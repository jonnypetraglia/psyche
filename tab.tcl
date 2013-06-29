snit::type tab {
    variable nick
    variable server
    variable ServerRef
    variable fileDesc
    variable channelMap
    variable id_var
    variable irc_conn
    
	# Next two can be blank, if the tab is a server
	# channel can be a nick if it's a PM
    variable channel
    variable port
    # Controls
    variable chat
    variable input

    
    ############## Get nick string
    method getNick {} {
	if [expr { [string length $server] > 0 }] {
	    return $nick
	}
	return [$ServerRef getNick]
    }
    
    ############## Get server string ##############
    method isServer {} {
	retun [expr { [string length $server] > 0 }]
    }
    
    ############## Get server string ##############
    method getServer {} {
	if [expr { [string length $server] > 0 }] {
	    return $server
	}
	return [$ServerRef getServer]
    }
    
    ############## Get server string ##############
    method joinChan {chan} {
	if [expr { [string length $server] > 0 }] {
	    set channelMap($chan) [tab %AUTO% $self $chan]
	} else {
	    $ServerRef joinChan $chan
	}
    }
    
    ############## getId ##############
    method getId {} { return $id_var }
   

    ############## Constructor ##############
    # Server:
    #        args = irc.geekshed.net 6697 nick
    # Channel:
    #        args = tab::server #jupiterbroadcasting
    constructor {args} {
	variable temp
	set server ""
	
	if [expr { [string length $args] > 0 }] {
	    $self init [lindex $args 0] [lindex $args 1] [lindex $args 2]
	} else {
	    set channel Temp
	    set id_var measure_tab
	}
	
	$self init_ui
	
	if [expr { [string length $args] > 0 }] {
	    if [expr { [string length $server] > 0 }] {
		$self initServer
	    } else {
		$self initChan
	    }
	}
    }
    
    ############## Initialize the variables ##############
    method init {arg0 arg1 arg2} {
	set nick $arg2
	# blank if is channel, a string if is server
	
	debug "~~~~~~~~~~NEW TAB~~~~~~~~~~~~~~"
	debug "  nick: !$nick!"
	
	if [ expr { [string length $nick] == 0} ] {
	    set ServerRef $arg0
	    set channel $arg1
	    set temp [$ServerRef getServer]
	    set id_var [concat $temp "__" $channel]
	    debug "  Channel: $channel"
	} else {
	    set server $arg0
	    set port $arg1
	    set id_var "$server"
	    debug "  Server: $server"
	}
    }
    
    ############## GUI stuff ##############
    # name should probably not be blank
    # id_var definitely should not be blank
    method init_ui {} {
	variable name
	if [expr { [string length $server] > 0 }] {
	    set name $server
	} else {
	    set name $channel
	}
	
	debug "  Name: $name"
	regsub -all "\\." $id_var "_" id_var
	regsub -all " " $id_var "__" id_var
	debug "  TabID: $id_var"
	
	# Magic bullshit
	set frame [$Main::notebook insert end $id_var -text $name]
	set topf  [frame $frame.topf]
	# Create the chat text widget
	set chat [text $topf.chat -height 30 -wrap word -font {Arial 9}]
	#$chat tag config bold   -font [linsert [$chat cget -font] end bold]
	#$chat tag config italic -font [linsert [$chat cget -font] end italic]
	#$chat tag config blue   -foreground blue
	$chat configure -background white
	$chat configure -state disabled
	
	# Create the input widget
	set input [entry $topf.input]
	bind $input <Return> [mymethod sendMessage]
	
	# Create the nicklist widget 
	set nicklistPanedWindow   [PanedWindow $topf.pw -side top]
	set pane  [$nicklistPanedWindow add -minsize 100]
        set nicklistScrolledWindow    [ScrolledWindow $pane.sw]
        set nicklist    [listbox $nicklistScrolledWindow.lb -height 8 -width 20 -highlightthickness 0]
        
        # DEBUG
        for {set i 1} {$i <= 100} {incr i} {
            $nicklist insert end "Value $i"
        }
        
        $nicklistScrolledWindow setwidget $nicklist
        
        # Add widgets to GUI - Order matters here!
	pack $input -side bottom -fill x
	pack $nicklistScrolledWindow $nicklistPanedWindow -fill both -expand 0 -side right
	pack $chat -fill both -expand 1
	pack $topf -fill both -expand 1
    }
    
    ############## Init Server ##############
    method initServer {} {
	set fileDesc [socket $server $port]
	$self _send "NICK $nick"
	#TODO: What is this
	$self _send "USER $nick 0 * :PicoIRC user"
	fileevent $fileDesc readable [mymethod _recv]
	
	$Main::toolbar_disconnect configure -state normal
	$Main::toolbar_join configure -state normal
	$Main::toolbar_part configure -state normal
	$Main::toolbar_properties configure -state normal
	$Main::toolbar_channellist configure -state normal
	$Main::toolbar_away configure -state normal
    }
    
    method initChan {} {
	$self _send "JOIN $channel"
    }
    
    ############## Append text to chat log ##############
    method append {txt stylez} {
	debug "$txt"
	$chat configure -state normal
	#$chat insert end "$txt\n"
	$chat insert end "$txt" $stylez
	$chat configure -state disabled
    }
    
    ############## Internal Function ##############
    method _recv {} {
	gets $fileDesc line
	if {[regexp {:([^!]*)![^ ].* +PRIVMSG ([^ :]+) +:(.*)} $line -> mNick mTarget mMsg]} {
	    puts "NICK:    $mTarget vs $nick"
	    if {[expr {$mTarget != $nick} ]} {
		$channelMap($mTarget) handleReceived $line
		return
	    }
	}
	$self handleReceived $line
    }
    
    method handleReceived {line} {
	#if {[regexp {:([^!]*)![^ ].* +PRIVMSG ([^ :]+) +:(.*)} $line -> nick target msg]} {
	    #set tag ""
	    #if [regexp {\001ACTION(.+)\001} $msg -> msg] {set tag italic}
	    #if [in {azbridge ijchain} $nick] {regexp {<([^>]+)>(.+)} $msg -> nick msg}
	    #$self append "$nick\t" bold
	    #$self append "$msg" $tag
	    #$self append "$line" $tag
	#} else {
	    $self append $line\n ""
	#}
	$chat yview end
    }
    #$chat insert end $nick\t bold $msg\n $tag
    
    ############## Send Message ##############
    method sendMessage {} {
	set msg [$input get]
	
	#DEBUG
	debug $msg
	
	#/me
	if [regexp {^/me (.+)} $msg -> action] {
	    set msg "\001ACTION $action\001"
	}
	#send "PRIVMSG $channel :$msg"
	
	$input delete 0 end
	set style ""
	if [regexp {\001ACTION(.+)\001} $msg -> msg] {set style italic}
	$self append $nick\t {bold blue}
	$self append $msg\n [list blue $style]
	    #TODO: Scroll only if at bottom
	$chat yview end
    }
    
    ############## Internal function ##############
    method _send {str} {
	if [expr { [string length $server] > 0 }] {
	    puts $fileDesc $str; flush $fileDesc
	} else {
	    $ServerRef _send $str
	}
    }
    
    
}

############## in: determines if an element is in a list? ##############
    proc in {list element} {expr {[lsearch -exact $list $element]>=0}}
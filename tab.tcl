source irc.tcl

snit::type tab {
    variable nick
    variable server
    variable ServerRef
    variable fileDesc
    variable channelMap
    variable activeChannels
    variable id_var
    variable irc_conn
    
	# Next two can be blank, if the tab is a server
	# channel can be a nick if it's a PM
    variable channel
    variable port
    # Controls
    variable chat
    variable input
    variable nickList

    
    ############## Get nick string
    method getNick {} {
	if { [string length $server] > 0 } {
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
	if { [string length $server] > 0 } {
	    return $server
	}
	return [$ServerRef getServer]
    }
    
    ############## Get server string ##############
    method joinChan {chan} {
	if { [string length $server] > 0 } {
	    set channelMap($chan) [tab %AUTO% $self $chan]
	    lappend activeChannels $channelMap($chan)
	    $Main::notebook raise [$channelMap($chan) getId]
	    $self updateToolbar $chan
	} else {
	    $ServerRef joinChan $chan
	}
    }
    
    ############## getId ##############
    method getId {} { return $id_var }
    method getfileDesc {} { return $fileDesc }
   

    ############## Constructor ##############
    # Server:
    #        args = irc.geekshed.net 6697 nick
    # Channel:
    #        args = tab::server #jupiterbroadcasting
    constructor {args} {
	variable temp
	set server ""
	
	if { [string length $args] > 0 } {
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
	set nickList [list]
	set activeChannels [list]
	set nick $arg2
	# blank if is channel, a string if is server
	
	debug "~~~~~~~~~~NEW TAB~~~~~~~~~~~~~~"
	debug "  nick: !$nick!"
	
	if { [string length $nick] == 0} {
	    set ServerRef $arg0
	    set channel $arg1
	    set temp [$ServerRef getServer]
	    set id_var [concat $temp " " $channel]
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
	if { [string length $server] > 0 } {
	    set name $server
	} else {
	    set name $channel
	}
	
	regsub -all "\\." $id_var "_" id_var
	regsub -all " " $id_var "*" id_var
	
	# Magic bullshit
	set frame [$Main::notebook insert end $id_var -text $name]
	set topf  [frame $frame.topf]
	# Create the chat text widget
	set chat [text $topf.chat -height 30 -wrap word -font {Arial 9}]
	$chat tag config bold   -font [linsert [$chat cget -font] end bold]
	$chat tag config italic -font [linsert [$chat cget -font] end italic]
	$chat tag config timestamp -font {Arial 7} -foreground grey60
	#$chat tag config blue   -foreground blue
	$chat configure -background white
	$chat configure -state disabled
	
	# Create the input widget
	set input [entry $topf.input]
	$input configure -background white
	bind $input <Return> [mymethod sendMessage]
	
	# Add widgets to GUI - Order matters here!
	pack $input -side bottom -fill x
	
	# Create the nicklist widget
	if { [string length $server] == 0 } {
	    set nicklistPanedWindow [PanedWindow $topf.pw -side top]
	    set pane  [$nicklistPanedWindow add -minsize 100]
	    set nicklistScrolledWindow [ScrolledWindow $pane.sw]
	    set nicklistCtrl [listbox $nicklistScrolledWindow.lb -listvariable [myvar nickList] \
				 -height 8 -width 20 -highlightthickness 0]
	    
	    $nicklistScrolledWindow setwidget $nicklistCtrl
	    pack $nicklistScrolledWindow $nicklistPanedWindow -fill both -expand 0 -side right
	}
        
	pack $chat -fill both -expand 1
	pack $topf -fill both -expand 1
    }
    
    method updateToolbar {mTarget} {
	if [info exists channelMap($mTarget)] {
	    $channelMap($mTarget) updateToolbar ""
	    return
	}
	
	#Is Server
	if { [string length $server] > 0 } {
	    #Is connected
	    if { [string length $fileDesc] > 0 } {
		$Main::toolbar_join configure -state normal
		$Main::toolbar_disconnect configure -state normal
		$Main::toolbar_reconnect configure -state disabled
		$Main::toolbar_properties configure -state normal
		$Main::toolbar_channellist configure -state normal
		$Main::toolbar_away configure -state normal
	    } else {
		$Main::toolbar_join configure -state disabled
		$Main::toolbar_disconnect configure -state disabled
		$Main::toolbar_reconnect configure -state normal
		$Main::toolbar_properties configure -state normal
		$Main::toolbar_channellist configure -state normal
		$Main::toolbar_away configure -state normal
	    }
	    $Main::toolbar_part configure -state disabled
	    
	    
	#Is Channel
	} else {
	    #Is connected
	    if { [string length [$ServerRef getfileDesc] ] > 0 } {
		#Is connected to this channel
		if { [lsearch $activeChannels $mTarget] != -1 } {
		    $Main::toolbar_part configure -state normal
		} else {
		    $Main::toolbar_part configure -state disabled
		}
		$Main::toolbar_join configure -state normal
		$Main::toolbar_disconnect configure -state normal
		$Main::toolbar_reconnect configure -state disabled
	    } else {
		$Main::toolbar_part configure -state disabled
		$Main::toolbar_join configure -state disabled
		$Main::toolbar_disconnect configure -state disabled
		$Main::toolbar_reconnect configure -state normal
	    }
	}
    }
    
    ############## Init Server ##############
    method initServer {} {
	set fileDesc [socket $server $port]
	puts $fileDesc
	$self _send "NICK $nick"
	#TODO: What is this
	$self _send "USER $nick 0 * :PicoIRC user"
	fileevent $fileDesc readable [mymethod _recv]
	$self updateToolbar ""
    }
    
    ############## Init Channel ##############
    method initChan {} {
	$self _send "JOIN $channel"
    }
    
    ############## Append text to chat log ##############
    method append {txt stylez} {
	$chat configure -state normal
	$chat insert end $txt $stylez
	$chat configure -state disabled
    }
    
    ############## Internal Function ##############
    method _recv {} {
	gets $fileDesc line
	set timestamp [clock format [clock seconds] -format \[%H:%M\] ]
	debug $line
	
	#PING
	if {[regexp {^PING :(.*)} $line -> mResponse]} {
	    $self _send "PONG :$mResponse"
	    return
	}
	
	# Private message - sent to channel or user
	if {[regexp {:([^!]*)![^ ].* +PRIVMSG ([^ :]+) +:(.*)} $line -> mNick mTarget mMsg]} {
	    debug TOP
	    if {[expr {$mNick != "IRC"} ]} {
		$channelMap($mTarget) handleReceived $timestamp <$mNick> bold $mMsg ""
		return
	    }
	}
	
	# Numbered message - sent to channel, user, or no one (mTarget could be blank)
	if {[regexp {:([^ ]*) ([0-9]+) byteslol =?([^:]*):(.*)} $line -> mServer mCode mTarget mMsg]} {
	    debug MIDDLE
	    set mTarget [string trim $mTarget]
	    set mMsg [string trim $mMsg]
	    switch $mCode {
		333 {
		    #RPL_TOPICWHOTIME
		    regexp {^ChanServ (.*)} $mMsg -> mMsg
		    set mMsg [clock format $mMsg]
		}
		353 {
		    #RPL_NAMREPLY
		    $channelMap($mTarget) addUsers $mMsg
		    return
		}
		366 {
		    #RPL_ENDOFNAMES
		    $channelMap($mTarget) sortUsers
		    return
		}
	    }
	    debug "$mCode!!!$mTarget"
	    if [info exists channelMap($mTarget)] {
		$channelMap($mTarget) handleReceived $timestamp [getTitle $mCode] bold $mMsg "" 
		return
	    } else {
		$self handleReceived $timestamp [getTitle $mCode] bold $mMsg "" 
		return
	    }
	}
	# Numbered message #2
	if {[regexp {:([^ ]*) ([0-9]+) byteslol (.*)} $line -> mServer mCode mMsg]} {
	    $self handleReceived $timestamp [getTitle $mCode] bold $mMsg ""
	    debug MIDDLE2
	    return
	}
	
	# Server message with no numbers but sent explicitely from server
	if {[regexp {:([^ ]*) ([^ ]*) ([^:]*):(.*)} $line -> mServer mSomething mTarget mMsg]} {
	    debug BOTTOM
	    # MODE
	    #if {[expr {$mServer == $nick} ]} {
		$self handleReceived $timestamp \[$mSomething\] bold $mMsg ""
	    #} else {
		#$self handleReceived $mServer bold $mMsg "" 
	    #}
	    return
	}
	debug "WHAT: $line"
    }
    
    method addUsers {users} {
	set users [split $users]
	foreach usr $users {
	    lappend nickList $usr
	}
	debug "TESTX"
	debug $nickList
    }
    
    method sortUsers {} {
	set nickList [lsort -command compare $nickList]
	debug "TEST366 $channel"
	debug $nickList
    }
   
    
    method handleReceived {timestamp title style1 message style2} {
	$self append $timestamp\  timestamp
	$self append $title\  $style1
	$self append $message\n $style2
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
	$self append $nick\  {bold blue}
	$self append $msg\n [list blue $style]
	    #TODO: Scroll only if at bottom
	$chat yview end
    }
    
    ############## Internal function ##############
    method _send {str} {
	if { [string length $server] > 0 } {
	    puts $fileDesc $str; flush $fileDesc
	} else {
	    $ServerRef _send $str
	}
    }
    
    # for server
    method quit {reason} {
	if { [string length $server] > 0 } {
	    set timestamp [clock format [clock seconds] -format \[%H:%M\] ]
	    $self _send "QUIT $reason"
	    close $fileDesc
	    set fileDesc ""
	    $self handleReceived $timestamp " \[QUIT\] " bold "You have left the server" ""
	    $self updateToolbar ""
	    
	    #foreach cha $channelMap {
		#TODO: Print in each Channel's tab
	    #}
	} else {
	    $ServerRef quit $reason
	}
    }
    
    # for channel
    method part {chann reason} {
	if { [string length $server] > 0 } {
	    $channelMap($chann) part $chann $reason
	} else {
	    set timestamp [clock format [clock seconds] -format \[%H:%M\] ]
	    $self _send "PART $chann $reason"
	    $self handleReceived $timestamp " \[PART\] " bold "You have left the channel" ""
	    
	    
	    set idx [lsearch $activeChannels $chann]
	    set activeChannels [lreplace $activeChannels $idx $idx]

	    set parts [split [$Main::notebook raise] "*"]
	    set serv [lindex $parts 0]
	    set chan [lindex $parts 1]
	    regsub -all "_" $serv "." serv
	    $Main::servers($serv) updateToolbar $chan
	}
    }
}

############## in: determines if an element is in a list? ##############
    proc in {list element} {expr {[lsearch -exact $list $element]>=0}}
    
# ~ = admin
# & = owner
# @ = op
# % = halfop
# + = voice
    
variable compareMap
set compareMap(~) 0
set compareMap(&) 1
set compareMap(@) 2
set compareMap(%) 3
set compareMap(+) 4
    
proc compare {a b} {
    global compareMap;
    set av 10
    set bv 10
    set a0 [lindex $a 0]
    set b0 [lindex $b 0]
    
    if {[regexp {^[~&@%+].*} $a0]} {
	set av $compareMap([string index $a0 0])
    }
    if {[regexp {^[~&@%+].*} $b0]} {
	set bv $compareMap([string index $b0 0])
    }
    if {$av == 10 && $bv == 10 } {
	return [string compare [lindex $a 1] [lindex $b 1]]
    } else {
	if {$av < $bv} {
	    return -1
	} elseif {$av > $bv} {
	    return 1
	}
    }
}
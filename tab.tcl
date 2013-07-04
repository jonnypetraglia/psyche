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
    method joinChan {chan pass} {
	if { [string length $server] > 0 } {
	    if [info exists channelMap($chan)] {
		$channelMap($chan) initChan $pass
	    } else {
		set channelMap($chan) [tab %AUTO% CHAN $self $chan $pass]
	    }
	    lappend activeChannels $chan
	    $Main::notebook raise [$channelMap($chan) getId]
	    $self updateToolbar $chan
	} else {
	    $ServerRef joinChan $chan $pass
	}
    }
    
    ############## getId ##############
    method getId {} { return $id_var }
    method getfileDesc {} { return $fileDesc }
    method isServer {} {
	if {[string length $server] > 0} {
	    return 1
	}
	return 0
    }
    method getChannel {} {
	if {[string length $server] > 0} {
	    return ""
	}
	return $channel
    }


    ############## Constructor ##############
    # Server:
    #        args = SERV irc.geekshed.net 6697 nick
    # Channel:
    #        args = CHAN tab::server #jupiterbroadcasting pass
    # PM:
    #        args = CHAN tab::server userhost
    #		need to manually set the tab name?
    constructor {args} {
	variable temp
	set server ""
	
	# If it has no args it's a dummy tab for measurement
	if { [string length $args] > 0 } {
	    $self init [lindex $args 0] [lindex $args 1] [lindex $args 2] [lindex $args 3]
	} else {
	    set channel Temp
	    set id_var measure_tab
	}
	
	$self init_ui
	
	if { [string length $args] > 0 } {
	    if [expr { [string length $server] > 0 }] {
			$self initServer
	    } else {
			$self initChan [lindex $args 3]
	    }
	}
    }
    
    ############## Initialize the variables ##############
    method init {arg0 arg1 arg2 arg3} {
	set nickList [list]
	set activeChannels [list]

	# blank if is channel, a string if is server
	
	debug "~~~~~~~~~~NEW TAB~~~~~~~~~~~~~~"
	debug "  nick: !$arg0!"
	
	if { $arg0 == "CHAN"} {
	    set ServerRef $arg1
	    set channel $arg2
	    set temp [$ServerRef getServer]
	    set id_var [concat $temp " " $channel]
	    debug "  Channel: $channel"
	} else {
	    set server $arg1
	    set port $arg2
	    set id_var "$server"
	    set nick [string trim $arg3]
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
	set chat [text $topf.chat -height 30 -wrap word -font {Arial 11}]
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
	
    ############## Update the toolbar's statuses ##############
    method updateToolbar {mTarget} {
	if [info exists channelMap($mTarget)] {
	    $channelMap($mTarget) updateToolbar $mTarget
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
		$Main::toolbar_nick configure -state normal
		$Main::toolbar_away configure -state normal
	    } else {
		$Main::toolbar_join configure -state disabled
		$Main::toolbar_disconnect configure -state disabled
		$Main::toolbar_reconnect configure -state normal
		$Main::toolbar_properties configure -state disabled
		$Main::toolbar_channellist configure -state disabled
		$Main::toolbar_away configure -state disabled
	    }
	    $Main::toolbar_part configure -state disabled
	    
	    
	#Is Channel
	} else {
	    #Is connected
	    if { [string length [$ServerRef getfileDesc] ] > 0 } {
		#Is connected to this channel
		puts "UPDATETOOLBAR: $mTarget [lsearch $activeChannels $mTarget]"
		if { [$ServerRef isChannelConnected $mTarget] } {
		    $Main::toolbar_part configure -state normal
		} else {
		    $Main::toolbar_part configure -state disabled
		}
		$Main::toolbar_join configure -state normal
		$Main::toolbar_disconnect configure -state normal
		$Main::toolbar_reconnect configure -state disabled
		$Main::toolbar_properties configure -state normal
		$Main::toolbar_channellist configure -state normal
		$Main::toolbar_away configure -state normal
	    } else {
		$Main::toolbar_part configure -state disabled
		$Main::toolbar_join configure -state disabled
		$Main::toolbar_disconnect configure -state disabled
		$Main::toolbar_reconnect configure -state normal
		$Main::toolbar_properties configure -state disabled
		$Main::toolbar_channellist configure -state disabled
		$Main::toolbar_away configure -state disabled
	    }
	}
    }
    
    method isChannelConnected {chann} {
	if { [string length $server] > 0 } {
	    if {[lsearch $activeChannels $chann] != -1} {
		return true
	    }
	    return false
	} else {
	    return [$ServerRef isChannelConnected $chann]
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
    method initChan {pass} {
	if {[string index $channel 0] == "#"} {
	    $self _send "JOIN $channel $pass"
	}
    }
    
    ############## Append text to chat log ##############
    method append {txt stylez} {
	$chat configure -state normal
	$chat insert end $txt $stylez
	$chat configure -state disabled
    }

    ############## Change the tab name ##############
    method updateTabName {newName} {
	if {$newName != $channel} {
	    set channel $newName
	    $Main::notebook itemconfigure [$self getId] -text $channel
	}
    }

    ############## Send a Private Message to a user...or maybe channel? ##############    
    method sendPM { mNick mMsg} {
	if { [string length $server] == 0 } {
	    $ServerRef sendPM $mNick $mMsg
	    return
	}
	$self _send "PRIVMSG $mNick $mMsg"
	$self createPMTabIfNotExist $mNick
	set timestamp [clock format [clock seconds] -format \[%H:%M\] ]
	$channelMap($mNick) handleReceived $timestamp <$mNick> bold $mMsg ""
    }
    
    method createPMTabIfNotExist { mNick } {
	if {![info exists channelMap($mNick)]} {
	    set channelMap($mNick) [tab %AUTO% CHAN $self $mNick]
	    if { $Pref::raiseNewTabs} {
		    $Main::notebook raise [$channelMap($mNick) getId]
	    }
	}
	$channelMap($mNick) updateTabName $mNick
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
	if {[regexp {:([^!]*)(![^ ]+) +PRIVMSG ([^ :]+) +:(.*)} $line -> mFrom mHost mTo mMsg]} {
	    debug TOP
	    puts "FROM: $mFrom  TO: $mTo"
	    # PRIVMSG
	    if {$mFrom != "IRC"} {
		# PM to me
		if {$mTo == [$self getNick]} {
		    $self createPMTabIfNotExist $mFrom
		    # PM - /me
		    if [regexp {\001ACTION ?(.+)\001} $mMsg -> mMsg] {
			$channelMap($mFrom) handleReceived $timestamp " \*" bold "$mFrom $mMsg" italic
		    # PM - general
		    } else {
			$channelMap($mNick) handleReceived $timestamp <$mNick> bold $mMsg ""
		    }
		# Msg to channel
		} else {
		    # Msg - /me
		    if [regexp {\001ACTION(.+)\001} $mMsg -> mMsg] {
			$channelMap($mTo) handleReceived $timestamp " \*" bold "$mFrom $mMsg" italic
		    # Msg - general
		    } else {
			$channelMap($mTo) handleReceived $timestamp <$mFrom> bold $mMsg ""
		    }
		}
		return
	    }
	}
	
	# Numbered message - sent to channel, user, or no one (mTarget could be blank)
	if {[regexp ":(\[^ \]*) (\[0-9\]+) [$self getNick] \[=@\]?(\[^:\]*):(.*)" $line -> mServer mCode mTarget mMsg]} {
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
		321 {
		    #RPL_LISTSTART
		    if {[wm state .channelList]=="normal"} {
			return
		    }
		}
		322 {
		    #RPL_LIST 
		    if {[wm state .channelList]=="normal"} {
			if {[regexp {(#[^ ]+) ([0-9]+)} $mTarget -> mTarget mUserCount]} {
			    #TODO: Fix regex to remove modes
			    regexp { ?\[.*\] (.*)} $mMsg -> mMsg
			    set whspc [string length $mTarget]
			    set whspc [expr {33 - $whspc}]
			    set whspc [string repeat " " $whspc]
			    set sss [$self getServer]
			    lappend Main::channelList($sss) "$mTarget$whspc$mMsg"
			}
			return
		    }
		}
		323 {
		    #RPL_LISTEND
		    if {[wm state .channelList]=="normal"} {
			set sss [$self getServer]
			set Main::channelList($sss) [lsort -nocase $Main::channelList($sss)]
			return
		    }
		}
		328 {
			#RPL_CHANNEL_URL
			# Ignore
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
	if {[regexp ":(\[^ \]*) (\[0-9\]+) [$self getNick] (.*)" $line -> mServer mCode mMsg]} {
	    $self handleReceived $timestamp [getTitle $mCode] bold $mMsg ""
	    debug MIDDLE2
	    return
	}
	
	# Server message with no numbers but sent explicitely from server
	if {[regexp {:([^ ]*) ([^ ]*) ([^:]*):(.*)} $line -> mServer mSomething mTarget mMsg]} {
	    debug BOTTOM
	    if {$mSomething == "NICK" } {
		$self nickChanged $mMsg
	    } else {
		$self handleReceived $timestamp \[$mSomething\] bold $mMsg ""
	    }
	    return
	}
	debug "WHAT: $line"
    }
    
    ############## Add a batch of users to the nick list ##############
    method addUsers {users} {
	set users [split $users]
	foreach usr $users {
	    lappend nickList $usr
	}
	debug "TESTX"
	debug $nickList
    }
    
    ############## Sort the nick list ##############
    method sortUsers {} {
	set nickList [lsort -command compareNick $nickList]
	debug "TEST366 $channel"
	debug $nickList
    }

    ############## Internal function ##############
    method handleReceived {timestamp title style1 message style2} {
	$self append $timestamp\  timestamp
	$self append $title\  $style1
	$self append $message\n $style2
	$chat yview end
    }
    
    ############## Send Message ##############
    method sendMessage {} {
	set msg [$input get]
	$input delete 0 end
	
	#DEBUG
	debug $msg

	# Starts with a backslash
	if [regexp {^/(.+)} $msg -> msg] {
		if { [string index $msg 0] != "/"} {
			if [performSpecialCase $msg $self ] {
				return
			}
		}
	}

	#/me
	#if [regexp {^/me (.+)} $msg -> action] {
	#    set msg "\001ACTION $action\001"
	#}
	
	set style ""
	
	#if [regexp {\001ACTION(.+)\001} $msg -> msg] {set style italic}
	
	set timestamp [clock format [clock seconds] -format \[%H:%M\] ]
	# Send to server
	if { [string length $server] > 0 } {
	    $self _send $msg
	    set lenick \[Raw\]
	} else {
	    $self _send "PRIVMSG $channel :$msg"
	    set lenick <[$self getNick]>
	}
	
	$self handleReceived $timestamp $lenick {bold blu} $msg $style
	
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
    
    ############## SERVER: Quit a server ##############
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
    
    ############## CHANNEL: Part a channel ##############
    method part {chann reason} {
	if { [string length $server] > 0 } {
	    $channelMap($chann) part $chann $reason
	} else {
	    set timestamp [clock format [clock seconds] -format \[%H:%M\] ]
	    $self _send "PART $chann $reason"
	    $self handleReceived $timestamp \[PART\] bold "You have left the channel" ""
	    
	    $ServerRef removeActiveChannel $chann

	    set parts [split [$Main::notebook raise] "*"]
	    set serv [lindex $parts 0]
	    set chan [lindex $parts 1]
	    regsub -all "_" $serv "." serv
	    $self updateToolbar $chan
	}
    }
    
    method removeActiveChannel {chann} {
	if { [string length $server] > 0 } {
	    puts "REMOVING: $activeChannels"
	    set idx [lsearch $activeChannels $chann]
	    set activeChannels [lreplace $activeChannels $idx $idx]
	}
    }
    
    ############## Nick has been changed ##############
    method nickChanged {newnick} {
	if { [string length $server] > 0 } {
	    set nick $newnick
	    set timestamp [clock format [clock seconds] -format \[%H:%M\] ]
	    foreach key [array names $activeChannels] {
		$activeChannels($key) handleReceived $timestamp "***" bold "You are now known as $nick" ""
	    }
	    $self handleReceived $timestamp "***" bold "You are now known as $nick" ""
	} else {
	    $ServerRef nickChanged $newnick
	}
    }
    
    
    
    method _setData {newport newnick} {
	if { [string length $server] > 0 } {
		set nick $newnick
		set port $newport
	} else {
		$ServerRef _setNick $newport $newnick
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
    
proc compareNick {a b} {
    global compareMap;
    set av 10
    set bv 10
    set a0 [lindex $a 0]
    set b0 [lindex $b 0]
    
    # Determine if either start with a special symbol
    if {[regexp {^[~&@%+].*} $a0]} {
		set av $compareMap([string index $a0 0])
    }
    if {[regexp {^[~&@%+].*} $b0]} {
		set bv $compareMap([string index $b0 0])
    }

    # If they are the same class (e.g. both ops OR both normal (10))
    if {$av == $bv } {
		return [string compare [lindex $a 1] [lindex $b 1]]
    } else {
		if {$av < $bv} {
		    return -1
		} elseif {$av > $bv} {
		    return 1
		} else {
			return 0
		}
    }
}
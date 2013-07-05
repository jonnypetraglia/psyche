source irc.tcl

snit::type tab {
    variable nick
    variable server
    variable ServerRef
    variable connDesc
    variable channelMap
    variable activeChannels
    variable id_var
    
    # Server
    variable CreationTime
    variable MOTD
    variable ChannelPrefixes
    variable NickPrefixes
    variable NetworkName
    variable ServerName
    variable ServerDaemon
    
    # Channel
    variable Topic
    variable TopicTime
    
    #TODO
    variable serverType
    # ^ Unreal3.2.8-gs.9
    # ^ ircd-seven-1.1.3
    
	# Next two can be blank, if the tab is a server
	# channel can be a nick if it's a PM
    variable channel
    variable port
    # Controls
    variable chat
    variable input
    variable nickList
    variable awayLabel

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
		set reason [$awayLabel cget -text]
		if {[regexp {^\(Away: (.+)\)} $reason -> reason]} {
		    $channelMap($chan) away $reason
		    $channelMap($chan) _showAway
		}
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
    method getconnDesc {} { return $connDesc }
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
    method getChannPrefixes {} {
	if {[string length $server] > 0} {
	    return [$SeverRef getChannPrefixes]
	}
	return $ChannelPrefixes
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
	set chat [text $topf.chat -height 20 -wrap word -font {Arial 11}]
	$chat tag config bold   -font [linsert [$chat cget -font] end bold]
	$chat tag config italic -font [linsert [$chat cget -font] end italic]
	$chat tag config timestamp -font {Arial 7} -foreground grey60
	$chat tag config blue   -foreground blue
	$chat configure -background white
	$chat configure -state disabled
	
	set lowerFrame [frame $topf.f]
	
	# Create the away label
	set awayLabel [label $lowerFrame.l_away -text ""]
	
	# Create the input widget
	set input [entry $lowerFrame.input]
	$input configure -background white
	bind $input <Return> [mymethod sendMessage]

	grid $awayLabel -row 0 -column 0
	grid $input -row 0 -column 1 -sticky ew
	grid columnconfigure $lowerFrame 1 -weight 1
	pack $lowerFrame -side bottom -fill x

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
	
	grid remove $awayLabel
    }
	
    ############## Update the specific Away button ##############
    method updateToolbarAway {mTarget} {
	if [info exists channelMap($mTarget)] {
	    $channelMap($mTarget) updateToolbarAway $mTarget
	    return
	}
	
	set icondir [pwd]/icons
	set reason [$awayLabel cget -text]
	if {[regexp {^\(Away: (.+)\)} $reason -> reason]} {
	    $Main::toolbar_away configure -image [image create photo -file $icondir/back.gif] -helptext "Back"
	} else {
	    $Main::toolbar_away configure -image [image create photo -file $icondir/away.gif] -helptext "Away"
	}
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
	    if { [string length $connDesc] > 0 } {
		$Main::toolbar_join configure -state normal
		$Main::toolbar_disconnect configure -state normal
		$Main::toolbar_reconnect configure -state disabled
		$Main::toolbar_properties configure -state normal
		$Main::toolbar_channellist configure -state normal
		$Main::toolbar_nick configure -state normal
		$Main::toolbar_away configure -state normal
		$self updateToolbarAway $mTarget
	    } else {
		$Main::toolbar_join configure -state disabled
		$Main::toolbar_disconnect configure -state disabled
		$Main::toolbar_reconnect configure -state normal
		$Main::toolbar_properties configure -state disabled
		$Main::toolbar_channellist configure -state disabled
		$Main::toolbar_away configure -state disabled
		$Main::toolbar_away configure -image [image create photo -file $icondir/away.gif]
	    }
	    $Main::toolbar_part configure -state disabled
	    
	    
	#Is Channel
	} else {
	    #Is connected
	    if { [string length [$ServerRef getconnDesc] ] > 0 } {
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
	set connDesc [socket $server $port]
	puts $connDesc
	$self _send "NICK $nick"
	#TODO: What is this
	$self _send "USER $nick 0 * :Psyche user"
	fileevent $connDesc readable [mymethod _recv]
	$self updateToolbar ""
    }
    
    ############## Init Channel ##############
    method initChan {pass} {
	if {[string index $channel 0] == "#"} {
	    puts "HERP"
	    #$self _send "JOIN $channel $pass"
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
	gets $connDesc line
	set timestamp [clock format [clock seconds] -format \[%H:%M\] ]
	debug $line
	
	# PING
	if {[regexp {^PING :(.*)} $line -> mResponse]} {
	    $self _send "PONG :$mResponse"
	    return
	}
	
	# CTCP - EXCEPT for 
	if {[regexp ":(\[^!\]*)!.* (\[^ \]*) [$self getNick] :\001\(\[^ \]*\) ?\(.*\)\001" \
		$line -> mFrom mThing mCmd mContent]} {
	    # mFrom    = User that sent CTCP msg
	    # mThing   = NOTICE for response, PRIVMSG for initiation
	    # mCmd     = VERSION, PING, etc
	    # mContent = timestamp for PING, empty for VERSION, etc
	    set mContent [string trim $mContent]
	    switch $mCmd {
		"PING" {
		    if {$mThing == "NOTICE"} {
			$self handleReceived $timestamp \[CTCP\] bold "Ping response from $mFrom: [expr {[clock seconds] - $mContent}] seconds" ""
		    } else {
			$self _send "NOTICE $mFrom :\001PING $mContent\001"
			$self handleReceived $timestamp \[CTCP\] bold "Ping request from $mFrom" ""
		    }
		}
		"VERSION" {
		    if {$mThing == "NOTICE"} {
			$self handleReceived $timestamp \[CTCP\] bold "Version response from $mFrom: $mContent" ""
		    } else {
			$self _send "NOTICE $mFrom :\001VERSION $Main::APP_NAME v$Main::APP_VERSION (C) 2013 Jon Petraglia"
			$self handleReceived $timestamp \[CTCP\] bold "Version request from $mFrom" ""
		    }
		}
	    }
	    return
	}
	
	
	# Private message - sent to channel or user
	if {[regexp {:([^!]*)(![^ ]+) +PRIVMSG ([^ :]+) +:(.*)} $line -> mFrom mHost mTo mMsg]} {
	    debug TOP
	    puts "FROM: $mFrom  TO: $mTo"
	    # PM to me
	    if {$mTo == [$self getNick]} {
		# PM - /me
		if [regexp {\001ACTION ?(.+)\001} $mMsg -> mMsg] {
		    $self createPMTabIfNotExist $mFrom
		    $channelMap($mFrom) handleReceived $timestamp " \*" bold "$mFrom $mMsg" italic
		# PM - general
		} else {
		    $self createPMTabIfNotExist $mFrom
		    $channelMap($mFrom) handleReceived $timestamp <$mFrom> bold $mMsg ""
		}
		
	    # Msg to channel
	    } else {
		# Msg - /me
		if [regexp {\001ACTION ?(.+)\001} $mMsg -> mMsg] {
		    $channelMap($mTo) handleReceived $timestamp " \*" bold "$mFrom $mMsg" italic
		# Msg - general
		} else {
		    $channelMap($mTo) handleReceived $timestamp <$mFrom> bold $mMsg ""
		}
	    }
	    return
	}
	
	# Numbered message - sent to channel, user, or no one (mTarget could be blank)
	#  Type A: Has an intended target, even if that target is blank;
	#          Following the nick, there is a string of length 0 or more, then a space, then a colon
	if {[regexp ":(\[^ \]*) (\[0-9\]+) [$self getNick] ?\[=@\]? ?(\[^ \]*) :(.*)" $line -> mServer mCode mTarget mMsg]} {
	    debug MIDDLE
	    set mTarget [string trim $mTarget]
	    set mMsg [string trim $mMsg]
	    switch $mCode {
		002 {
		    #Your host is hitchcock.freenode.net[93.152.160.101/6667], running version ircd-seven-1.1.3
		    #Your host is Komma.GeekShed.net, running version Unreal3.2.8-gs.9
		    regexp {^Your host is ([^,]+), running version (.*)} $mMsg -> ServerName ServerDaemon
		}
		003 {
		    regexp {^This server was created (.*)} $mMsg -> CreationTime
		}
		303 {
		    #RPL_ISON
		    set mMsg "$mMsg is online"
		}
		305 {
		    #RPL_UNAWAY
		    $self _hideAway
		    $self awaySignalServer ""
		    Main::updateAwayButton
		}
		306 {
		    #RPL_NOWAWAY
		    $self _showAway
		    Main::updateAwayButton
		}
		332 {
		    #RPL_TOPIC
		    if {[string length $mMsg] == 0} {
			set mMsg "(No topic set)"
		    }
		    set Topic $mMsg
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
		323 {
		    #RPL_LISTEND
			set sss [$self getServer]
			set Main::channelList($sss) [lsort -nocase $Main::channelList($sss)]
		    if {[wm state .channelList]=="normal"} {
			return
		    }
		}
		328 {
		    #RPL_CHANNEL_URL
		    # Ignore
		    return
		}
	    }
	    if [info exists channelMap($mTarget)] {
			$channelMap($mTarget) handleReceived $timestamp [getTitle $mCode] bold $mMsg "" 
			return
	    } else {
			$self handleReceived $timestamp [getTitle $mCode] bold $mMsg "" 
		return
	    }
	}
	#  Type B: Is stil a numbered message, but the content immediately follows the nick
	if {[regexp ":(\[^ \]*) (\[0-9\]+) [$self getNick] (.*)" $line -> mServer mCode mMsg]} {
	    $self handleReceived $timestamp [getTitle $mCode] bold $mMsg ""
	    debug MIDDLE2
	    switch $mCode {
		005 {
		    # Pull out CHANTYPES (prefixes for channels)
		    if [regexp {.*CHANTYPES=([^ ]+) .*} $mMsg -> derp] {
			set ChannelPrefixes $derp
		    }
		    
		    # Pull out PREFIX (user modes, e.g. ~&@%+)
		    if [regexp {.*PREFIX=([^ ]+) .*} $mMsg -> userModes] {
			set NickPrefixes $userModes
		    }
		    
		    regexp {.*NETWORK=([^ ]+) .*} $mMsg -> NetworkName
		}
		322 {
		    #RPL_LIST 
		    if {[regexp {(#[^ ]+) ([0-9]+)} $mMsg -> mTarget mUserCount]} {
			#TODO: Fix regex to remove modes
			regexp { ?\[.*\] (.*)} $mMsg -> mMsg
			set whspc [string length $mTarget]
			set whspc [expr {33 - $whspc}]
			set whspc [string repeat " " $whspc]
			set sss [$self getServer]
			puts "$mTarget$whspc$mMsg"
			lappend Main::channelList($sss) "$mTarget$whspc$mMsg"
		    }
		    if {[wm state .channelList]=="normal"} {
			return
		    }
		}
		333 {
		    #RPL_TOPICWHOTIME
		    if {[regexp {(#[^ ]+) ([^ ]+) ([0-9]+)} $mMsg -> mTarget mBy mTopicTime]} {
			$channelMap($mTarget) handleReceived $timestamp [getTitle $mCode] bold "Topic set by $mBy at [clock format $mTopicTime]" ""
			return
		    }
		}
	    }
	    return
	}
	
	#:byteslol!~byteslol@protectedhost-99B37D77.hsd1.co.comcast.net NICK :bytes101
	if {[regexp {:([^!]*)!.* ([^ ]*) [^:]*:(.*)} $line -> mNick mSomething mMsg]} {
		switch $mSomething {
		"NICK" {
		    if {$mNick == [$self getNick]} {
			$self handleReceived $timestamp "***" bold "You are now known as $mMsg" ""
			$self propogateMessage MYNICK $timestamp "***" bold "You are now known as $mMsg" ""
			$self nickChanged $mMsg
		    } else {
			#$self handleReceived $timestamp "***" bold "$mNick is now known as $mMsg" ""
			$self propogateMessage NICK $timestamp "***" bold "$mNick is now known as $mMsg" ""
		    }
		    return
		}
		"JOIN" {
		    if {$mNick == [$self getNick]} {
			$self joinChan $mMsg ""
		    } else {
			$channelMap($mMsg) handleReceived $timestamp "***" bold "$mNick has joined" ""
		    }
		    return
		}
		default {
		    $self handleReceived $timestamp \[$mSomething\] bold $mMsg ""
		}
	    }
	}
	
	
	# Server message with no numbers but sent explicitely from server
	if {[regexp {:([^ ]*) ([^ ]*) ([^:]*):(.*)} $line -> mServer mSomething mTarget mMsg]} {
	    debug BOTTOM
	    debug "!!!!!!!!!$line"
	}
	debug "WHAT: $line"
    }
    
    method propogateMessage {what timestamp title titleStyle msg msgStyle} {
	if { [string length $server] > 0 } {
	    foreach key $activeChannels {
		$channelMap($key) propogateMessage $what $timestamp $title $titleStyle $msg $msgStyle
	    }
	    return
	}
	
	puts "WHAT: $what"
	
	#if what is NICK, check the nick list
	if {$what == "NICK"} {
	    regexp {([^ ]+) is now known as (.*)} $msg -> oldNick newNick
	    set ind [lsearch $nickList $oldNick]
	    #TODO ^ -sorted
	    if {$ind > -1} {
		lset nickList $ind $newNick
		set nickList [lsort -command [mymethod compareNick] $nickList]
	    } else { return }
	}
	
	if {$what == "MYNICK"} {
	    regexp {You are now known as (.*)} $msg -> newNick
	    set ind [lsearch $nickList [$self getNick]]
	    #TODO ^ -sorted
	    if {$ind > -1} {
		lset nickList $ind $newNick
		set nickList [lsort -command [mymethod compareNick] $nickList]
	    }
	}
	
	$self handleReceived $timestamp $title $titleStyle $msg $msgStyle
    }
    
    ############## Add a batch of users to the nick list ##############
    method addUsers {users} {
	set users [split $users]
	foreach usr $users {
	    lappend nickList $usr
	}
    }
    
    ############## Sort the nick list ##############
    method sortUsers {} {
	set nickList [lsort -command [mymethod compareNick] $nickList]
    }

    ############## Internal function ##############
    method handleReceived {timestamp title style1 message style2} {
	set isAtBottom [lindex [$chat yview] 1]
	$self append $timestamp\  timestamp
	$self append $title\  $style1
	$self append $message\n $style2
	if {$isAtBottom==1.0} {
	    $chat yview end
	}
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

	
	set style ""
	
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
	    puts $connDesc $str; flush $connDesc
	} else {
	    $ServerRef _send $str
	}
    }
    
    ############## SERVER: Quit a server ##############
    method quit {reason} {
	if { [string length $server] > 0 } {
	    set timestamp [clock format [clock seconds] -format \[%H:%M\] ]
	    $self _send "QUIT $reason"
	    close $connDesc
	    set connDesc ""
	    $self handleReceived $timestamp " \[QUIT\] " bold "You have left the server" ""
	    $self updateToolbar ""
	    
	    $self propogateMessage ALL $timestamp " \[QUIT\] " bold "You have left the server" ""
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
    
    ############## SERVER: Removes a channel from the active list ##############
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
	    #foreach key $activeChannels {
		#$activeChannels($key) handleReceived $timestamp "***" bold "You are now known as $nick" ""
	    #}
	    #$self propogateMessage ALL $timestamp "***" bold "You are now known as $nick" ""
	    #$self handleReceived $timestamp "***" bold "You are now known as $nick" ""
	} else {
	    $ServerRef nickChanged $newnick
	}
    }
    
    ############## Clears the chat view ##############
    method clearScrollback {} {
	$chat configure -state normal
	$chat delete 0.0 end
	$chat configure -state disabled
    }
    
    ############## Used by the server to notify its children that it is away ##############
    method awaySignalServer {reason} {
	if { [string length $server] > 0 } {
	    foreach key $activeChannels {
		$channelMap($key) away $reason
	    }
	    $self away $reason
	} else {
	    $ServerRef awaySignalServer $reason
	}
    }
    
    ############## Modifies the message away ##############
    method away {reason } {
	$awayLabel configure -text "(Away: $reason)"
    }
    
    ############## Hides GUI element ##############
    method _hideAway {} {
	if { [string length $server] > 0 } {
	    foreach key $activeChannels {
		$channelMap($key) _hideAway
	    }
	}
	grid remove $awayLabel
    }
    
    ############## Shows GUI element ##############
    method _showAway {} {
	if { [string length $server] > 0 } {
	    foreach key $activeChannels {
		$channelMap($key) _showAway
	    }
	}
	grid $awayLabel
    }
    
     ############## Toggles away status ##############
    method toggleAway {} {
	set reason [$awayLabel cget -text]
	# Is away, come back
	if {[regexp {^\(Away: (.+)\)} $reason -> reason]} {
	    performSpecialCase "away" $self
	# Is back, go away
	} else {
	    performSpecialCase "away $Pref::defaultAway" $self
	}
    }
    
    
    
    method showProperties {} {
	if { [string length $server] > 0 } {
	    puts $CreationTime
	    puts $ChannelPrefixes
	    puts $NickPrefixes
	    puts $NetworkName
	    puts $ServerName
	    puts $ServerDaemon
	} else {
	    puts $Topic
	    puts $TopicTime
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
    
    
    method compareNick {a b} {
	set av 10
	set bv 10
	set a0 [lindex $a 0]
	set b0 [lindex $b 0]
	
	
	# Determine if either start with a special symbol
	if {[regexp "^\[[myvar NickPrefixes]\].*" $a0]} {
	    set av [string first [string index $a0 0] [myvar NickPrefixes] ]
	}
	if {[regexp "^\[[myvar NickPrefixes]\].*" $b0]} {
	    set bv [string first [string index $b0 0] [myvar NickPrefixes] ]
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
}
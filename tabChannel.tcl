snit::type tabChannel {
    # BOTH
    variable id_var
    # UI Controls
    variable chat
    variable input
    variable nickList
    variable awayLabel
    variable nicklistCtrl
    
    # SPECIFIC
    variable ServerRef	;# tabServer Reference
    variable channel
    
    # Channel info
    variable Topic
    variable TopicTime
    variable TopicAuthor
    variable ModeList
    variable BanList
    

    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Similar (same name)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    ############## Constructor ##############
    # args = tab::server #jupiterbroadcasting pass    
    constructor {args} {
	# If it has no args it's a dummy tab for measurement
	if { [string length $args] > 0 } {
	    $self init [lindex $args 0] [lindex $args 1] [lindex $args 2]
	} else {
	    set channel Temp
	    set id_var measure_tab
	}
	
	$self init_ui
	
	if { [string length $args] > 0 } {
	    $self initChan [lindex $args 2]
	}
    }
    
    ############## Initialize the variables ##############
    method init {arg0 arg1 arg2} {
	set nickList [list]
	set activeChannels [list]
	
	debug "~~~~~~~~~~NEW TAB~~~~~~~~~~~~~~"
	
	set ServerRef $arg0
	set channel $arg1
	set temp [$ServerRef getServer]
	set id_var [concat $temp " " $channel]
	debug "  Channel: $channel"
    }
    
    ############## GUI stuff ##############
    method init_ui {} {
	variable name
	set name $channel
	
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
	set nicklistPanedWindow [PanedWindow $topf.pw -side top]
	set pane  [$nicklistPanedWindow add -minsize 100]
	set nicklistScrolledWindow [ScrolledWindow $pane.sw]
	set nicklistCtrl [listbox $nicklistScrolledWindow.lb -listvariable [myvar nickList] \
				-height 8 -width 20 -highlightthickness 0]
	
	$nicklistScrolledWindow setwidget $nicklistCtrl
	pack $nicklistScrolledWindow $nicklistPanedWindow -fill both -expand 0 -side right
	bind $nicklistCtrl <Double-1> [mymethod DoubleclickNicklist]
	
	pack $chat -fill both -expand 1
	pack $topf -fill both -expand 1
	
	grid remove $awayLabel
    }
    
    ############## Update the toolbar's statuses ##############
    method updateToolbar {mTarget} {
	set icondir [pwd]/icons
	#Is connected
	if { [string length [$ServerRef getconnDesc] ] > 0 } {
	    #Is connected to this channel
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
    
    ############## checks if a channel is connected ##############
    method isChannelConnected {chann} { return [$ServerRef isChannelConnected $chann] }
    
    ############## Join a Channel ##############
    method joinChan {chan pass} { $ServerRef joinChan $chan $pass }

    ############## Send a Private Message to a user...or maybe channel? ##############    
    method sendPM { mNick mMsg} { $ServerRef sendPM $mNick $mMsg }
    
    ############## getters ##############
    method getChannel {} { return $channel }
    method getChannPrefixes {} { return [$ServerRef getChannPrefixes] }
    method getServer {} { return [$ServerRef getServer] }
    method getNick {} { return [$ServerRef getNick] }
    method getNickPrefixes {} { return [$ServerRef getNickPrefixes] }
    method isServer {} { return 0 }
    
    method propogateMessage {what timestamp title titleStyle msg msgStyle} {
	puts "Propogating message: $what  $title  $msg"
	#if what is NICK, check the nick list
	if {[string equal $what "NICK"]} {
	    regexp {([^ ]+) is now known as (.*)} $msg -> oldNick newNick
	    if {[$self NLedit $oldNick $newNick] != 1 } {
		return
	    }
	}
	if {[string equal $what "MYNICK"]} {
	    regexp {You are now known as (.*)} $msg -> newNick
	    #TODO ^ -sorted
	    $self NLedit $oldNick $newNick
	}
	
	if {[string equal $what "QUIT"]} {
	    regexp {([^ ]+) has quit.* } $msg -> newNick
	    $self NLremove $newNick
	}
	
	$self handleReceived $timestamp $title $titleStyle $msg $msgStyle
    }
    
    
    ############## Internal function ##############
    method _send {str} { $ServerRef _send $str }
    
    ############## Quit the server ##############
    method quit {reason} { $ServerRef quit $reason }
    
    ############## Part a channel ##############
    method part {chann reason} {
	$self _send "PART $chann $reason"
	$self handleReceived [$self getTimestamp] \[PART\] bold "You have left the channel" ""
	
	$ServerRef removeActiveChannel $chann

	set parts [split [$Main::notebook raise] "*"]
	set serv [lindex $parts 0]
	set chan [lindex $parts 1]
	regsub -all "_" $serv "." serv
	$self updateToolbar $chan
    }
    
    ############## Nick has been changed ##############
    method nickChanged {newnick} { $ServerRef nickChanged $newnick }
    
    ############## Used by the server to notify its children that it is away ##############
    method awaySignalServer {reason} { $ServerRef awaySignalServer $reason }
    
    ############## Hides GUI element ##############
    method _hideAwayLabel {} {
	grid remove $awayLabel
    }
    
    ############## Shows GUI element ##############
    method _showAwayLabel {} {
	grid $awayLabel
    }
    
    ############## Toggles away status; for use with the button ##############
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
    
    ############## Show properties dialog ##############
    method showProperties {chann} {
	if { [string length $chann] > 0 } {
	    $channelMap($chann) showProperties ""
	    return
	}
	
	destroy .propDialog
	toplevel .propDialog -padx 10 -pady 10
	wm title .propDialog "Properties"
	wm transient .propDialog .
	wm resizable .propDialog 0 0
    
	label .propDialog.l_topic -text "Topic" -font {-size 16}
	text .propDialog.topic  -width 60 -height 7 -background white
	text .propDialog.topicA -width 29 -height 1 -background white
	text .propDialog.topicT -width 29 -height 1 -background white
	.propDialog.topic insert end $Topic ""
	.propDialog.topic configure -state disabled
	.propDialog.topicA insert end $TopicAuthor ""
	.propDialog.topicA configure -state disabled
	.propDialog.topicT insert end $TopicTime ""
	.propDialog.topicT configure -state disabled
	
	label .propDialog.sep1 -font {-size 16} -text " "
	label .propDialog.l_mode -text "Modes" -font {-size 16}
	listbox .propDialog.mode -listvariable [myvar ModeList] \
				-height 5 -width 25 -highlightthickness 0
				
	label .propDialog.l_bans -text "Bans" -font {-size 16}
	listbox .propDialog.bans \
				-height 5 -width 25 -highlightthickness 0
	
	set banlistnames [array names BanList]
	foreach key $banlistnames {
	    .propDialog.bans insert end $key
	}
	
	grid config .propDialog.l_topic -row 0 -column 0 -sticky "w"
	grid config .propDialog.topic   -row 1 -column 0 -columnspan 2
	grid config .propDialog.topicA  -row 2 -column 0
	grid config .propDialog.topicT  -row 2 -column 1
	
	grid config .propDialog.sep1    -row 3 -column 0 -columnspan 2
	grid config .propDialog.l_mode  -row 4 -column 0 -sticky "w"
	grid config .propDialog.mode    -row 5 -column 0
	grid config .propDialog.l_bans  -row 4 -column 1 -sticky "w"
	grid config .propDialog.bans    -row 5 -column 1
	
	Main::foreground_win .propDialog
	grab release .
	grab set .propDialog
    }
    
    method _setData {newport newnick} {
	$ServerRef _setNick $newport $newnick
    }
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Shared (same)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    method getId {} { return $id_var }
    
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

	# Starts with a backslash
	if [regexp {^/(.+)} $msg -> msg] {
		if { [string index $msg 0] != "/"} {
			if [performSpecialCase $msg $self ] {
				return
			}
		}
	}

	
	set style ""
	
	$self _send "PRIVMSG $channel :$msg"
	$self handleReceived [$self getTimestamp] <[$self getNick]> {bold blu} $msg $style
	
	    #TODO: Scroll only if at bottom
	$chat yview end
    }
    
    method getTimestamp {} {
        return [clock format [clock seconds] -format \[%H:%M\] ]
    }
    
    ############## Clears the chat view ##############
    method clearScrollback {} {
	$chat configure -state normal
	$chat delete 0.0 end
	$chat configure -state disabled
    }
    
    ############## Modifies the message away ##############
    method away {reason } {
	$awayLabel configure -text "(Away: $reason)"
    }
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Specific (this)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    ############## Init Channel ##############
    method initChan {pass} {
	if {[string index $channel 0] == "#"} {
	    set nickList [list]
	    if [info exists Topic] {
		unset Topic
	    }
	    if [info exists TopicTime] {
		unset TopicTime
	    }
	    if [info exists TopicAuthor] {
		unset TopicAuthor
	    }
	    if [info exists ModeList] {
		unset ModeList
	    }
	    if [info exists BanList] {
		unset BanList
	    }
	    
	    $self _send "MODE $channel"
	    $self _send "MODE $channel +b"
	}
    }
    
    
    method setModes {mModes} {
	set result [llength mModes]
	set ModeList [split $mModes {}]
	return $result
    }
    
    ############## NickList functions ##############
    # 1 if it was found, 0 otherwise
    method NLedit {oldNick newNick} {
	set temp [$self getNickPrefixes]
	set ind [lsearch -regexp $nickList "\[$temp\]$oldNick"]
	#TODO ^ -sorted
	if {$ind > -1} {
	    set prefix ""
	    regexp "\(\[$temp\]\)$oldNick" [lindex $nickList $ind] -> prefix
	    lset nickList $ind "$prefix$newNick"
	    set nickList [lsort -command [mymethod compareNick] $nickList]
	    return 1
	} else {
	    return 0
	}
    }
    
    method NLremove {target} {
	set idx [lsearch $nickList $target]
	set nickList [lsort -command [mymethod compareNick] [lreplace $nickList $idx $idx]]
    }
    
    method NLadd {target} {
	set nickList [lsort -command [mymethod compareNick] [linsert $nickList 1 $target]]
    }
    
    ############## BanList functions ##############
    method addBanEntry {mEntry mCreator mTime} {
	set res [array size BanList]
	set BanList($mEntry) "$mCreator $mTime"
	return $res
    }

    ############## Add a batch of users to the nick list ##############
    method addUsers {users} {
	set users [split $users]
	foreach usr $users {
	    lappend nickList $usr
	}
    }
    
    ############## setters ##############
    method setTopic {newTopic} { set Topic $newTopic }
    method setTopicInfo {author time} {
	set TopicTime [clock format $time]
	set TopicAuthor $author
    }
    
    ############## Sort the nick list ##############
    method sortUsers {} {
	set nickList [lsort -command [mymethod compareNick] $nickList]
    }
    
    ############## Gui Event ##############
    method DoubleclickNicklist {} {
	set nickName [$nicklistCtrl get [$nicklistCtrl curselection] ]
	puts $nickName
	$self createPMTabIfNotExist $nickName
    }
    
    ############## Comparator for NickList ##############
    method compareNick {a b} {
	set av 100
	set bv 100
	set a0 [lindex $a 0]
	set b0 [lindex $b 0]
	
	# Determine if either start with a special symbol
	if {[regexp "^\[[$self getNickPrefixes]\].*" $a0]} {
	    set av [string first [string index $a0 0] [$self getNickPrefixes] ]
	}
	if {[regexp "^\[[$self getNickPrefixes]\].*" $b0]} {
	    set bv [string first [string index $b0 0] [$self getNickPrefixes] ]
	}
	

	# If they are the same class (e.g. both ops OR both normal (10))
	if {$av == $bv } {
	    return [string compare -nocase $a $b]
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
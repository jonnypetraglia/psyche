snit::type tabChannel {
    # BOTH
    variable id_var
    # UI Controls
    variable chat
    variable scroll
    variable scrollNick
    variable input
    variable nickList
    variable awayLabel
    variable nicklistCtrl
    # Other
    variable sendHistory
    variable sendHistoryIndex
    variable logDesc
    variable lastSearchIndex
    variable lastSearchTerm
    variable lastSearchSwitches
    variable lastSearchDirection
    
    # SPECIFIC
    variable ServerRef	;# tabServer Reference
    variable channel
    variable tabCompleteData
    variable tabCompleteIndex
    
    # Channel info
    variable Topic
    variable TopicTime
    variable TopicAuthor
    variable ModeList
    variable BanList
    
    variable SpecialUsers
    variable LastSpoke
    variable LastTabbed
    variable NickSearchTerm
    

    
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
            set sendHistory [list ""]
            set sendHistoryIndex 0
        
        $self init_ui
        if { [string length $args] > 0 } {
            if {$Pref::logEnabled} {
                $self createLog
            }
            $self initChan [lindex $args 2]
        }
    }
    
    ############## Initialize the variables ##############
    method init {arg0 arg1 arg2} {
        set nickList [list]
        set activeChannels [list]
        
        Log D "~~~~~~~~~~NEW TAB~~~~~~~~~~~~~~"
        
        set ServerRef $arg0
        set channel $arg1
        set temp [$ServerRef getServer]
        set id_var "${temp}__${channel}"
        Log D "  Channel: $channel"
    }
    
    ############## GUI stuff ##############
    method init_ui {} {
        variable name
        set name $channel
        
        regsub -all "\\." $id_var "_" id_var
        #regsub -all " " $id_var "__" id_var
        
        # Magic bullshit
        set frame [$Main::notebook insert end $id_var -text $name -image [image create photo -file "[pwdW]/icons/x.gif"] -raisecmd Main::pressTab]
        set_close_bindings $Main::notebook $id_var
        set topf  [frame $frame.topf]
        
        # Create the chat text widget
        set chat [text $topf.chat -height 20 -wrap word -font {Arial 11} -undo true]
        $chat tag config bold   -font [linsert [$chat cget -font] end bold]
        $chat tag config italic -font [linsert [$chat cget -font] end italic]
        $chat tag config timestamp -font {Arial 7} -foreground grey60
        $chat tag config blue   -foreground blue
        $chat tag config mention   -foreground red
        $chat configure -background white
        $chat configure -state disabled
        $chat tag configure regionSearch -background yellow
        set scroll [xscrollbar $topf.sbar -orient vertical -command "$chat yview"]
        $chat conf -yscrollcommand "$scroll set"
        for {set i 0} {$i < [llength $Main::nick_colors]} {incr i} {
            $chat tag config "nick_color$i" -foreground [lindex $Main::nick_colors $i]
        }
        
        set lowerFrame [frame $topf.f]
        
        # Create the away label
        set awayLabel [xlabel $lowerFrame.l_away -text ""]
        
        # Create the input widget
        set input [text $lowerFrame.input -height 1 -undo true]
        $input configure -background white
        bind $input <Return> "[mymethod hitSendKey]; break;"
        bind $input <Up> "[mymethod upDown] -1; break;"
        bind $input <Down> "[mymethod upDown] 1; break;"
        bind $input <Tab> "[mymethod tabCompleteBegin]; break;"
        bind $input <KeyPress> "[mymethod tabCompleteCancel] %K"
    
        grid $awayLabel -row 0 -column 0
        grid $input -row 0 -column 1 -sticky ew
        grid columnconfigure $lowerFrame 1 -weight 1
        pack $lowerFrame -side bottom -fill x
    
        # Create the nicklist widget
        if {![$self isPM]} {
            set nicklistCtrl [listbox $topf.lb -listvariable [myvar nickList] \
                        -height 8 -width 20 -highlightthickness 0]
            
            bind $nicklistCtrl <Double-1> [mymethod DoubleclickNicklist]
            bind $nicklistCtrl <ButtonRelease-$Main::MIDDLE_CLICK> "event generate $nicklistCtrl <1> -x %x -y %y; [mymethod RightclickNicklist] %x %y"
            set scrollNick [xscrollbar $topf.sbar2 -orient vertical -command "$nicklistCtrl yview"]
            $nicklistCtrl conf -yscrollcommand "$scrollNick set"
            
            pack $scrollNick -fill both -expand 0 -side right
            pack $nicklistCtrl -fill both -expand 0 -side right
        }
        
        pack $scroll -fill both -expand 0 -side right
        pack $chat -fill both -expand 1
        pack $topf -fill both -expand 1
        
        grid remove $awayLabel
    }
    
    ############## Update the toolbar's statuses ##############
    method updateToolbar {mTarget} {
        $Main::toolbar_find configure -state normal
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
        Log D "Propogating message: $what  $title  $msg"
        switch $what {
            "NICK" {
                # If it is not in the nickList, no need to propogate it here
                regexp {([^ ]+) is now known as (.*)} $msg -> oldNick newNick
                if {[$self NLrename $oldNick $newNick] != 1 } {
                    return
                }
            }
            "MYNICK" {
                regexp {You are now known as (.*)} $msg -> newNick
                catch {$self NLrename $nick $newNick}
                #TODO
            }
            "QUIT" {
                regexp {([^ ]+) has quit.* } $msg -> newNick
                $self NLremove $newNick
            }
        }
        
        $self handleReceived $timestamp $title $titleStyle $msg $msgStyle
    }
    
    
    ############## Internal function ##############
    method _send {str} { $ServerRef _send $str }
    
    ############## Quit the server ##############
    method quit {reason} { $ServerRef quit $reason }
    
    ############## Part a channel ##############
    method part {chann reason} {
        $ServerRef part $chann $reason
        return
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
        destroy .propDialog
        toplevel .propDialog -padx 10 -pady 10
        wm title .propDialog "Properties"
        wm transient .propDialog .
        wm resizable .propDialog 0 0
        
        xlabel .propDialog.l_topic -text "Topic" -font {-size 16}
        text .propDialog.topic  -width 60 -height 7 -background white -undo true
        text .propDialog.topicA -width 29 -height 1 -background white -undo true
        text .propDialog.topicT -width 29 -height 1 -background white -undo true
        .propDialog.topic insert end $Topic ""
        .propDialog.topic configure -state disabled
        .propDialog.topicA insert end $TopicAuthor ""
        .propDialog.topicA configure -state disabled
        .propDialog.topicT insert end $TopicTime ""
        .propDialog.topicT configure -state disabled
        
        xlabel .propDialog.sep1 -font {-size 16} -text " "
        xlabel .propDialog.l_mode -text "Modes" -font {-size 16}
        listbox .propDialog.mode -listvariable [myvar ModeList] \
                    -height 5 -width 25 -highlightthickness 0
                    
        xlabel .propDialog.l_bans -text "Bans" -font {-size 16}
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
        catch {grab release .}
        catch {grab set .propDialog}
    }
        
    method _setData {newport newnick} {
        $ServerRef _setNick $newport $newnick
    }
    
    ############## Issued when calling find ##############
    method find {direction switches val} {
        $self findClear
        if { (![info exists lastSearchTerm] || ([info exists lastSearchTerm] && $lastSearchTerm != $val)) || \
             (![info exists lastSearchSwitches] || ([info exists lastSearchSwitches] && $lastSearchSwitches != $switches))} {
            set lastSearchIndex 1.0
            set lastSearchTerm $val
            set lastSearchSwitches $switches
        } else {
            if {$lastSearchIndex < 1 } {
                set lastSearchIndex 1.0
            }
        }
        set lastSearchDirection $direction
        $self findNext
    }

    method findNext {} {
        variable lastSearchLength
        set offsetFromLast "+1c"
        if {$lastSearchDirection == "-backwards"} {
            set offsetFromLast "-1c"
        }
        if {![info exists lastSearchTerm]} {
            return
        }
        $self findClear
        set loc ""
        catch {
            set evalString "$chat search -count lastSearchLength $lastSearchDirection $lastSearchSwitches -- \"$lastSearchTerm\" \"$lastSearchIndex$offsetFromLast\""
            set loc [eval $evalString]
        }
        if { $loc == "" } {
            set lastSearchIndex 1.0
            return
        }
        set lastSearchIndex $loc
    
        $chat see $lastSearchIndex
        $chat tag add regionSearch $lastSearchIndex "$lastSearchIndex+${lastSearchLength}c"
        set lastSearchIndex "$lastSearchIndex"
    }
    
    method findMarkAll {switches val} {
        variable locLen
        $self findClear
        
        set lastFind -1
        set evalString "$chat search -count locLen $switches -- \"$var\" 1.0"
        set loc [eval $evalString]
        while {$loc > $lastFind && $loc != ""} {
            $chat tag add regionSearch $loc "$loc+${locLen}c"
            set lastFind $loc
            set evalString "$chat search -count locLen $switches -- \"$var\" \"$loc+1c\""
            set loc [eval $evalString]
        }
    }
    
    method resetMentionColor {} {
        $chat tag config mention   -foreground $Pref::mentionColor
    }
    
    source "_shared.tcl"
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Specific (this)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    ############## Send Message ##############
    method sendMessage {msg} {
        #sendHistory
        set sendHistoryIndex [expr {[llength $sendHistory] - 1}]
        lset sendHistory $sendHistoryIndex $msg
        if {[llength $sendHistory] > $Pref::maxSendHistory} {
            set sendHistory [lreplace $sendHistory 0 0]
        }
        lappend sendHistory ""
        set sendHistoryIndex [expr {[llength $sendHistory] -1}]

        # Starts with a backslash
        if [regexp {^/(.+)} $msg -> msg] {
            if { [string index $msg 0] != "/"} {
                if {![performSpecialCase $msg $self ]} {
                    $ServerRef _send $msg
                    $ServerRef handleReceived [$self getTimestamp] \[Raw\] {bold blue} $msg ""
                }
                return
            }
        }
        
        $self _send "PRIVMSG $channel :$msg"
        $self handleReceived [$self getTimestamp] <[$self getNick]> {bold blue} $msg ""
        
        #TODO: Scroll only if at bottom
        $chat yview end
    }
    
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
    
    ############## Update the specific Away button ##############
    method updateToolbarAway {} {
        set reason [$awayLabel cget -text]
        if {[regexp {^\(Away: (.+)\)} $reason -> reason]} {
            $Main::toolbar_away configure -image [image create photo -file $About::icondir/back.gif] -helptext "Back"
        } else {
            $Main::toolbar_away configure -image [image create photo -file $About::icondir/away.gif] -helptext "Away"
        }
    }
    
    
    method setModes {mModes} {
        set result [llength mModes]
        set ModeList [split $mModes {}]
        return $result
    }
    
    ############## NickList functions ##############
    # 1 if it was in the nicklist, 0 if not
    method NLrename {oldNick newNick} {
        # Iterate over mode lists looking for nick
        set modes [split [$ServerRef getNickPrefixes] {}]
        foreach m $modes {
            # Create list if not exist
            if {![info exists SpecialUsers($m)]} { set SpecialUsers($m) [list] }
            
            # If it's found, replace it with the new one
            set idx [lsearch $SpecialUsers($m) $oldNick]
            if {$idx > -1} {
                set SpecialUsers($m) [lreplace $SpecialUsers($m) $idx $idx $oldNick]
            }
        }
        return [$self _NLchangeTheNickAndOrUpdateItsMode $oldNick $newNick]
    }
    
    # Essentially the same as NLrename; just had to tweak it to not try to handle the mode
    method NLchmod {theNick modeToSet setOrUnset} {
        # Create list if not exist
        if {![info exists SpecialUsers($modeToSet)]} { set SpecialUsers($modeToSet) [list] }
        
        switch $setOrUnset {
            "+" {
                lappend SpecialUsers($modeToSet) $theNick
            }
            "-" {
                set idx [lsearch $SpecialUsers($modeToSet) $theNick]
                set SpecialUsers($modeToSet) [lreplace $SpecialUsers($modeToSet) $idx $idx]
            }
        }
        $self _NLchangeTheNickAndOrUpdateItsMode $theNick $theNick
    }
    
    # 1 if it was in the nicklist, 0 if not
    method _NLchangeTheNickAndOrUpdateItsMode {oldNick newNick} {
        # Look through the modes -from most important to least- checking the lists
        set modes [split [$ServerRef getNickPrefixes] {}]
        foreach m $modes {
            # Create list if not exist
            if {![info exists SpecialUsers($m)]} { set SpecialUsers($m) [list] }
            
            # Found!
            if {[lsearch $SpecialUsers($m) $oldNick] != -1} {
                # Find last nick, even if it has a different prefix
                set temp [$self getNickPrefixes]
                # Now find it in the NickList
                set ind [lsearch -regexp $nickList "^\[$temp\]?$oldNick\$"]
                if {$ind > -1} {
                    lset nickList $ind "$m$newNick"
                    set nickList [lsort -command [mymethod compareNick] $nickList]
                    return 1
                } else {
                    Log E "_NLchangeTheNickAndOrUpdateItsMode - Found $oldNick inst SpecialUsers($m), but not in the nickList"
                }
                return 0
            }
        }
        
        # No modes
        set temp [$self getNickPrefixes]
        set ind [lsearch -regexp $nickList "^\[$temp\]?$oldNick\$"]
        if {$ind > -1} {
            lset nickList $ind "$newNick"
            set nickList [lsort -command [mymethod compareNick] $nickList]
            return 1
        }
        return 0
    }
    
    method NLremove {target} {
        set idx [lsearch $nickList $target]
        set nickList [lsort -command [mymethod compareNick] [lreplace $nickList $idx $idx]]
        if [info exists LastSpoke($target)] { unset LastSpoke($target) }
        
        # Remove from modes list
        set modes [split [$ServerRef getNickPrefixes] {}]
        foreach m $modes {
            # Create list if not exist
            if {![info exists SpecialUsers($m)]} { set SpecialUsers($m) [list] }
            
            set idx [lsearch $SpecialUsers($m) $target]
            if {$idx > -1} {
                set SpecialUsers($m) [lreplace $SpecialUsers($m) $idx $idx]
            }
        }
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
            # If it's a special user add it
            set temp [$self getNickPrefixes]
            Log V "Adding User: $usr   looking for ^(\[$temp\])(.*)"
            if {[regexp "^(\[$temp\])(.*)" $usr -> mod usr]} {
                lappend nickList $usr
                $self NLchmod $usr $mod "+"
            } else {
                lappend nickList $usr
            }
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
        if {[$ServerRef isChannelConnected $channel]} {
            set nickName [$nicklistCtrl get [$nicklistCtrl curselection] ]
            $ServerRef createPMTabIfNotExist $nickName
        }
    }
    
    ############## Gui Event ##############
    method RightclickNicklist {x y} {
        if {[$ServerRef isChannelConnected $channel]} {
            set Main::NLnick [$self getSelectedNick]
            .nicklistMenu entryconfigure 0 -label "PM $Main::NLnick"
            set x [expr [winfo rootx $nicklistCtrl] + $x]
            set y [expr [winfo rooty $nicklistCtrl] + $y]
            tk_popup .nicklistMenu $x $y
        }
    }
    
    method touchLastSpoke {nick} {
        set LastSpoke($nick) [clock milliseconds]
    }
    
    method tabCompleteBegin {} {
        # Initiate data
        set tabCompleteData [list]
        set tabCompleteIndex 0
        # Extract thing we are looking for & get the indices
        regexp ".*\\.(.*)" [$input index {insert + 0 c}] -> insert_ind
        set nickSearchTerm [$input get 1.0 1.$insert_ind]
        set begin_ind [expr {[string last " " $nickSearchTerm $insert_ind] + 1}]
        set nickSearchTerm [string range $nickSearchTerm $begin_ind end]
        set ind [lsearch -regexp -nocase $nickList "^\[[$ServerRef getNickPrefixes]\]?$nickSearchTerm.*"]
        while {$ind > -1} {
            set theNick [lindex $nickList $ind]
            regexp "^\[[$self getNickPrefixes]\](.*)" $theNick -> theNick
            if [info exists LastSpoke($theNick)] {
                lappend tabCompleteData [list $theNick $LastSpoke($theNick)]
            } else {
                lappend tabCompleteData [list $theNick 0]
            }
            incr ind
            set ind [lsearch -start $ind -regexp -nocase $nickList "^\[[$ServerRef getNickPrefixes]\]?$nickSearchTerm.*"]
        }
        if {[llength $tabCompleteData] == 0} { return }
        
        #lsort by 2nd column first, then 1st column
        set tabCompleteData [lsort -command [mymethod compareTabComplete] $tabCompleteData]
        
        $input replace 1.$begin_ind 1.$insert_ind "[lindex [lindex $tabCompleteData $tabCompleteIndex] 0], "
        
        bind $input <Tab> "[mymethod tabCompleteNext]; break;"
    }
    
    method tabCompleteNext {} {
        regexp ".*\\.(.*)" [$input index {insert + 0 c}] -> insert_ind
        set oldNickLength [string length [lindex [lindex $tabCompleteData $tabCompleteIndex] 0]]
        set begin_ind [expr {$insert_ind - $oldNickLength - 2}]
        incr tabCompleteIndex
        if {$tabCompleteIndex >= [llength $tabCompleteData]} { set tabCompleteIndex 0}
        $input replace 1.$begin_ind 1.$insert_ind "[lindex [lindex $tabCompleteData $tabCompleteIndex] 0], "
    }
    
    method tabCompleteCancel {arg} {
        bind $input <Tab> "[mymethod tabCompleteBegin]; break;"
    }
    
    ############## Comparator for Nick Completion ##############
    method compareTabComplete {a b} {
        set timeA [lindex $a 1]
        set timeB [lindex $b 1]
        if {$timeA == $timeB} {
            return [$self compareNick [lindex $a 0] [lindex $b 0]]
        }
        if {$timeA < $timeB} { return  1 }
        if {$timeA > $timeB} { return -1 }
        return 0
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
        }
        if {$av < $bv} { return -1 }
        if {$av > $bv} { return 1 }
        return 0
    }
    
    method requestBan {thenick bantype shouldkick banmsg} {
        $ServerRef requestBan $thenick $channel $bantype $shouldkick $banmsg
    }
    
    method getSelectedNick {} {
        set theNick [$nicklistCtrl get [$nicklistCtrl curselection] ]
        regexp "^\[[$self getNickPrefixes]\](.*)" $theNick -> theNick
        return $theNick
    }
    
    method isPM {} {
        return [regexp -- "^\[[$ServerRef getChannelPrefixes]\].+" $channel]
    }
}
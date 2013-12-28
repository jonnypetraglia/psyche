    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Shared (same)~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
    method getId {} { return $id_var }
    
    method findClear {} {
        $chat tag remove regionSearch 1.0 end
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
        
        set beginning [$chat index [list end - 1 lines]]
        $chat configure -state normal
        $chat insert end $timestamp\  timestamp
        $chat insert end $title\  $style1
        $chat insert end $message\n $style2
        
        set msgStart [expr {[string length $timestamp] + [string length $title] + 2}]
        
        # Aw yiss. Mother. Fucking. Hyperlinks.
        set linkRegex {(http|https|ftp)\://([a-zA-Z0-9\.\-]+(\:[a-zA-Z0-9\.&amp;%\$\-]+)*@)*((25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])|localhost|([a-zA-Z0-9\-]+\.)*[a-zA-Z0-9\-]+\.(com|edu|gov|int|mil|net|org|biz|arpa|info|name|pro|aero|coop|museum|[a-zA-Z]{2}))(\:[0-9]+)*(/($|[a-zA-Z0-9\.\,\?\'\\\+&amp;%\$#\=~_\-]+))*}
            # ^ via http://stackoverflow.com/questions/3726807/regex-expression-for-valid-website-link
        set lastMatchInd 0
        # helped a ton by https://gist.github.com/marvin/4130284
        while {[regexp -start $lastMatchInd -indices -- $linkRegex $message location]} {
            set urlStart [$chat index [list $beginning + [expr {[lindex $location 0] + $msgStart}] chars]]
            set urlEnd   [$chat index [list $beginning + [expr {[lindex $location 1] + $msgStart + 1}] chars]]
            set url [$chat get $urlStart $urlEnd]
            set tagname "${id_var}[clock milliseconds]"
            $chat tag add $tagname $urlStart $urlEnd
            $chat tag configure $tagname -underline true
            $chat tag configure $tagname -foreground blue
            $chat tag bind      $tagname "<Enter>" "$chat configure -cursor $Main::cursor_link"
            $chat tag bind      $tagname "<Leave>" "$chat configure -cursor arrow"
            $chat tag bind      $tagname "<Button-1>" "platformOpen $url"
            
            set lastMatchInd [lindex $location 1] 
        }
        
        # Bold
        while {[regexp -indices -- "" $message locationA]} {
            set locationA [lindex $locationA 0]
            set message [string replace $message $locationA $locationA ""]
            $chat delete [$chat index [list $beginning + [expr {$locationA + $msgStart}] chars]] \
                         [$chat index [list $beginning + [expr {$locationA + $msgStart + 1}] chars]]
            if {[regexp -indices -- "" $message locationB]} {
                set locationB [lindex $locationB 0]
                set message [string replace $message $locationB $locationB ""]
                $chat delete       [$chat index [list $beginning + [expr {$locationB + $msgStart}] chars]] \
                                   [$chat index [list $beginning + [expr {$locationB + $msgStart + 1}] chars]]
                Log WTF "[$chat get [$chat index [list $beginning + [expr {$locationB + $msgStart}] chars]]   [$chat index [list $beginning + [expr {$locationB + $msgStart + 1}] chars]]]"
                Log WTF [$chat get $beginning end]
                $chat tag add bold [$chat index [list $beginning + [expr {$locationA + $msgStart}] chars]] \
                                   [$chat index [list $beginning + [expr {$locationB + $msgStart}] chars]]
            }
        }
        # Italic
        while {[regexp -indices -- "" $message locationA]} {
            set locationA [lindex $locationA 0]
            set message [string replace $message $locationA $locationA ""]
            $chat delete [$chat index [list $beginning + [expr {$locationA + $msgStart}] chars]] \
                         [$chat index [list $beginning + [expr {$locationA + $msgStart + 1}] chars]]
            if {[regexp -indices -- "" $message locationB]} {
                set locationB [lindex $locationB 0]
                set message [string replace $message $locationB $locationB ""]
                $chat delete       [$chat index [list $beginning + [expr {$locationB + $msgStart}] chars]] \
                                   [$chat index [list $beginning + [expr {$locationB + $msgStart + 1}] chars]]
                Log WTF "[$chat get [$chat index [list $beginning + [expr {$locationB + $msgStart}] chars]]   [$chat index [list $beginning + [expr {$locationB + $msgStart + 1}] chars]]]"
                Log WTF [$chat get $beginning end]
                $chat tag add italic [$chat index [list $beginning + [expr {$locationA + $msgStart}] chars]] \
                                     [$chat index [list $beginning + [expr {$locationB + $msgStart}] chars]]
            }
        }
        
        # the original example (on the interwebs) used -1; -2 is for the trailing newline?
        if {[expr [lindex [split [$chat index end] .] 0] -2] > $Pref::maxScrollback} {
            $chat delete 1.0 2.0
            if {[info exists logDesc]} {
                if {[info exists lastSearchIndex]} {
                    set lastSearchIndex [expr {$lastSearchIndex -1}]
                } else {
                    set lastSearchIndex 1.0
                }
            } else {
                set lastSearchIndex 1.0
            }
        }
        $chat configure -state disabled
        
        if {$isAtBottom==1.0} {
            $chat yview end
        }
        if {$Pref::logEnabled} {
            set timestamp [clock format [clock seconds] -format "\[%A, %B %d, %Y\] \[%I:%M:%S %p\]"]
            puts $logDesc "$timestamp $title $message"
            flush $logDesc
        }
    }
    
    ############## Creates the logDesc ##############
    method createLog {} {
        file mkdir $Pref::logDir
        set logDesc [open "$Pref::logDir/$id_var.log" a+]
        Log D "Creating log:  $Pref::logDir/$id_var.log      $logDesc"
    }
    
    ############## Closes the log handle ##############
    method closeLog {} {
        if {[info exists logDesc] && [string length $logDesc] > 0 } {
            close $logDesc
        }
    }
    
    ############## When enter key is pressed ##############
    method hitSendKey {} {
        set msg [$input get 1.0 end-1c]
        $input delete 1.0 end
        $self sendMessage $msg
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
    
    ############## Notify user of a mention ##############
    method notifyMention {mNick mMsg} {
        if {[string length [focus]] > 0 && [$Main::notebook raise] == $id_var} {
            return
        }
        ::notebox::addmsg "$mNick - $mMsg"
        $Main::notebook itemconfigure $id_var -background $Pref::mentionColor
        if {[string length $Pref::mentionSound] > 0 } {
            playSound $Pref::mentionSound
        }
    }
    
    ############## Handles pressing of the up down buttons for send history ###############
    ## direction == -1 for prior (up), +1 for next (down)
    method upDown {direction} {
        set newSHindex [expr {$sendHistoryIndex + $direction}]
        if { $newSHindex < 0 || $newSHindex > $Pref::maxSendHistory || $newSHindex >= [llength $sendHistory]} { return }

        # Save old one
        set msg [$input get 1.0 end-1c]
        #set msg [string range $msg 0 [expr {[string length $msg]-2}]]
        lset sendHistory $sendHistoryIndex $msg

        # Retrieve new one
        set sendHistoryIndex $newSHindex
        $input replace 1.0 end [lindex $sendHistory $sendHistoryIndex]
    }
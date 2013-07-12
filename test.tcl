package require Tk

variable nickList
set nickList [list byteslol notbryant notbyteslol Techman]

variable LastSpoke
variable LastTabbed
variable NickSearchTerm

proc getNickPrefixes {} { return "~" }
proc debug {ARGS} { puts $ARGS }

set input [text .input -height 1]
.input insert end not ""
pack .input


proc _tabComplete {nickloc txt earlierThan {leNickPrefix ""}} {
    global nickList
    set i [expr {$nickloc + 1}]
    while {[regexp "^$leNickPrefix$txt.*" [lindex $nickList $i]]} {
        # The iterating-one over must have spoken at least once
        if {![info exists LastSpoke([lindex $nickList $i])]} {
            incr i; continue;
        }
        
        # If the iterating-one HAS spoken but the nickloc (i.e., the alphanumerical first) has not,
        # default to the iterating-one
        # OR if they both exist, actually compare
        if {![info exists LastSpoke([lindex $nickList $nickloc])] || \
            ($LastSpoke([lindex $nickList $i]) > $LastSpoke([lindex $nickList $nickloc]) &&
             $LastSpoke([lindex $nickList $i]) < $earlierThan)} {
            # DEBUG
            if [info exists LastSpoke([lindex $nickList $nickloc])] {
                debug "   [lindex $nickList $i] @ $LastSpoke([lindex $nickList $i]) < [lindex $nickList $nickloc] @ $LastSpoke([lindex $nickList $nickloc])" }
            # GUBED
            set nickloc $i
        }
        incr i
    }
    return $nickloc
}




bind .input <Tab> {
    global nickList
    regexp ".*\\.(.*)" [$input index {insert + 0 c}] -> ind
    set ind [expr {$ind - 1}]
    set tempNickSearchTerm [$input get 1.0 end]
    set ind0 [expr {[string last " " $tempNickSearchTerm $ind] + 1}]
    
    if {![info exists LastTabbed]} {
        set NickSearchTerm [string range $tempNickSearchTerm $ind0 $ind]
    }
    debug "Looking for nick that starts with: '$NickSearchTerm'"
    
    
    
    
    set earlierThan 9999999999
    if {[info exists LastTabbed] && [info exists LastSpoke($LastTabbed)]} {
        set earlierThan $LastSpoke($LastTabbed)
    }
    
    debug "Must be earlier than $earlierThan"
    
    set nickloc [lsearch -regexp $nickList "^$NickSearchTerm.*"]
    # If there is a prior tabbed, make sure our starting point is not it
    if {[info exists LastTabbed] && [lindex $nickList $nickloc]==$LastTabbed} { ;#&& [info exists LastSpoke($LastTabbed)]
        incr nickloc
        # If the starting point WAS the Last Tabbed AND it was the only one, invalidate the normal nicks
        if {![regexp "^$NickSearchTerm.*" [lindex $nickList $nickloc]]} {
            set nickloc -1
        }
    }
    debug "Checking normal. Starting point is $nickloc"
    debug "  [lindex $nickList $nickloc]"
    
    # Check normal nicks, if there are any
    if {$nickloc > -1} {
        set tempnickloc [_tabComplete $nickloc $NickSearchTerm $earlierThan]
        if {$tempnickloc > $nickloc} {
            set nickloc $tempnickloc
        }
    }
    
    debug "Post post - $nickloc"
    debug "Post post - [lindex $nickList $nickloc]"
    
    # Do mods and such
    set modes [split [getNickPrefixes] {}]
    foreach m $modes {
        set tempnickloc [lsearch -regexp $nickList "^$NickSearchTerm.*"]
        if {$tempnickloc < 0} { continue }
        set tempnickloc [_tabComplete $nickloc $NickSearchTerm $earlierThan "\[[getNickPrefixes]\]" ]
        if {$tempnickloc > $nickloc} {
            set nickloc $tempnickloc
        }
    }
    
    # Regular
    debug "Post modes - $nickloc"
    debug "Post modes - [lindex $nickList $nickloc]"
    
    
    set LastTabbed [lindex $nickList $nickloc]
    $input replace 1.$ind0 1.[expr {$ind+1}] $LastTabbed
    #set LastSpoke($LastTabbed) 5
    
    break
}



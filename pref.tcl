package require BWidget

namespace eval Pref {
    variable configDir
    set configDir $::env(HOME)

    variable timeout
    variable raiseNewTabs
    variable defaultQuit
    variable defaultBan
    variable defaultPart
    variable defaultAway
    variable bookmarks

    set timeout 5000
    set raiseNewTabs false
    set defaultQuit "Quittin'"
    set defaultBan "Please stop that"
    set defaultPart "Partin'"
    set defaultAway "I'm away"
    
    
    #This is for debug
    set prefFile [pwd]/test.cfg
}


proc Pref::readPrefs {} {
    if {[file exists $Pref::prefFile]} {
	set fp [open $Pref::prefFile r]
    } else {
	return 0
    }
    
    while {![eof $fp]} {
	set data [gets $fp]
	if {[lindex $data 0] == "#"} {
	    continue
	}
	# restore some other values that might be useful
	#set config([lindex $data 0]) [lindex $data 1]
	if [regexp {([^=]+)=(.*)} $data -> key val] {
	    if [regexp {\{(.*)\}} $val -> val] {
		set val "\[list $val \]"
	    }
# 		puts "set [subst Pref::$key] $val"

	    if {[catch {eval "set [subst Pref::$key] $val"}]} {
		puts "ERROR: Unable to load preference: '$key'"
	    }
	}
    }
    close $fp
    
    menu .bookmarkMenu -tearoff true -title Bookmarks
    foreach x [array names Pref::bookmarks] {
	puts "PREF: $x"
	.bookmarkMenu add command -label $x -command "Main::openBookmark $x"
    }

    return 1
}

proc Pref::writePrefs {pref val} {

}

#Pref::readPrefs
package require BWidget

namespace eval Pref {
    variable configDir
    #NOT a preference; for reference
    set CONFIG_DIR $::env(HOME)/.psyche

    variable timeout
    variable raiseNewTabs
    variable defaultQuit
    variable defaultBan
    variable defaultKick
    variable defaultPart
    variable defaultAway
    variable bookmarks
    variable logEnabled
    variable logDir
    variable popupTimeout
    variable popupLocation
    variable popupFont
    # (n|s)(e|w)   OR   999x999 for absolute path
    variable maxSendHistory
    variable maxScrollback	;#TODO
    variable mentionColor
    variable mentionSound
    

    set timeout 5000
    set raiseNewTabs false
    set defaultQuit "Quittin'"
    set defaultKick "Please stop that"
    set defaultBan "Stop. That."
    set defaultPart "Partin'"
    set defaultAway "I'm away"
    set logEnabled false
    set logDir "$CONFIG_DIR\\log"
    set popupTimeout 5000
    set popupFont {Helvetica 16}
    switch $::this(platform) {
        "windows" {
            set popupLocation se
        }
        default {
            set popupLocation ne
        }
    }
    
    set maxSendHistory 50
    set maxScrollback 200
    
    set mentionColor "LightGreen" ;#PaleGreen, PaleGreen3
    set mentionSound "[pwd]/mention.wav"
    
    
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
        # Manually add the namespace
        if {[regexp "^set ((timeout |raiseNewTabs |defaultQuit |defaultBan |defaultKick |defaultPart |defaultAway |bookmarks\\(.*\\)|logEnabled |logDir |popupTimeout |popupLocation |popupFont |maxSendHistory |maxScrollback |mentionSound |mentionColor ).*)" $data -> data]} {
            set data "set Pref::$data"
        }
        puts "Reading preference: '$data'"

        if {[catch {eval "$data"} prob]} {
            puts "ERROR: Unable to load preference: '$data"
        }
    }
    close $fp
    
    menu .bookmarkMenu -tearoff true -title Bookmarks
    set derp [lreverse [array names Pref::bookmarks]]
    foreach x $derp {
        .bookmarkMenu add command -label $x -command "Main::openBookmark $x"
    }

    return 1
}

proc Pref::writePrefs {pref val} {

}


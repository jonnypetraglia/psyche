package require BWidget

namespace eval Pref {
    #NOT a preference; for reference
    set CONFIG_DIR ~/.psyche

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
    variable toolbarHidden
    

    set timeout 5000
    set raiseNewTabs false
    set defaultQuit "Quittin'"
    set defaultKick "Please stop that"
    set defaultBan "Stop. That."
    set defaultPart "Partin'"
    set defaultAway "I'm away"
    set logEnabled false
    set logDir "$CONFIG_DIR/log"
    set popupTimeout 5000
    set popupFont {Helvetica 16}
    switch $::PLATFORM {
        $::PLATFORM_WIN {
            set popupLocation se
        }
        default {
            set popupLocation ne
        }
    }
    set toolbarHidden false
    
    set maxSendHistory 50
    set maxScrollback 200
    
    set mentionColor "LightGreen" ;#PaleGreen, PaleGreen3
    set mentionSound "[pwd]/mention.wav"
    
    
    set prefFile "$CONFIG_DIR/psyche.cfg"
    #set prefFile [pwd]/test.cfg                 ;#This is for debug
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
        if {[regexp "^set ((timeout |raiseNewTabs |defaultQuit |defaultBan |defaultKick |defaultPart |defaultAway |bookmarks\\(.*\\)|logEnabled |logDir |popupTimeout |popupLocation |popupFont |maxSendHistory |maxScrollback |mentionSound |mentionColor |toolbarHidden ).*)" $data -> data]} {
            set data "set Pref::$data"
        }
        debugV "Reading preference: '$data'"

        if {[catch {eval "$data"} prob]} {
            debugE "ERROR: Unable to load preference: '$data"
        }
    }
    close $fp
    
    menu .bookmarkMenu -tearoff true -title Bookmarks
    catch {set derp [lreverse [array names Pref::bookmarks]]
    foreach x $derp {
        .bookmarkMenu add command -label $x -command "Main::openBookmark $x"
    }} ;# lreverse is not defined in tcl 8.4

    return 1
}

proc Pref::writePrefs {pref val} {

}

debugV "Preference file exists? [file exists $Pref::prefFile]"

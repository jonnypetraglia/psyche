package require BWidget

namespace eval Pref {
    #NOT a preference; for reference
    set CONFIG_DIR "$::env(HOME)${Main::fs_sep}.psyche"
    if {[file exists "[pwd]${Main::fs_sep}portable"] && $::PLATFORM == $::PLATFORM_WIN} {
        set CONFIG_DIR "[pwd]"
    }
    
    puts "[file dirname [info script]]"

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
    variable maxScrollback
    variable mentionColor
    variable mentionSound
    variable toolbarHidden
    
    variable gtimeout
    variable gsendh
    variable gscrollback
    variable gmenColorBtn
    variable gmenSoundBtn
    variable gmenSound
    variable gquit
    variable gkick
    variable gban
    variable gpart
    variable gaway
    variable glogDir
    variable glogDirBtn
    variable gptimeout
    variable gpopupFontBtn
    variable vnewFont
    
    set timeout 5000
    set raiseNewTabs false
    set defaultQuit "Quittin'"
    set defaultKick "Please stop that"
    set defaultBan "Stop. That."
    set defaultPart "Partin'"
    set defaultAway "I'm away"
    set logEnabled false
    set logDir "$CONFIG_DIR${Main::fs_sep}log"
    set popupTimeout 5000
    set popupFont {Helvetica 16}
    if {$::PLATFORM == $::PLATFORM_WIN} {
        set popupLocation se
    } else {
        set popupLocation ne
    }
    set toolbarHidden false
    
    set maxSendHistory 50
    set maxScrollback 200
    
    set mentionColor "LightGreen" ;#PaleGreen, PaleGreen3
    set mentionSound "[pwd]${Main::fs_sep}mention.wav"
    
    set prefFile "$CONFIG_DIR${Main::fs_sep}psyche.cfg"
    #set prefFile [pwd]${Main::fs_sep}test.cfg                 ;#This is for debug
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

proc Pref::writePrefs {} {
    set prefsToWrite {timeout raiseNewTabs defaultQuit defaultBan defaultKick defaultPart defaultAway logEnabled logDir popupTimeout popupLocation popupFont maxSendHistory maxScrollback mentionColor mentionSound}
    foreach pref $prefsToWrite {
        set val "Pref::$pref"
        set val "[expr $$val]"
        debug "Writing preference: $pref   $val"
    }
}

proc Pref::show {} {
    if [winfo exists .prefDialog] {
        Main::foreground_win .prefDialog
        Pref::setValues
        return
    }
    toplevel .prefDialog
    wm title .prefDialog "Preferences"
    wm maxsize .prefDialog 600 400
    wm resizable .prefDialog 0 0
    
    set notebook [NoteBook .prefDialog.nb]
    $notebook compute_size
    xbutton .prefDialog.save -text "Save"
    xbutton .prefDialog.cancel -text "Cancel"
    grid config $notebook        -row 0 -column 0 -padx 4 -pady 4 -columnspan 100
    grid config .prefDialog.save -row 1 -column 98
    grid config .prefDialog.cancel -row 1 -column 99 -padx 4 -pady 4
    
    #################### General tab ####################
    set page [$notebook insert end preftab1 -text "General"]
    $notebook raise [$notebook page 0]
    set theFrame [frame $page.frame]
    pack $theFrame -fill both -expand 1
    
    xlabel $theFrame.l_timeout          -text "Timeout (ms)"
    set Pref::gtimeout [xspinbox $theFrame.timeout          -from 0 -increment 1000 -to 60000]
    xlabel $theFrame.l_sendh            -text "Max Send History"
    set Pref::gsendh [xspinbox $theFrame.sendh            -from 0 -increment 10 -to 100000]
    xlabel $theFrame.l_scrollback       -text "Max Scrollback"
    set Pref::gscrollback [xspinbox $theFrame.scrollback       -from 0 -increment 10 -to 100000]
    xlabel $theFrame.l_raiseNewTabs     -text "Raise New Tabs"
    xcheckbutton $theFrame.raiseNewTabs -onvalue true -offvalue false \
        -variable Pref::raiseNewTabs
    xlabel $theFrame.l_mcolor           -text "Mention Color"
    set Pref::gmenColorBtn [button $theFrame.mcolor -width 10]
    xlabel $theFrame.l_msound           -text "Mention Sound"
    set Pref::gmenSound [xentry $theFrame.msound -width 50]
    set Pref::gmenSoundBtn [xbutton $theFrame.b_msound -width 4 -text "..."]
    
    grid config $theFrame.l_timeout      -row 0 -column 0 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.timeout        -row 0 -column 1 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.l_sendh        -row 1 -column 0 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.sendh          -row 1 -column 1 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.l_scrollback   -row 2 -column 0 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.scrollback     -row 2 -column 1 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.l_raiseNewTabs -row 3 -column 0 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.raiseNewTabs   -row 3 -column 1 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.l_mcolor       -row 4 -column 0 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.mcolor         -row 4 -column 1 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.l_msound       -row 5 -column 0 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.msound         -row 5 -column 1 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.b_msound       -row 5 -column 4 -padx 5 -pady 5
    
    #################### Messages tab ####################
    set page [$notebook insert end preftab2 -text "Default Messages"]
    set theFrame [frame $page.frame]
    pack $theFrame -fill both -expand 1
    
    xlabel $theFrame.l_quit -text "Quit:"
    set Pref::gquit [xentry $theFrame.quit -width 65]
    xlabel $theFrame.l_kick -text "Kick:"
    set Pref::gkick [xentry $theFrame.kick -width 65]
    xlabel $theFrame.l_ban  -text "Ban:"
    set Pref::gban  [xentry $theFrame.ban  -width 65]
    xlabel $theFrame.l_part -text "Part:"
    set Pref::gpart [xentry $theFrame.part -width 65]
    xlabel $theFrame.l_away -text "Away:"
    set Pref::gaway [xentry $theFrame.away -width 65]
    
    set pady 10
    grid config $theFrame.l_quit      -row 0 -column 0 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.quit        -row 0 -column 1 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.l_kick      -row 1 -column 0 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.kick        -row 1 -column 1 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.l_ban       -row 2 -column 0 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.ban         -row 2 -column 1 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.l_part      -row 3 -column 0 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.part        -row 3 -column 1 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.l_away      -row 4 -column 0 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.away        -row 4 -column 1 -padx 5 -pady $pady -sticky "w"
    
    #################### Mentions tab ####################
    set page [$notebook insert end preftab3 -text "Notification"]
    set theFrame [frame $page.frame]
    pack $theFrame -fill both -expand 1
    
    xlabel $theFrame.l_ptimeout         -text "Timeout (ms)"
    set Pref::gptimeout [xspinbox $theFrame.ptimeout       -from 0 -increment 10 -to 100000]
    
    xlabel $theFrame.l_plocation        -text "Location"
    xlabelframe $theFrame.plocation
    set ::nsew "new"
    set nw [radiobutton $theFrame.plocation.nw -value "nw" -variable nsew -text "Top/Left" -indicatoron 0]
    set ne [radiobutton $theFrame.plocation.ne -value "ne" -variable nsew -text "Top/Right" -indicatoron 0]
    set sw [radiobutton $theFrame.plocation.sw -value "sw" -variable nsew -text "Bottom/Left" -indicatoron 0]
    set se [radiobutton $theFrame.plocation.se -value "se" -variable nsew -text "Bottom/Right" -indicatoron 0]
    
    xlabel $theFrame.pl_font        -text "Font"
    set Pref::gpopupFontBtn [button $theFrame.pfont]
    # popup
    #  timeout, location, font
    
    grid config $theFrame.l_ptimeout    -row 0 -column 0 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.ptimeout      -row 0 -column 1 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.l_plocation   -row 1 -column 0 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.plocation     -row 1 -column 1 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $nw -row 0 -column 0 -padx 5 -pady 5
    grid config $ne -row 0 -column 1 -padx 5 -pady 5
    grid config $sw -row 1 -column 0 -padx 5 -pady 5
    grid config $se -row 1 -column 1 -padx 5 -pady 5
    grid config $theFrame.pl_font       -row 3 -column 0 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.pfont         -row 3 -column 1 -padx 5 -pady 5 -sticky "w" -columnspan 2
    
    #################### Logging tab ####################
    set page [$notebook insert end preftab4 -text "Logging"]
    set theFrame [frame $page.frame]
    pack $theFrame -fill both -expand 1
    
    xlabel $theFrame.l_logenabled -text "Logging enabled"
    xcheckbutton $theFrame.logenabled -variable Pref::logEnabled -onvalue true -offvalue false
    
    xlabel $theFrame.l_logdir           -text "Logging Directory"
    set Pref::glogDir [xentry $theFrame.logdir -width 50]
    set Pref::glogDirBtn [xbutton $theFrame.b_logdir -width 4 -text "..."]
    xbutton $theFrame.openlogdir -text "Open Data Location"
    
    grid config $theFrame.l_logenabled      -row 0 -column 0 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.logenabled        -row 0 -column 1 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.l_logdir          -row 1 -column 0 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.logdir            -row 1 -column 1 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.b_logdir          -row 1 -column 4 -padx 5 -pady 5
    grid config $theFrame.openlogdir        -row 2 -column 0 -padx 5 -pady 5 -columnspan 4
    
    Pref::setValues
    
    #################### Binding clicks ####################
    bind $Pref::gmenColorBtn <ButtonRelease> {
        set newColor [tk_chooseColor -initialcolor $Pref::mentionColor -parent .prefDialog]
        if {[string length $newColor] > 0} {
            set $Pref::mentionColor [string range $newColor 1 end]
            $Pref::gmenColorBtn configure -background $newColor -activebackground $newColor
        }
    }
    bind $Pref::gmenSoundBtn <ButtonRelease> {
        set newFile [tk_getOpenFile -filetypes {{{Wave Files} {.wav}}} -parent .prefDialog]
        $Pref::gmenSound delete 0 end
        $Pref::gmenSound insert 0 $newFile
    }
    bind $Pref::gpopupFontBtn <ButtonRelease> {
        set newFont [SelectFont .prefDialog.font -font $Pref::popupFont]
        if {[string length $newFont] > 0} {
            set Pref::vnewFont $newFont
            $Pref::gpopupFontBtn configure -text [join $Pref::vnewFont " "] -font $Pref::vnewFont
            
        }
    }
    bind .prefDialog.cancel <ButtonRelease> {
        destroy .prefDialog
    }
    bind .prefDialog.save <ButtonRelease> {
        wm withdraw .prefDialog
        Pref::writePrefs
    }
    bind $theFrame.openlogdir <ButtonRelease> {
        platformOpen $Pref::logDir
    }
}

proc Pref::setValues {} {
    #################### Setting values ####################
    $Pref::gtimeout    set $Pref::timeout
    $Pref::gsendh      set $Pref::maxSendHistory
    $Pref::gscrollback set $Pref::maxScrollback
    #$theFrame.raiseNewTabs
    $Pref::gmenColorBtn configure -background $Pref::mentionColor -activebackground $Pref::mentionColor
    $Pref::gmenSound delete 0 end
    $Pref::gmenSound insert 0 $Pref::mentionSound
    $Pref::glogDir delete 0 end
    $Pref::glogDir insert 0 $Pref::logDir
    $Pref::gquit delete 0 end
    $Pref::gquit insert 0 $Pref::defaultQuit
    $Pref::gkick delete 0 end
    $Pref::gkick insert 0 $Pref::defaultKick
    $Pref::gban  delete 0 end
    $Pref::gban  insert 0 $Pref::defaultBan
    $Pref::gpart delete 0 end
    $Pref::gpart insert 0 $Pref::defaultPart
    $Pref::gaway delete 0 end
    $Pref::gaway insert 0 $Pref::defaultAway
    $Pref::gptimeout    set $Pref::popupTimeout
    set ::nsew $Pref::popupLocation
    $Pref::gpopupFontBtn configure -text [join $Pref::popupFont " "]  -font $Pref::popupFont
}

debugV "Preference file exists? [file exists $Pref::prefFile]"

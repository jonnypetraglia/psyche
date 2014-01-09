package require BWidget

namespace eval Pref {
    #NOT a preference; for reference
    set CONFIG_DIR "$::env(HOME)${Main::fs_sep}.psyche"
    if {[file exists "[pwdW]${Main::fs_sep}portable"] && $::PLATFORM == $::PLATFORM_WIN} {
        set CONFIG_DIR "[pwdW]"
    }
    
    puts "[file dirname [info script]]"

    variable timeout
    variable raiseNewTabs
    variable useTheme
    variable defaultQuit
    variable defaultBan
    variable defaultKick
    variable defaultPart
    variable defaultAway
    variable banMask
    variable bookmarks
    variable logServers
    variable logChannels
    variable logPMs
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
    variable guseTheme
    variable gquit
    variable gkick
    variable gban
    variable gpart
    variable gaway
    variable glogDir
    variable glogDirBtn
    variable gptimeout
    variable gpopupFontBtn
    variable graiseNew
    variable gtoolbar
    variable glogServers
    variable glogChannels
    variable glogPMs
    variable gmenSoundChk
    variable gmenSoundChk_v
    variable vnewFont
    variable gBname
    variable gBserver
    variable gBport
    variable gBssl
    variable gBnick
    variable gBpass
    variable gBchannels
    variable gBsave
    variable gBcancel
    variable gBadd
    variable gBremove
    variable gBedit
    variable gBlist
    variable tempbookmarks
    variable tempssl
    
    set timeout 5000
    set raiseNewTabs false
    set useTheme [expr [expr {$::tcl_version >= 8.5} && {$::PLATFORM != $::PLATFORM_MAC}] == 1 ? true : false]
    set defaultQuit "Quittin'"
    set defaultKick "Please stop that"
    set defaultBan "Stop. That."
    set defaultPart "Partin'"
    set defaultAway "I'm away"
    set banMask "*!user@domain"
    set logServers false
    set logChannels false
    set logPMs false
    set logDir "${CONFIG_DIR}${Main::fs_sep}log"
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
    set mentionSound "[pwdW]${Main::fs_sep}mention.wav"
    
    set prefFile "$CONFIG_DIR${Main::fs_sep}psyche.cfg"
    #set prefFile [pwdW]${Main::fs_sep}test.cfg                 ;#This is for debug
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
        if {[regexp "^set ((timeout |raiseNewTabs |useTheme |defaultQuit |defaultBan |defaultKick |defaultPart |defaultAway |bookmarks\\(.*\\)|logServers |logChannels|logPMs |logDir |popupTimeout |popupLocation |popupFont |maxSendHistory |maxScrollback |mentionSound |mentionColor |toolbarHidden |banMask ).*)" $data -> data]} {
            set data "set Pref::[regsub -all {\\} $data {\\\\}]"
        }
        Log V "Reading preference: '$data'"

        if {[catch {eval "$data"} prob]} {
            Log E "ERROR: Unable to load preference: '$data"
        }
    }
    close $fp
    aliases
    menu .bookmarkMenu -tearoff false -title Bookmarks
    Pref::createBookmarkMenu
    return 1
}

proc Pref::createBookmarkMenu {} {
    .bookmarkMenu delete 0 end
    catch {set derp [lsort -nocase [array names Pref::bookmarks]]
    foreach x $derp {
        .bookmarkMenu add command -label $x -command "Main::openBookmark $x"
    }}
}

proc Pref::show {} {
    if [winfo exists .prefDialog] {
        Main::foreground_win .prefDialog
        grab .prefDialog
        Pref::setValues
        return
    }
    toplevel .prefDialog
    wm title .prefDialog "Preferences"
    wm maxsize .prefDialog 600 400
    wm resizable .prefDialog 0 0
    grab .prefDialog
    
    set notebook [NoteBook .prefDialog.nb]
    $notebook compute_size
    xbutton .prefDialog.save -text "Save" -command {
        Pref::savePrefs
        Pref::writePrefs
        grab release .prefDialog
        destroy .prefDialog
    }
    xbutton .prefDialog.cancel -text "Cancel" -command {grab release .prefDialog; destroy .prefDialog}
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
    set Pref::graiseNew [xcheckbutton $theFrame.raiseNewTabs -onvalue true -offvalue false -variable Pref::graiseNew_v]
    xlabel $theFrame.l_mcolor           -text "Mention Color"
    set Pref::gmenColorBtn [button $theFrame.mcolor -width 10]
    xlabel $theFrame.l_msound           -text "Mention Sound"
    set Pref::gmenSoundChk [xcheckbutton $theFrame.c_msound -onvalue true -offvalue false -variable Pref::gmenSoundChk_v]
    set Pref::gmenSound [xentry $theFrame.msound -width 50]
    set Pref::gmenSoundBtn [xbutton $theFrame.b_msound -width 4 -text "..."]
    xlabel $theFrame.l_hideToolbar      -text "Toolbar Hidden"
    set Pref::gtoolbar [xcheckbutton $theFrame.hideToolbar -onvalue true -offvalue false -variable Pref::gtoolbar_v]
    xlabel $theFrame.l_theme            -text "Use Theme"
    set Pref::guseTheme [xcheckbutton $theFrame.theme -onvalue true -offvalue false -variable Pref::guseTheme_v]
    xlabel $theFrame.n_theme            -text "(Requires restart)"
    if {$::tcl_version < 8.5} {
        $Pref::guseTheme configure -state disabled
    }
    
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
    grid config $theFrame.c_msound       -row 5 -column 1 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.msound         -row 5 -column 2 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.b_msound       -row 5 -column 4 -padx 5 -pady 5
    grid config $theFrame.l_hideToolbar  -row 6 -column 0 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.hideToolbar    -row 6 -column 1 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.l_theme        -row 7 -column 0 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.theme          -row 7 -column 1 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.n_theme        -row 7 -column 2 -padx 5 -pady 5 -sticky "w"
    
    #################### Bookmarks tab ####################
    set page [$notebook insert end preftab2 -text "Bookmarks"]
    set theFrame [frame $page.frame]
    pack $theFrame -fill both -expand 1
    
    
    set Pref::gBlist   [listbox $theFrame.list -width 40]
    set Pref::gBadd    [xbutton $theFrame.add              -text "Add"    -width 6 -command {$Pref::gBlist selection clear 0 end; Pref::addBookmark}]
    set Pref::gBremove [xbutton $theFrame.remove           -text "Remove" -width 9 -command Pref::removeBookmark]
    set Pref::gBedit   [xbutton $theFrame.edit             -text "Edit"   -width 6 -command Pref::editBookmark]
    
    xlabel $theFrame.l_name            -text "Label"
    set Pref::gBname [xentry $theFrame.name]
    xlabel $theFrame.l_server          -text "Server"
    set Pref::gBserver [xentry $theFrame.server]
    xlabel $theFrame.l_port            -text "Port"
    set Pref::gBport [xentry $theFrame.port]
    
    set Pref::gBssl [xcheckbutton $theFrame.ssl -text "SSL" -variable Pref::tempssl -onvalue true -offvalue false]
    
    xlabel $theFrame.l_nick            -text "Nick"
    set Pref::gBnick [xentry $theFrame.nick]
    xlabel $theFrame.l_pass            -text "NickServ Pass"
    set Pref::gBpass [xentry $theFrame.pass -show "*"]
    xlabel $theFrame.l_channels        -text "Channels"
    set Pref::gBchannels [xentry $theFrame.channels -width 30]
    xlabel $theFrame.channelsnote      -text "(Space delimited)"
    set Pref::gBsave [xbutton $theFrame.save -text "Update" -command Pref::saveBookmark]
    set Pref::gBcancel [xbutton $theFrame.cancel -text "Nevermind" -command Pref::clearBookmarks]
    
    grid config $theFrame.list          -row 0 -column 0  -padx 5 -pady 5 -sticky "w" -rowspan 10 -columnspan 10
    grid config $theFrame.l_name        -row 0 -column 10 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.name          -row 0 -column 11 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.l_server      -row 1 -column 10 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.server        -row 1 -column 11 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.l_port        -row 2 -column 10 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.port          -row 2 -column 11 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.ssl           -row 2 -column 12 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.l_nick        -row 3 -column 10 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.nick          -row 3 -column 11 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.l_pass        -row 4 -column 10 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.pass          -row 4 -column 11 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.l_channels    -row 5 -column 10 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.channels      -row 5 -column 11 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.channelsnote  -row 6 -column 11 -padx 5 -pady 0 -sticky "w"
    grid config $theFrame.add           -row 7 -column 0  -padx 5 -pady 0 -sticky "w"
    grid config $theFrame.remove        -row 7 -column 1  -padx 5 -pady 0 -sticky "w"
    grid config $theFrame.edit          -row 7 -column 2  -padx 5 -pady 0 -sticky "w"
    grid config $theFrame.save          -row 7 -column 12 -padx 5 -pady 0 -sticky "e"
    grid config $theFrame.cancel        -row 7 -column 11 -padx 5 -pady 0 -sticky "e"
    
    #################### Messages tab ####################
    set page [$notebook insert end preftab3 -text "Default Messages"]
    set theFrame [frame $page.frame]
    pack $theFrame -fill both -expand 1
    
    xlabel $theFrame.l_quit -text "Quit:"
    set Pref::gquit [xentry $theFrame.quit -width 65]
    xlabel $theFrame.l_kick -text "Kick:"
    set Pref::gkick [xentry $theFrame.kick -width 65]
    xlabel $theFrame.l_part -text "Part:"
    set Pref::gpart [xentry $theFrame.part -width 65]
    xlabel $theFrame.l_away -text "Away:"
    set Pref::gaway [xentry $theFrame.away -width 65]
    xlabel $theFrame.l_ban  -text "Ban:"
    set Pref::gban  [xentry $theFrame.ban  -width 65]
    
    xlabelframe $theFrame.banmask -text "Ban mask"
    set ::banmask "*!*@domain"
    set ban_host       [radiobutton $theFrame.banmask.host       -variable banmask -text "*!*@*.host"    -value "*!*@*.host"]
    set ban_domain     [radiobutton $theFrame.banmask.domain     -variable banmask -text "*!*@domain"    -value "*!*@domain"]
    set ban_userhost   [radiobutton $theFrame.banmask.userhost   -variable banmask -text "*!user@*.host" -value "*!user@*.host"]
    set ban_userdomain [radiobutton $theFrame.banmask.userdomain -variable banmask -text "*!user@domain" -value "*!user@domain"]
    
    set pady 7
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
    
    grid config $theFrame.banmask   -row 5 -column 0 -padx 5 -pady 10 -sticky "w" -columnspan 2
    grid config $ban_host       -row 0 -column 0 -padx 5 -pady 5
    grid config $ban_domain     -row 0 -column 1 -padx 5 -pady 5
    grid config $ban_userhost   -row 0 -column 2 -padx 5 -pady 5
    grid config $ban_userdomain -row 0 -column 3 -padx 5 -pady 5
    
    #################### Mentions tab ####################
    set page [$notebook insert end preftab4 -text "Notification"]
    set theFrame [frame $page.frame]
    pack $theFrame -fill both -expand 1
    
    xlabel $theFrame.l_ptimeout         -text "Timeout (ms)"
    set Pref::gptimeout [xspinbox $theFrame.ptimeout       -from 0 -increment 10 -to 100000]
    
    xlabel $theFrame.l_plocation        -text "Location"
    xlabelframe $theFrame.plocation
    set ::nsew "nw"
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
    set page [$notebook insert end preftab5 -text "Logging"]
    set theFrame [frame $page.frame]
    pack $theFrame -fill both -expand 1
    
    
    xlabel $theFrame.l_logservers -text "Log servers"
    set Pref::glogServers [xcheckbutton $theFrame.logservers -onvalue true -offvalue false -variable Pref::glogServers_v]
    xlabel $theFrame.l_logchannels -text "Log channels"
    set Pref::glogChannels [xcheckbutton $theFrame.logchannels -onvalue true -offvalue false -variable Pref::glogChannels_v]
    xlabel $theFrame.l_logpms -text "Log PMs"
    set Pref::glogPMs [xcheckbutton $theFrame.logpms -onvalue true -offvalue false -variable Pref::glogPMs_v]
    
    xlabel $theFrame.l_logdir           -text "Logging Directory"
    set Pref::glogDir [xentry $theFrame.logdir -width 50]
    set Pref::glogDirBtn [xbutton $theFrame.b_logdir -width 4 -text "..."]
    xbutton $theFrame.openlogdir -text "Open Data Location" -command {platformOpen $Pref::logDir}
    
    grid config $theFrame.l_logservers      -row 0 -column 0 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.logservers        -row 0 -column 1 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.l_logchannels     -row 1 -column 0 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.logchannels       -row 1 -column 1 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.l_logpms          -row 2 -column 0 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.logpms            -row 2 -column 1 -padx 5 -pady $pady -sticky "w"
    grid config $theFrame.l_logdir          -row 3 -column 0 -padx 5 -pady 5 -sticky "w"
    grid config $theFrame.logdir            -row 3 -column 1 -padx 5 -pady 5 -sticky "w" -columnspan 2
    grid config $theFrame.b_logdir          -row 3 -column 4 -padx 5 -pady 5
    grid config $theFrame.openlogdir        -row 4 -column 0 -padx 5 -pady 5 -columnspan 4
    
    #################### Binding clicks ####################
    $Pref::gmenColorBtn configure -command {
        set newColor [tk_chooseColor -initialcolor $Pref::mentionColor -parent .prefDialog]
        if {[string length $newColor] > 0} {
            set $Pref::mentionColor [string range $newColor 1 end]
            $Pref::gmenColorBtn configure -background $newColor -activebackground $newColor
        }
    }
    $Pref::gmenSoundBtn configure -command {
        set newFile [tk_getOpenFile -filetypes {{{Wave Files} {.wav}}} -parent .prefDialog]
        $Pref::gmenSound delete 0 end
        $Pref::gmenSound insert 0 $newFile
    }
    $Pref::gpopupFontBtn configure -command {
        set newFont [SelectFont .prefDialog.font -font $Pref::popupFont]
        if {[string length $newFont] > 0} {
            set Pref::vnewFont $newFont
            $Pref::gpopupFontBtn configure -text [join $Pref::vnewFont " "] -font $Pref::vnewFont
            
        }
    }
    $Pref::gmenSoundChk configure -command {
        if {$Pref::gmenSoundChk_v==true} {
            $Pref::gmenSound configure -state normal
            $Pref::gmenSoundBtn configure -state normal
        } else {
            $Pref::gmenSound configure -state disabled
            $Pref::gmenSoundBtn configure -state disabled
        }
    }
    
    Pref::setValues
}

proc Pref::addBookmark {} {
    $Pref::gBname     configure -state normal
    $Pref::gBserver   configure -state normal
    $Pref::gBport     configure -state normal
    $Pref::gBssl      configure -state normal
    $Pref::gBnick     configure -state normal
    $Pref::gBpass     configure -state normal
    $Pref::gBchannels configure -state normal
    $Pref::gBsave     configure -state normal
    $Pref::gBcancel   configure -state normal
    $Pref::gBlist     configure -state disabled
    $Pref::gBadd      configure -state disabled
    $Pref::gBremove   configure -state disabled
    $Pref::gBedit     configure -state disabled
    
    $Pref::gBname     delete 0 end
    $Pref::gBserver   delete 0 end
    $Pref::gBport     delete 0 end
    $Pref::gBnick     delete 0 end
    $Pref::gBpass     delete 0 end
    $Pref::gBchannels delete 0 end
}

proc Pref::editBookmark {} {
    Pref::addBookmark
    
    if {[$Pref::gBlist curselection] >=0} {
        set name [$Pref::gBlist get [$Pref::gBlist curselection]]
        set bookmark $Pref::tempbookmarks($name)
        
        set connInfo [lindex $bookmark 0]
        Log D "Editing Bookmark: $bookmark"
        $Pref::gBname     insert 0 $name
        $Pref::gBserver   insert 0 [lindex $connInfo 0]
        $Pref::gBport     insert 0 [lindex $connInfo 1]
        set Pref::tempssl [lindex $connInfo 2]
        $Pref::gBnick     insert 0 [lindex [lindex $bookmark 1] 0]
        $Pref::gBpass     insert 0 [lindex [lindex $bookmark 1] 1]
        $Pref::gBchannels insert 0 [lindex $bookmark 2]
    }
}

proc Pref::clearBookmarks {} {
    $Pref::gBname     delete 0 end
    $Pref::gBserver   delete 0 end
    $Pref::gBport     delete 0 end
    set Pref::tempssl false
    $Pref::gBnick     delete 0 end
    $Pref::gBpass     delete 0 end
    $Pref::gBchannels delete 0 end
    
    $Pref::gBname     configure -state disabled
    $Pref::gBserver   configure -state disabled
    $Pref::gBport     configure -state disabled
    $Pref::gBssl      configure -state disabled
    $Pref::gBnick     configure -state disabled
    $Pref::gBpass     configure -state disabled
    $Pref::gBchannels configure -state disabled
    $Pref::gBsave     configure -state disabled
    $Pref::gBcancel   configure -state disabled
    $Pref::gBlist     configure -state normal
    $Pref::gBadd      configure -state normal
    $Pref::gBremove   configure -state normal
    $Pref::gBedit     configure -state normal
}

proc Pref::saveBookmark {} {
    $Pref::gBlist     configure -state normal
    Log D "Selected: [$Pref::gBlist curselection]"
    set oldname [$Pref::gBlist get active]
    set newname [$Pref::gBname get]
    set thing [list]
    
    lappend thing [list [$Pref::gBserver get] [$Pref::gBport get] $Pref::tempssl]
    if {[string length [$Pref::gBpass get]] > 0} {
        lappend thing [list [$Pref::gBnick get] [$Pref::gBpass get]]
    } else {
        lappend thing [list [$Pref::gBnick get]]
    }
    if {[string length [$Pref::gBchannels get]] > 0} {
        lappend thing [split [$Pref::gBchannels get] " "]
    }
    set cur [$Pref::gBlist curselection]
    if {$cur != ""} {
        if {$oldname!=$newname} {
            unset Pref::tempbookmarks($oldname)
        }
        set curi [$Pref::gBlist index active]
        $Pref::gBlist delete $curi
    } else {
        set curi [$Pref::gBlist index end]
    }
    $Pref::gBlist insert $curi $newname
    set Pref::tempbookmarks($newname) $thing
    $Pref::gBlist activate $curi
    
    Pref::clearBookmarks
}


proc Pref::setValues {} {
    # bookmarks
    $Pref::gBlist delete 0 end
    array unset ::Pref::tempbookmarks
    array set ::Pref::tempbookmarks [array get ::Pref::bookmarks]
    foreach name [lsort -nocase [array names ::Pref::tempbookmarks]] {
        $Pref::gBlist insert end $name
    }
    Pref::clearBookmarks
    
    # spinboxes
    $Pref::gtimeout     set $Pref::timeout
    $Pref::gsendh       set $Pref::maxSendHistory
    $Pref::gscrollback  set $Pref::maxScrollback
    $Pref::gptimeout    set $Pref::popupTimeout
    # entries
    $Pref::gmenSound delete 0 end
    $Pref::gmenSound insert 0 $Pref::mentionSound
    $Pref::glogDir   delete 0 end
    $Pref::glogDir   insert 0 $Pref::logDir
    $Pref::gquit     delete 0 end
    $Pref::gquit     insert 0 $Pref::defaultQuit
    $Pref::gkick     delete 0 end
    $Pref::gkick     insert 0 $Pref::defaultKick
    $Pref::gban      delete 0 end
    $Pref::gban      insert 0 $Pref::defaultBan
    $Pref::gpart     delete 0 end
    $Pref::gpart     insert 0 $Pref::defaultPart
    $Pref::gaway     delete 0 end
    $Pref::gaway     insert 0 $Pref::defaultAway
    # checkbuttons
    set ::[$Pref::graiseNew cget -variable]    $Pref::raiseNewTabs
    set ::[$Pref::gtoolbar cget -variable]     $Pref::toolbarHidden
    set ::[$Pref::glogServers cget -variable]  $Pref::logServers
    set ::[$Pref::glogChannels cget -variable] $Pref::logChannels
    set ::[$Pref::glogPMs cget -variable]      $Pref::logPMs
    set ::[$Pref::guseTheme cget -variable]    $Pref::useTheme
    # radio groups
    set ::nsew $Pref::popupLocation
    set ::banmask $Pref::banMask
    # color buttons
    $Pref::gmenColorBtn configure -background $Pref::mentionColor -activebackground $Pref::mentionColor
    # font buttons
    $Pref::gpopupFontBtn configure -text [join $Pref::popupFont " "]  -font $Pref::popupFont
    # dependent entries
    if {[string length $Pref::mentionSound] > 0 } {
        set ::[$Pref::gmenSoundChk cget -variable] true
        $Pref::gmenSound configure -state enabled
        $Pref::gmenSoundBtn configure -state enabled
    } else {
        set ::[$Pref::gmenSoundChk cget -variable] false
        $Pref::gmenSound configure -state disabled
        $Pref::gmenSoundBtn configure -state disabled
    }
}

proc Pref::savePrefs {} {
    # spinboxes
    set Pref::timeout         [$Pref::gtimeout get]
    set Pref::maxSendHistory  [$Pref::gsendh get]
    set Pref::maxScrollback   [$Pref::gscrollback get]
    set Pref::popupTimeout    [$Pref::gptimeout get]
    # entries
    set Pref::logDir          [$Pref::glogDir get]
    set Pref::defaultQuit     [$Pref::gquit get]
    set Pref::defaultKick     [$Pref::gkick get]
    set Pref::defaultBan      [$Pref::gban get]
    set Pref::defaultPart     [$Pref::gpart get]
    set Pref::defaultAway     [$Pref::gaway get]
    # checkbuttons
    set Pref::raiseNewTabs    $Pref::graiseNew_v
    set Pref::toolbarHidden   $Pref::gtoolbar_v
    set Pref::logServers      $Pref::glogServers_v
    set Pref::logChannels     $Pref::glogChannels_v
    set Pref::logPMs          $Pref::glogPMs_v
    set Pref::useTheme        $Pref::guseTheme_v
    # radio groups
    set Pref::popupLocation $::nsew
    set Pref::banMask $::banmask
    # color buttons
    set Pref::mentionColor [$Pref::gmenColorBtn cget -background]
    # font buttons
    set Pref::popupFont [$Pref::gpopupFontBtn cget -font]
    # dependent entries
    if {$Pref::gmenSoundChk_v==true} {
        set Pref::mentionSound    [$Pref::gmenSound get]
    } else {
        set Pref::mentionSound    ""
    }
    # bookmarks
    array unset ::Pref::bookmarks
    array set ::Pref::bookmarks [array get ::Pref::tempbookmarks]
    Pref::createBookmarkMenu
    # color
    
    set servs [array names Main::servers]
    foreach serv $servs {
        $Main::servers($serv) resetMentionColor
        $Main::servers($serv) resetLog
    }
    
}

proc Pref::writePrefs {} {
    set fp [open $Pref::prefFile w]
    set prefsToWrite {timeout raiseNewTabs useTheme defaultQuit defaultBan defaultKick defaultPart defaultAway logServers logChannels logPMs logDir popupTimeout popupLocation popupFont maxSendHistory maxScrollback mentionColor mentionSound toolbarHidden banMask}
    foreach pref $prefsToWrite {
        set val "Pref::$pref"
        set val "[expr $$val]"
        puts $fp "set $pref \"$val\""
        Log D "Writing preference:   $pref = \"$val\""
    }
    foreach key [lsort -dictionary [array names Pref::bookmarks]] {
        #do something with key and value
        Log D "Writing preference:   bookmarks($key) = {$Pref::bookmarks($key)}"
        puts $fp "set bookmarks($key) {$Pref::bookmarks($key)}"
    }
    flush $fp
    close $fp
}

Log V "Preference file exists? [file exists $Pref::prefFile]"

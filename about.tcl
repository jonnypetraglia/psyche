namespace eval About {
    variable icondir
    variable tk_version
    variable bwidget_version
    variable snit_version
    variable copyright_year
    variable donateUrl
    variable BTC
    variable config
    variable keystrokes
    
    set tk_version [package version Tk]
    set bwidget_version [package version BWidget]
    set snit_version [package version snit]
    
    set icondir [pwdW]/icons
    set copyright_year 2013
    set donateUrl "http://qweex.com/donate"
    set BTC "1G6cCKnhbESiBXLprxNjzjFDZsES4tH9ZM"
    set LTC "LRthYyVMBUJJqkoJTnnWrTQpuATWfv5s7g"
    
    
    set config(timeout) {"(integer)" "the time in milliseconds to wait for a server to connect"}
    set config(raiseNewTabs) {"(boolean)" "when opening a new tab if you want to immediately switch to it"}
    set config(defaultQuit) {"(string)" "the default message when issuing the /quit command or pressing the Quit button"}
    set config(defaultKick) {"(string)" "the default message when issuing the /kick command or using the Ban/Kick menu)"}
    set config(defaultBan) {"(string)" "the default message when issuing the /kb command or using the Ban/Kick menu; used specifically for the Kick message in kickbans)"}
    set config(defaultPart) {"(string)" "the default message when issuing the /part command or pressing the Part button)"}
    set config(defaultAway) {"(string)" "the default message when issuing the /away command or pressing the Away button"}
    set config(logEnabled) {"(boolean)" "if you want all messages to be logged"}
    set config(logDir) {"(string)" "the location of the log"}
    set config(popupTimeout) {"(integer)" "the duration in milliseconds the popup notification for mentions should stay on the screen; set to 0 for it to stay indefinitely until manually dismissed"}
    set config(popupLocation) {"(nsew)" "the location on the screen for the popup; should contain one of 'n' or 's' for the vertical and one of 'e' or 'w' for the horizontal; example: 'nw'"}
    set config(popupFont) {"(list)" "the font to be used in the mention popup; see the Tcl/Tk documentation on fonts for syntax"}
    set config(maxSendHistory) {"(integer)" "how many of your past commands to keep"}
    set config(maxScrollback) {"(integer)" "how many lines on screen the chats should be limited"}
    set config(mentionColor) {"(string/hex)" "the color to change a tab to when it has been mentioned; can use the strings builtin to Tcl/Tk or a custom RGB value"}
    set config(mentionSound) {"(string)" "the path to the sound file to be played when you are mentioned; set to the empty string if you want to disable sounds"}
    set config(bookmarks) {"" "bookmarks are slightly more complicated, in that they are stored in the array 'bookmarks' with a list of the values needed to connect. If any channels are given, they are joined automatically.\nSyntax:   bookmarks($nickname) \{$server $port $nick $channel1 $channel2 ...\}"}
    set config(toolbarHidden) {"boolean" "hides the toolbar by default"}
    
    
    # Key strokes
    set keystrokes [list]
    if { $::PLATFORM == $::PLATFORM_MAC } {
        lappend keystrokes [list "⌘F" "Find"]
        lappend keystrokes [list "⌘G" "Find Next"]
        for {set i 1} {$i < 10} {incr i} {
            lappend keystrokes [list "⌘$i" "Nick completion"]
        }
        lappend keystrokes [list "⌘0" "Nick completion"] 
    } else {
        lappend keystrokes [list "Ctrl+F" "Find"]
        lappend keystrokes [list "F3" "Find Next"]
        for {set i 1} {$i < 10} {incr i} {
            lappend keystrokes [list "Alt+$i" "Switch to tab $i"]
        }
        lappend keystrokes [list "Alt+0" "Switch to tab 10"] 
    }
    lappend keystrokes [list "Up/Down" "Scroll through previous sent messages"]
    lappend keystrokes [list "Tab" "Nick completion"]
    lappend keystrokes [list "F10" "Toggle Toolbar"]
}


proc About::show {} {
    if [winfo exists .aboutDialog] {
        Main::foreground_win .aboutDialog
        return
    }
    toplevel .aboutDialog
    wm title .aboutDialog "About"
    wm maxsize .aboutDialog 600 400
    wm resizable .aboutDialog 0 0
    
    set notebook [NoteBook .aboutDialog.nb]
    $notebook compute_size
    pack $notebook -fill both -expand yes -padx 4 -pady 4
    
    #################### About tab ####################
    set page [$notebook insert end about -text "About"]
    $notebook raise [$notebook page 0]
    set theFrame [frame $page.frame]
    pack $theFrame -fill both -expand 1
    
    set builtonString ""
    set builtonString "${builtonString}        Tcl v[info patchlevel]\n"
    set builtonString "${builtonString}        Tk v$About::tk_version\n"
    set builtonString "${builtonString}        BWidget v$About::bwidget_version\n"
    set builtonString "${builtonString}        snit v$About::snit_version\n"
    
    xlabel $theFrame.icon -image [image create photo -file $About::icondir/butterfly-icon_192.gif]
    xlabel $theFrame.title -text "$Main::APP_NAME $Main::APP_VERSION" -font {Arial 25}
    xlabel $theFrame.cwith -text "Compiled with:\n$builtonString" -justify left
    xlabel $theFrame.builton -text "Built on $Main::APP_BUILD_DATE"
    xlabel $theFrame.copyright -text "Copyright $About::copyright_year Jon Petraglia of Qweex"
    xlabel $theFrame.license -text "Released under the BSD 3-clause license"
    grid config $theFrame.icon      -row 0 -column 0 -padx 5 -sticky "w" -rowspan 5
    grid config $theFrame.title     -row 0 -column 1 -padx 5 -sticky "w"
    grid config $theFrame.cwith     -row 1 -column 1 -padx 5 -sticky "w"
    grid config $theFrame.builton   -row 2 -column 1 -padx 5 -sticky "w"
    grid config $theFrame.copyright -row 3 -column 1 -padx 5 -sticky "w"
    grid config $theFrame.license   -row 4 -column 1 -padx 5 -sticky "w"
    
    label $theFrame.hr -foreground grey \
        -text "_________________________________________________________________"
    grid $theFrame.hr -row 5 -column 0 -padx 5 -pady 15 -columnspan 2
    
    # Donate
    xlabel $theFrame.donate -text "Like Psyche? Support the developer." -foreground blue
    $theFrame.donate configure -font [linsert [$theFrame.donate cget -font] end -underline true]       ;#TODO: reliable way of getting font size
    $theFrame.donate configure -cursor $Main::cursor_link
    grid config $theFrame.donate    -row 6 -column 0 -padx 5 -columnspan 2 -pady 15
    bind $theFrame.donate <ButtonRelease> {platformOpen $About::donateUrl}
    
    # Crypto coins
    xlabel $theFrame.btc_l -text "BTC"
    xentry $theFrame.btc -textvariable About::BTC -state readonly -width 35 -foreground black
    xlabel $theFrame.ltc_l -text "LTC"
    xentry $theFrame.ltc -textvariable About::LTC -state readonly -width 35 -foreground black
    
    grid config $theFrame.btc_l -row 7 -column 0 -padx 5 -sticky "e"
    grid config $theFrame.btc   -row 7 -column 1 -padx 5 -sticky "w"
    grid config $theFrame.ltc_l -row 8 -column 0 -padx 5 -sticky "e"
    grid config $theFrame.ltc   -row 8 -column 1 -padx 5 -sticky "w"
    
    #################### Config tab ####################
    set page [$notebook insert end config -text "Config"]
    $notebook raise [$notebook page 0]
    set theFrame [frame $page.frame]
    pack $theFrame -fill both -expand 1
    
    # Scroll window content
    set sw [ScrolledWindow $theFrame.sv -background white ]
    set sf [ScrollableFrame $sw.scrollable -background white]
    $sw setwidget $sf
    set options [$sf getframe]
    
    # Headers
    xlabel $options.a -text "Variable" -background white
    $options.a configure -font [linsert [$options.a cget -font] end -weight bold -underline true]     ;#TODO how do get real font size + 2
    grid config $options.a -row 0 -column 0 -padx 2 -pady 2 -sticky "w"
    
    xlabel $options.b -text "Type" -background white
    $options.b configure -font [linsert [$options.b cget -font] end -weight bold -underline true]     ;#TODO how do get real font size + 2
    grid config $options.b -row 0 -column 1 -padx 2 -pady 2 -sticky "w"
    
    xlabel $options.c -text "Description" -background white
    $options.c configure -font [linsert [$options.c cget -font] end -weight bold -underline true]     ;#TODO how do get real font size + 2
    grid config $options.c -row 0 -column 2 -padx 2 -pady 2 -sticky "w"
    
    set i 1
    foreach c [array names About::config] {
        xlabel $options.a$i -text $c -background white
        $options.a$i configure -font [linsert [$options.a$i cget -font] end -size 9 -weight bold]     ;#TODO how do get real font size
        grid config $options.a$i -row $i -column 0 -padx 2 -pady 2 -sticky "w"
        
        xlabel $options.b$i -text [lindex $About::config($c) 0] -background white
        grid config $options.b$i -row $i -column 1 -padx 2 -pady 2 -sticky "w"
        
        xlabel $options.c$i -text [lindex $About::config($c) 1] -background white -justify left
        grid config $options.c$i -row $i -column 2 -padx 2 -pady 2 -sticky "w"

        incr i
    }
    pack $sw -fill both -expand 1 -padx 2
    
    # Info text
    xlabel $theFrame.locationL -text "\nPsyche's configuration is stored in a Tcl file located at:" -anchor w
    pack $theFrame.locationL -fill x -expand 1
    xlabel $theFrame.location -text "$Pref::prefFile" -anchor w -foreground blue
    #$theFrame.location configure -font [linsert [$theFrame.location cget -font] end 9 underline]       ;#TODO: reliable way of getting font size
    $theFrame.location configure -font [list underline]       ;#TODO: reliable way of getting font size
    pack $theFrame.location -anchor w
    $theFrame.location configure -cursor $Main::cursor_link
    bind $theFrame.location <ButtonRelease> {platformOpen $Pref::prefFile}
    
    
    #################### Keyboard tab ####################
    set page [$notebook insert end keyboard -text "Keyboard"]
    $notebook raise [$notebook page 0]
    set theFrame [frame $page.frame]
    pack $theFrame -fill both -expand 1
    
    # Scroll window content
    set sw [ScrolledWindow $theFrame.sv -background white ]
    set sf [ScrollableFrame $sw.scrollable -background white]
    $sw setwidget $sf
    set options [$sf getframe]
    
    # Headers
    xlabel $options.a -text "Keys" -background white
    $options.a configure -font [linsert [$options.a cget -font] end -size 11 -weight bold -underline true]     ;#TODO how do get real font size
    grid config $options.a -row 0 -column 0 -padx 2 -pady 2 -sticky "w"
    
    xlabel $options.b -text "Action" -background white
    $options.b configure -font [linsert [$options.b cget -font] end -size 11 -weight bold -underline true]     ;#TODO how do get real font size
    grid config $options.b -row 0 -column 1 -padx 16 -pady 2 -sticky "w"
    
    set i 1
    foreach keyAndAction $About::keystrokes {
        xlabel $options.a$i -text [lindex $keyAndAction 0] -background white
        $options.a$i configure -font [linsert [$options.a$i cget -font] end -size 9 -weight bold]     ;#TODO how do get real font size
        grid config $options.a$i -row $i -column 0 -padx 2 -sticky "w"
        
        xlabel $options.b$i -text [lindex $keyAndAction 1] -background white
        grid config $options.b$i -row $i -column 1 -padx 16 -sticky "w"
        
        incr i
    }
    pack $sw -fill both -expand 1 -padx 2
    
    #################### License tab ####################
    set page [$notebook insert end license -text "License"]
    $notebook raise [$notebook page 0]
    set theFrame [frame $page.frame]
    pack $theFrame -fill both -expand 1
    
    # Scroll window content
    set sw [ScrolledWindow $theFrame.sv -background white ]
    set sf [ScrollableFrame $sw.scrollable -background white]
    $sw setwidget $sf
    set license [$sf getframe]
    
    # Header
    xlabel $license.header -text "BSD 3-Clause License" -background white
    $license.header configure -font [linsert [$license.header cget -font] end -weight bold -underline true]
    
    # Read in dat license!
    set fp [open "LICENSE" r]
    xlabel $license.content -text "[read $fp]" -background white
    close $fp
    
    # Pack it in
    pack $license.header -expand 1
    pack $license.content -fill both -expand 1
    pack $sw -fill both -expand 1 -padx 2
    
    
    # Bindings for scrollviews
    eval bind .aboutDialog <4>         \" set_scroll_helper $notebook $sf %X %Y  -1 y \"
    eval bind .aboutDialog <5>         \" set_scroll_helper $notebook $sf %X %Y  1 y \"
    eval bind .aboutDialog <Control-4> \" set_scroll_helper $notebook $sf %X %Y -1 x \"
    eval bind .aboutDialog <Control-5> \" set_scroll_helper $notebook $sf %X %Y  1 x \"
}

proc platformOpen { whatwhat } {
    debug "Attempting to open  ${whatwhat}"
    if {$::PLATFORM == $::PLATFORM_WIN} {
        debugV "Opening on Windows"
        exec {*}[auto_execok start] "$whatwhat"
    } elseif {$::PLATFORM == $::PLATFORM_MAC} {
        debugV "Opening on Mac"
        exec "open" $whatwhat
    } else {
        debugV "Opening on Etc"
        if { [catch {exec "xdg-open" $whatwhat}] } {
            debugE "Could not open  $whatwhat"
        }
    }
}
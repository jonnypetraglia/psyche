package require Tk
clipboard append [zvfs::list *]
lappend ::auto_path [file dirname [zvfs::list */bwidget1.9.5/pkgIndex.tcl]]
package require BWidget
lappend ::auto_path [file dirname [zvfs::list */snit/pkgIndex.tcl]]
package require snit

proc debugV {arg} {
    puts $arg
}

proc debug {arg} {
    puts $arg
}

proc debugE {arg} {
    puts "DEBUG: $arg"
}


namespace eval Main {
    variable APP_VERSION
    variable APP_NAME
    variable APP_BUILD_DATE
    set APP_NAME Psyche
    set APP_VERSION 0.02
    set APP_BUILD_DATE "July 20, 2013"
    
    variable DEFAULT_PORT
    set DEFAULT_PORT 6667
    
    variable servers
    variable channelList
    
    variable descmenu
    variable bookmarkMenu
    variable mainframe
    variable toolbar
    variable status_text
    variable status_prog
    variable notebook
    variable nicklist
    
    variable toolbar
    variable toolbar_reconnect
    variable toolbar_disconnect
    variable toolbar_channellist
    variable toolbar_join
    variable toolbar_part
    variable toolbar_nick
    variable toolbar_properties
    variable toolbar_away
    variable toolbar_find

    variable default_tab_color
    
    variable hiddenToolbar
    variable meta_toolbar
    
    variable MIDDLE_CLICK
    
    variable findRegex
    variable findCase
    #variable findWord
}

set ::PLATFORM_MAC "macosx"
set ::PLATFORM_WIN "windows"
set ::PLATFORM_UNIX "unix"


set ::PLATFORM windows	;#TODO This should not be necessary
switch $tcl_platform(platform) {
    "unix" {
        if {$tcl_platform(os) == "Darwin"} {
            set ::PLATFORM $::PLATFORM_OSX
            set Main::MIDDLE_CLICK 2
        } else {
            set ::PLATFORM $::PLATFORM_UNIX
            set Main::MIDDLE_CLICK 3
        }
    }
    "windows" {
        set ::PLATFORM $::PLATFORM_WIN
        set Main::MIDDLE_CLICK 3
    }
}

if {$tcl_version >= 8.5 && $::PLATFORM != $::PLATFORM_MAC} {
    interp alias {} xbutton {} ttk::button
    interp alias {} xlabel {} ttk::label
    interp alias {} xentry {} ttk::entry
    interp alias {} xcheckbutton {} ttk::checkbutton
} else {
    interp alias {} xbutton {} button
    interp alias {} xlabel {} label
    interp alias {} xentry {} entry
    interp alias {} xcheckbutton {} checkbutton
}
source about.tcl
source pref.tcl
source irc.tcl
source sound.tcl
source tabServer.tcl
source tabChannel.tcl
source toolbar.tcl
source notebox.tcl

Pref::readPrefs
if [regexp {(.*)x(.*)} $Pref::popupLocation -> x y] {
    ::notebox::setposition $x $y
} else {
    option add *Notebox.anchor $Pref::popupLocation widgetDefault
}
option add *Notebox.millisecs $Pref::popupTimeout widgetDefault
option add *Notebox.font $Pref::popupFont widgetDefault
option add *Notebox.Message.width 500


#font create myDefaultFont -family Helvetica -size 10
#option add *font {-family Helvetica -size 10}

proc Main::init { } {
    file mkdir $Pref::CONFIG_DIR
    
    #set top [toplevel .intro -relief raised -borderwidth 2]
    #BWidget::place $top 0 0 center
    
    #Commands menus
    #Url Catcher
    #Channel List
    #Logfile
    
    # Menu description
    if { false || true } {
        set Main::descmenu {
            "&File" all file 0 {
            {command "E&xit" {} "Exit BWidget demo" {} -command exit}
            }
            "&Options" all options 0 {
            {checkbutton "Toolbar &1" {all option} "Show/hide toolbar 1" {}
                -variable Main::toolbar
                -command  {$Main::mainframe showtoolbar 0 $Main::toolbar}
            }
            }
        }
    }
    
    
    # Status Bar & Toolbar
    set Main::mainframe [MainFrame .mainframe]
                       #-menu         $Main::descmenu]
    
    
    # Create status bar
        # Modified version of MainFrame::addindicator
    if {[string length [Widget::getoption .mainframe -statusbarfont]]} {
        set sbfnt [list -font [Widget::getoption .mainframe -statusbarfont]]
    } else {
        set sbfnt {}
    }
    set indic $Main::mainframe.status.lastpinged
    eval label $indic -textvariable Main::status_text -anchor e \
        -relief sunken -borderwidth 1 \
        -takefocus 0 -highlightthickness 0 $sbfnt
    pack $indic -anchor w -padx 2 -fill x -expand 1
    
   
    init_toolbar
    
    # NoteBook creation
    set frame    [$Main::mainframe getframe]
    set Main::notebook [NoteBook $frame.nb]
    $Main::notebook bindtabs <1> { Main::pressTab }
    $Main::notebook bindtabs <ButtonRelease-$Main::MIDDLE_CLICK> { Main::tabContext %x %y}
    
    
    $Main::notebook compute_size
    pack $Main::notebook -fill both -expand yes -padx 4 -pady 4
    $Main::notebook raise [$Main::notebook page 0]
    pack $Main::mainframe -fill both -expand yes
    
    
    wm iconphoto . -default [image create photo -file $About::icondir/butterfly-icon_48.gif]
    set Main::servers(1) [tabServer %AUTO%]
    $Main::notebook compute_size
    wm title . "$Main::APP_NAME v$Main::APP_VERSION"
    
    # Measure the GUI
    bind . <Configure> { 
        if {"%W" == ".mainframe.status.prgf"} {
            bind . <Configure> ""
            wm minsize . [winfo width .] [winfo height .]
            debug "MinSize: [winfo width .]x[winfo height .]"
        }
    }
    set Main::default_tab_color [$Main::notebook itemcget [$Main::servers(1) getId] -background]
    $Main::notebook delete [$Main::servers(1) getId] 1
    destroy Main::servers(1)
    unset Main::servers(1)
    
    # Find
    if {$::PLATFORM == $::PLATFORM_MAC} {
        bind . <Command-F> { Main::find }
        bind . <Command-f> { Main::find }
        bind . <Command-G> { Main::findNext }
        bind . <Command-g> { Main::findNext }
    } else {
        bind . <Control-F> { Main::find }
        bind . <Control-f> { Main::find }
        bind . <F3>        { Main::findNext }
    }
    
    # Create the tab menu
    menu .tabMenu -tearoff false -title Bookmarks
    .tabMenu add command -label "Join channel" -command Main::showJoinDialog
    .tabMenu add command -label "Part or Quit" -command Main::partOrQuit
    .tabMenu add command -label "Close tab" -command Main::closeTabFromGui
    
    # Create the nicklist menu
    menu .nicklistMenu -tearoff false -title Bookmarks
    .nicklistMenu add command -label "PM" -command Main::NLpm 
    .nicklistMenu add separator
    .nicklistMenu add command -label "Whois" -command {Main::NLcmd "/whois "}
    .nicklistMenu add command -label "Version" -command {Main::NLcmd "/version "}
    .nicklistMenu add command -label "Ping" -command {Main::NLcmd "/ping "}
    # Modes submenu
    menu .nicklistMenu.modes
    .nicklistMenu.modes add command -label "Give Op" -command "Main::NLmode +o"
    .nicklistMenu.modes add command -label "Take Op" -command "Main::NLmode -o"
    .nicklistMenu.modes add command -label "Give HalfOp" -command "Main::NLmode +h"
    .nicklistMenu.modes add command -label "Take HalfOp" -command "Main::NLmode -h"
    .nicklistMenu.modes add command -label "Give Voice" -command "Main::NLmode +v"
    .nicklistMenu.modes add command -label "Take Voice" -command "Main::NLmode -v"
    .nicklistMenu add cascade -label "Modes" -menu .nicklistMenu.modes
    # Ban submenu
    menu .nicklistMenu.kickban
    .nicklistMenu.kickban add command -label "Kick" -command "Main::NLkick"
    .nicklistMenu.kickban add command -label "Ban" -command "Main::NLban"
    .nicklistMenu.kickban add command -label "KickBan" -command "Main::NLkickban"
    .nicklistMenu.kickban add separator
    .nicklistMenu.kickban add command -label "Ban *!*@*.host" -command "Main::NLban *!*@*.host false"
    .nicklistMenu.kickban add command -label "Ban *!*@domain" -command "Main::NLban *!*@domain false"
    .nicklistMenu.kickban add command -label "Ban *!user@*.host" -command "Main::NLban *!user@*.host false"
    .nicklistMenu.kickban add command -label "Ban *!user@domain" -command "Main::NLban *!user@domain false"
    .nicklistMenu.kickban add separator
    .nicklistMenu.kickban add command -label "Kickban *!*@*.host" -command "Main::NLban *!*@*.host true"
    .nicklistMenu.kickban add command -label "Kickban *!*@domain" -command "Main::NLban *!*@domain true"
    .nicklistMenu.kickban add command -label "Kickban *!user@*.host" -command "Main::NLban *!user@*.host true"
    .nicklistMenu.kickban add command -label "Kickban *!user@domain" -command "Main::NLban *!user@domain true"
    .nicklistMenu add cascade -label "Kick/Ban" -menu .nicklistMenu.kickban
    .nicklistMenu add command -label "Ignore" -command {Main::NLcmd "/ignore"}
    .nicklistMenu add command -label "Watch" -command {Main::NLcmd "/watch +"}
    
    wm protocol . WM_DELETE_WINDOW {
    #wm command . [expr {"0x111"}]
    #if { [tk_messageBox -type yesno -icon question -message "Are you sure you want to quit?"] != "no" } {
        exit
    #}
    }
    bind . <Activate> {
        Main::unsetTabMention
    }
    
    # Change to tab
    if { $::PLATFORM == $::PLATFORM_MAC } {
        for {set i 1} {$i < 10} {incr i} {
            bind . <Command-KeyPress-$i> "Main::changeToTab [expr {$i -1}]"
        }
        bind . <Command-KeyPress-0> "Main::changeToTab 9]"
    } else {
        for {set i 1} {$i < 10} {incr i} {
            bind . <Alt-KeyPress-$i> "Main::changeToTab [expr {$i -1}]"
        }
        bind . <Alt-KeyPress-0> "Main::changeToTab 9"
    }
    
    # Toggle Toolbar
    set Main::hiddenToolbar [expr {$Pref::toolbarHidden}]
    if { $Main::hiddenToolbar} { Main::toggleToolbar }
    bind . <F10> { Main::toggleToolbar }
}

proc Main::changeToTab {i} {
    if { $i < [llength [$Main::notebook pages]] } {
        $Main::notebook raise [$Main::notebook page $i]
    }
}

proc Main::find {} {
    if {[llength [$Main::notebook pages]] == 0} {
        return
    }
    
    if [winfo exists .findDialog] {
        #if {[wm state .findDialog] == "withdrawn"} {
            wm state .findDialog normal
        #}
        return
    }
    toplevel .findDialog -padx 10 -pady 10
    wm title .findDialog "Find"
    wm transient .findDialog .
    wm resizable .findDialog 0 0
    
    # Fields
    xlabel .findDialog.l_find -text "Find what:"
    xentry .findDialog.find -width 40
    
    # Checkboxes
    frame .findDialog.chkboxes
    xcheckbutton .findDialog.regex -text "Regex"      -variable Main::findRegex
    xcheckbutton .findDialog.case -text "Match case"  -variable Main::findCase
    #xcheckbutton .findDialog.word -text "Match word"  -variable Main::findWord
    
    # Buttons
    xbutton .findDialog.next -text "Find Next"
    xbutton .findDialog.previous -text "Find Previous"
    xbutton .findDialog.mark -text "Mark All"
    
    grid config .findDialog.l_find      -row 0 -column 0 -padx 5 -sticky "w"
    grid config .findDialog.find        -row 0 -column 1 -padx 5 -columnspan 3

    grid config .findDialog.regex       -row 1 -column 1 -padx 5
    grid config .findDialog.case        -row 1 -column 2 -padx 5
    #grid config .findDialog.word        -row 1 -column 3 -padx 5

    grid config .findDialog.next        -row 0 -column 6 -padx 5 -sticky "ew"
    grid config .findDialog.previous    -row 1 -column 6 -padx 5 -sticky "ew"
    grid config .findDialog.mark        -row 2 -column 6 -padx 5 -sticky "ew"
    
    bind .findDialog.mark <ButtonPress> { Main::markAll}
    bind .findDialog.next <ButtonPress> { Main::doFind [list -forwards]}
    bind .findDialog.previous <ButtonPress> { Main::doFind  [list -backwards]}
    bind .findDialog.find <Return> { Main::doFind "-forwards"}
    bind .findDialog.find <Shift-Return> { Main::doFind "-backwards"}
    
    wm protocol .findDialog WM_DELETE_WINDOW {
        set servs [array names Main::servers]
        foreach s $servs {
            $Main::servers($s) findClearAndChildren
        }
        wm state .findDialog withdrawn
    }
    
    Main::foreground_win .findDialog
}

proc Main::doFind { direction } {
    set target [$Main::notebook raise]
    if {[string length $target] == 0} {
        return
    }
    regsub -all "__" $target "*" target
    set parts [split $target "\*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    set chan [lindex $parts 1]

    set switches [list]

    if {[info exists Main::findRegex] && $Main::findRegex} {
        lappend switches "-regexp"
    }
    if {![info exists Main::findCase] || !$Main::findCase} {
        lappend switches "-nocase"
    }
    #if {$Main::findWord} {
    #    lappend args "-regexp"
    #}
    
    $Main::servers($serv) find $chan $direction $switches [.findDialog.find get]
}

proc Main::markAll {} {
    set target [$Main::notebook raise]
    if {[string length $target] == 0} {
        return
    }
    regsub -all "__" $target "*" target
    set parts [split $target "\*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    set chan [lindex $parts 1]
    
    set switches [list]
    if {[info exists Main::findRegex] && $Main::findRegex} {
        lappend switches "-regexp"
    }
    if {[info exists Main::findCase] && !$Main::findCase} {
        lappend switches "-nocase"
    }
    #if {$Main::findWord} {
    #    lappend args "-regexp"
    #}
    $Main::servers($serv) findMarkAll $chan $switches [.findDialog.find get]
}

proc Main::doFindNext { switches } {
    set target [$Main::notebook raise]
    if {[string length $target] == 0} {
        return
    }
    regsub -all "__" $target "*" target
    set parts [split $target "\*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    set chan [lindex $parts 1]

    $Main::servers($serv) findNext $chan
}

proc Main::findNext {} {
    set target [$Main::notebook raise]
    if {[string length $target] == 0} { return }
    regsub -all "__" $target "*" target
    set parts [split $target "\*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    set chan [lindex $parts 1]

    $Main::servers($serv) findNext $chan
}

proc Main::NLpm {} {
    set target [$Main::notebook raise]
    regsub -all "__" $target "*" target
    set parts [split $target "\*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    set chan [lindex $parts 1]

    set theNick [$Main::servers($serv) getSelectedNickOfChannel $chan]

    $Main::servers($serv) createPMTabIfNotExist $theNick
}

proc Main::NLcmd {the_cmd} {
    set target [$Main::notebook raise]
    regsub -all "__" $target "*" target
    set parts [split $target "\*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    set chan [lindex $parts 1]
    
    set theNick [$Main::servers($serv) getSelectedNickOfChannel $chan]
    
    $Main::servers($serv) sendMessage "$the_cmd$theNick"
}

proc Main::NLmode {the_mode} {
    set target [$Main::notebook raise]
    regsub -all "__" $target "*" target
    set parts [split $target "\*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    set chan [lindex $parts 1]
    
    set theNick [$Main::servers($serv) getSelectedNickOfChannel $chan]
    $Main::servers($serv) sendMessage "/mode $chan $the_mode $theNick"
}

proc Main::NLkick {} {
}
proc Main::NLban {bantype shouldkick} {
    set target [$Main::notebook raise]
    regsub -all "__" $target "*" target
    set parts [split $target "\*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    set chan [lindex $parts 1]
    
    set theNick [$Main::servers($serv) getSelectedNickOfChannel $chan]
    $Main::servers($serv) requestBan $theNick $chan $bantype $shouldkick $Pref::defaultBan
}


proc Main::closeTabFromGui {} {
    set target [$Main::notebook raise]
    Main::closeTab $target
}

proc Main::closeTab {target} {
    regsub -all "__" $target "*" target2
    set parts [split $target2 "\*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    set chan [lindex $parts 1]
    
    set tabIndex [$Main::notebook index $target]
    if { $tabIndex == [expr {[llength [$Main::notebook pages]] - 1}]} {
        set tabIndex [expr {$tabIndex -1}]
    }
    
    if {[string length $chan] > 0} {
        $Main::servers($serv) closeChannel $chan
    } else {
        $Main::servers($serv) quit $Pref::defaultQuit
        $Main::servers($serv) closeAllChannelTabs
        $Main::notebook delete $target
        $Main::servers($serv) closeLog
        destroy Main::servers($serv)
        unset Main::servers($serv)
    }
    
    if {[llength [$Main::notebook pages]] == 0} {
        Main::clearToolbar
    } else {
        $Main::notebook raise [$Main::notebook page $tabIndex]
    }
}

proc Main::pressTab { args} {
    set parts [split $args "\*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    set chan [lindex $parts 1]
    
    if [info exists Main::servers($serv)] {
        $Main::servers($serv) updateToolbar $chan
    }
    Main::unsetTabMention
    Main::updateStatusbar
}

proc Main::updateStatusbar {} {
    set target [$Main::notebook raise]
    if {[string length $target] == 0} {
        return
    }
    regsub -all "__" $target "*" target
    set parts [split $target "*"]
    set serv [lindex $parts 0]
    set chan [lindex $parts 1]
    regsub -all "_" $serv "." serv

    set pingtime [$Main::servers($serv) getPingtime]
    if {$pingtime == 0} {
        set Main::status_text "Disconnected"
    }
    
    set pingtime [expr {[clock seconds] - $pingtime}]
    if {$pingtime < 90} {
        set Main::status_text "Last Ping: $pingtime seconds ago"
    } else {
        set pingtime [expr {$pingtime / 60}]
        set Main::status_text "Last Ping: $pingtime minutes ago"
    }
    
}

proc Main::updateStatusbarTimer {} {
    after [expr {1000 * 60}] {
        Main::updateStatusbar
        Main::updateStatusbarTimer
    }
}

proc Main::unsetTabMention {} {
    if { [string length [$Main::notebook raise]] > 0} {
        $Main::notebook itemconfigure [$Main::notebook raise] -background $Main::default_tab_color
    }
}

proc Main::tabContext { x y tabId } {
    $Main::notebook raise $tabId
    Main::pressTab $tabId
    tk_popup .tabMenu [expr [winfo rootx .] + $x] [expr [winfo rooty .] + $y + 50]
}

proc Main::pressAway { args } {
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    set chan [lindex $parts 1]
    
    $Main::servers($serv) toggleAway
}

proc Main::updateAwayButton {} {
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    set chan [lindex $parts 1]
    
    $Main::servers($serv) updateToolbarAway $chan
}

proc Main::showConnectDialog { } {
    
    destroy .connectDialog
    toplevel .connectDialog -padx 10 -pady 10
    wm title .connectDialog "Connect"
    wm transient .connectDialog .
    wm resizable .connectDialog 0 0
    
    xlabel .connectDialog.l_serv -text "Server"
    xentry .connectDialog.serv -width 20
    .connectDialog.serv configure -background white
    xlabel .connectDialog.l_port -text "Port"
    xentry .connectDialog.port -width 10 -textvariable Main::DEFAULT_PORT
    .connectDialog.port configure -background white
    xlabel .connectDialog.l_nick -text "Nick"
    xentry .connectDialog.nick -width 20
    .connectDialog.nick configure -background white
    xbutton .connectDialog.go -text "Connect"
    
    grid config .connectDialog.l_serv -row 0 -column 0 -sticky "w"
    grid config .connectDialog.serv   -row 1 -column 0
    grid config .connectDialog.l_port -row 0 -column 1 -sticky "w"
    grid config .connectDialog.port   -row 1 -column 1
    grid config .connectDialog.l_nick -row 2 -column 0 -sticky "w"
    grid config .connectDialog.nick   -row 3 -column 0
    grid config .connectDialog.go     -row 3 -column 1
    bind .connectDialog.go <ButtonPress> Main::connectDialogConfirm
    
    foreground_win .connectDialog
    catch {grab release .}
    catch {grab set .connectDialog}
}

proc Main::showJoinDialog { } {
    global DEFAULT_PORT;
    
    destroy .joinDialog
    toplevel .joinDialog -padx 10 -pady 10
    wm title .joinDialog "Join"
    wm transient .joinDialog .
    wm resizable .joinDialog 0 0
    
    xlabel .joinDialog.l_chan -text "Channel"
    xentry .joinDialog.chan -width 20
    .joinDialog.chan configure -background white
    xbutton .joinDialog.go -text "Join"
    
    grid config .joinDialog.l_chan -row 0 -column 0 -sticky "w"
    grid config .joinDialog.chan   -row 1 -column 0
    grid config .joinDialog.go     -row 1 -column 1
    bind .joinDialog.go <ButtonPress> Main::joinChannel
    
    foreground_win .joinDialog
    catch {grab release .}
    catch {grab set .joinDialog}
}

proc Main::joinChannel {} {
    set chan [.joinDialog.chan get]
    if { [string length $chan] == 0 } {
        debugE "Main::joinChannel - Insufficient data"
        tk_messageBox -message "Insufficient data" -parent .connectDialog -title "Error"
        return
    }
    catch {grab release .joinDialog}
    catch {grab set .}
    wm state .joinDialog withdrawn
    
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    
    if { [string length [$Main::servers($serv) getconnDesc]] > 0 } {
        $Main::servers($serv) _send "JOIN $chan"
        #$Main::servers($serv) joinChan $chan ""
    }
}

# serv should be the raw server, i.e. irc.geekshed.net, NOT irc_geekshed_net
proc Main::createConnection {serv por nick} {
    if [info exists Main::servers($serv)] {
        if { [string length [$Main::servers($serv) getconnDesc]] > 0 } { 
            $Main::servers($serv) handleReceived [$Main::servers($serv) getTimestamp] \[Nope\] bold "Dude you are already connected" ""
        } else {
            $Main::servers($serv) _setData $por $nick
            $Main::servers($serv) initServer
        }
    } else {
        set Main::servers($serv) [tabServer %AUTO% $serv $por $nick]
    }
    .tabMenu unpost
    $Main::notebook raise [$Main::servers($serv) getId]
}

proc Main::connectDialogConfirm {} {
    set serv [.connectDialog.serv get]
    set por [.connectDialog.port get]
    set nick [.connectDialog.nick get]
    if [ expr { [string length $serv] == 0 || \
        [string length $por] == 0  || \
        [string length $nick] == 0}] {
    debugE "Main::connectDialogConfirm - Insufficient data"
        tk_messageBox -message "Insufficient data" -parent .connectDialog -title "Error"
        return
    }
    catch {grab release .connectDialog}
    catch {grab set .}
    wm state .connectDialog withdrawn

    Main::createConnection $serv $por $nick
}

proc Main::reconnect {} {
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    set chan [lindex $parts 1]
    regsub -all "_" $serv "." serv
    $Main::servers($serv) initServer
}

proc Main::disconnect {} {
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    set chan [lindex $parts 1]
    regsub -all "_" $serv "." serv
    $Main::servers($serv) quit $Pref::defaultQuit
}

proc Main::partOrQuit {} {
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    set chan [lindex $parts 1]
    regsub -all "_" $serv "." serv
    debug "partOrQuit: [array names Main::servers]"
    if {[string length $chan]>0} {
        $Main::servers($serv) part $chan $Pref::defaultPart
    } else {
        $Main::servers($serv) quit $Pref::defaultQuit
    }
}

proc Main::part {} {
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    set chan [lindex $parts 1]
    regsub -all "_" $serv "." serv
    $Main::servers($serv) part $chan $Pref::defaultPart
}

proc Main::channelList {} {
    variable chanL
    
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    if { ![info exists Main::channelList($serv)] } {
        set Main::channelList($serv) [list]
        $Main::servers($serv) _send LIST
    } else {
        if { [llength $Main::channelList($serv) ] == 0 } {
            set Main::channelList($serv) [list]
            $Main::servers($serv) _send LIST
        }
    }

    destroy .channelList
    toplevel .channelList -padx 10 -pady 10
    wm title .channelList "Channel List"
    wm transient .channelList .
    wm resizable .channelList 400 300

    set nicklistCtrl [listbox .channelList.lb -listvariable Main::channelList($serv) \
            -height 20 -width 40 -highlightthickness 0 \
            -font [list Courier 12] ]
    button .channelList.join -text "Join"
    button .channelList.refresh -text "Refresh"
    bind .channelList.lb <Double-1> Main::joinChannelList
    bind .channelList.join <ButtonPress> Main::joinChannelList
    bind .channelList.refresh <ButtonPress> Main::refreshChannelList
    
    pack .channelList.lb -fill both -expand 1
    pack .channelList.join -fill both -expand 0
    pack .channelList.refresh -fill both -expand 0
    
    foreground_win .channelList
    catch {grab release .}
    catch {grab set .channelList}
}

proc Main::joinChannelList {} {
    set chanName [.channelList.lb get [.channelList.lb curselection] ]
    regexp {(#[^ ]+) .*} $chanName -> chanName

    catch {grab release .channelList}
    catch {grab set .}
    wm state .channelList withdrawn
    
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    $Main::servers($serv) joinChan $chanName ""
}

proc Main::refreshChannelList {} {
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    
    # Clear the list & update
    set Main::channelList($serv) [list]
    $Main::servers($serv) _send LIST
}

proc Main::showNickDialog {} {
    destroy .nickDialog
    toplevel .nickDialog -padx 10 -pady 10
    wm title .nickDialog "Change Nick"
    wm transient .nickDialog .
    wm resizable .nickDialog 0 0
    
    xlabel .nickDialog.l_nick -text "New Nick"
    xentry .nickDialog.nick -width 20
    xlabel .nickDialog.l_pass -text "NickServ pass\n(if registered)"
    xentry .nickDialog.pass -width 20
    .nickDialog.nick configure -background white
    xbutton .nickDialog.change -text "Change"
    
    grid config .nickDialog.l_nick -row 0 -column 0 -sticky "w"
    grid config .nickDialog.nick   -row 0 -column 1
    grid config .nickDialog.l_pass -row 1 -column 0 -sticky "w"
    grid config .nickDialog.pass   -row 1 -column 1
    grid config .nickDialog.change     -row 2 -column 1
    bind .nickDialog.change <ButtonPress> Main::nickDialogConfirm
    
    foreground_win .nickDialog
    catch {grab release .}
    catch {grab set .nickDialog}
}

proc Main::nickDialogConfirm {} {
    set newnick [.nickDialog.nick get]
    set newpass [.nickDialog.pass get]
    wm state .nickDialog withdrawn

    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    
    $Main::servers($serv) _send "NICK $newnick"
    if {[string length $newpass] > 0 } {
        $Main::servers($serv) _send "PRIVMSG NickServ identify $newpass"
    }
}

proc Main::showProperties {} {
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    set chan [lindex $parts 1]
    regsub -all "_" $serv "." serv
    $Main::servers($serv) showProperties $chan
}

proc Main::openBookmark {target} {
    set serv [lindex $Pref::bookmarks($target) 0]
    set por [lindex $Pref::bookmarks($target) 1]
    set nic [lindex $Pref::bookmarks($target) 2]
    Main::createConnection $serv $por $nic
    if { [string length [$Main::servers($serv) getconnDesc]] > 0} {
        for {set x 3} {$x<[llength $Pref::bookmarks($target)]} {incr x} {
            $Main::servers($serv) _send "JOIN [lindex $Pref::bookmarks($target) $x]"
        }
    }
}

proc Main::foreground_win { w } {
    wm withdraw $w
    wm deiconify $w
}

#http://www.tek-tips.com/viewthread.cfm?qid=1668522
proc set_close_bindings {notebook page} {
    $notebook.c bind $page:img <ButtonPress-1> "+; 
    $notebook.c move $page:img 1 1
    set pressed \[%W find closest %x %y]
    "
    $notebook.c bind $page:img <ButtonRelease-1> "+; 
    $notebook.c move $page:img -1 -1
    if {\$pressed==\[%W find closest %x %y]} {
        set pressed \"\"
        Main::closeTab $page
    }
    "
}

proc set_scroll_helper {notebookctl widget x y dir xory} {
    set widgetUnderMouse [winfo containing $x $y]
    if [regexp {(.*\.scrollable).*$} $widgetUnderMouse -> scrollControl] {
        $scrollControl ${xory}view scroll $dir units
    }
}

proc startsWith {haystack needle} {
    return [string equal [string range $haystack 0 [expr {[string length $needle]}]] $needle]
}

Main::init
#toplevel .channelList -padx 10 -pady 10
#wm state .channelList withdrawn
Main::updateStatusbarTimer
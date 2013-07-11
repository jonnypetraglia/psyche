package require Tk
package require BWidget
package require snit

proc debug {arg} {
    puts $arg
}

proc debugE {arg} {
    puts "DEBUG: $arg"
}


namespace eval Main {
    variable APP_VERSION
    variable APP_NAME
    set APP_NAME Psyche
    set APP_VERSION 0.02

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
}

set ::this(platform) windows	;#TODO This should not be necessary
switch $tcl_platform(platform) {
    "unix" {
	if {$tcl_platform(os) == "Darwin"} {
	    set ::this(platform) macosx
	} else {
	    set ::this(platform) unix
	}
    }
    "windows" {
	set ::this(platform) windows
    }
}
source pref.tcl
source irc.tcl
source tabServer.tcl
source tabChannel.tcl
source toolbar.tcl
source notebox.tcl
puts $Pref::popupLocation

Pref::readPrefs
if [regexp {(.*)x(.*)} $Pref::popupLocation -> x y] {
    puts "DERP: $x"
    ::notebox::setposition $x $y
} else {
    option add *Notebox.anchor $Pref::popupLocation widgetDefault
}
option add *Notebox.millisecs $Pref::popupTimeout widgetDefault
option add *Notebox.font $Pref::popupFont widgetDefault
option add *Notebox.Message.width 500



proc Main::init { } {
    variable mainframe

    
    #set top [toplevel .intro -relief raised -borderwidth 2]
    #BWidget::place $top 0 0 center
    
	#Commands menus
	#Url Catcher
	#Channel List
	#Logfile
    
    # Menu description
    if false {
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
    set mainframe [MainFrame .mainframe \
                       -textvariable Main::status_text \
                       -progressvar  Main::status_prog]
                       #-menu         $Main::descmenu]
   
    #$mainframe addindicator -text "BWidget [package version BWidget]"
    #$mainframe addindicator -textvariable tk_patchLevel
    init_toolbar
    
    # NoteBook creation
    set frame    [$Main::mainframe getframe]
    set Main::notebook [NoteBook $frame.nb]
    $Main::notebook bindtabs <1> { Main::pressTab }
    $Main::notebook bindtabs <ButtonRelease-3> { Main::tabContext %x %y}
    
    
    $Main::notebook compute_size
    pack $Main::notebook -fill both -expand yes -padx 4 -pady 4
    $Main::notebook raise [$Main::notebook page 0]
    pack $Main::mainframe -fill both -expand yes
    
    
    set icondir [pwd]/icons
    wm iconphoto . -default [image create photo -file $icondir/butterfly-icon_48.gif]
    set Main::servers(1) [tabServer %AUTO%]
    $Main::notebook compute_size
    wm title . "$Main::APP_NAME v$Main::APP_VERSION"
    
    # Measure the GUI
    bind . <Configure> { 
	if {"%W" == ".mainframe.status.prgf"} {
	    bind . <Configure> ""
	    wm minsize . [winfo width .] [winfo height .]
	    puts "MinSize: [winfo width .]x[winfo height .]"
	}
    }
    $Main::notebook delete [$Main::servers(1) getId] 1
    unset Main::servers(1)
    
    
    # Create the tab menu
    menu .tabMenu -tearoff false -title Bookmarks
    .tabMenu add command -label "Join channel" -command Main::showJoinDialog
    .tabMenu add command -label "Part channel" -command Main::part
    .tabMenu add command -label "Close tab" -command Main::closeTab
    
    #set Main::servers(1) [tab %AUTO% irc.geekshed.net 6667 byteslol]
    #$Main::notebook raise [$Main::servers(1) getId]
    #$Main::servers(1) joinChan #jupiterBroadcasting
}

proc Main::closeTab {} {
    set target [$Main::notebook raise]
    set parts [split $target "\*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    set chan [lindex $parts 1]
    
    puts "closing: $serv $chan"
    
    if {[string length $chan] > 0} {
	Main::part
	$Main::servers($serv) closeChannel $chan
    } else {
	Main::disconnect
	$Main::servers($serv) closeAllChannelTabs
	$Main::notebook delete $target
	unset Main::servers($serv)
    }
    
    if {[llength [$Main::notebook pages]] == 0} {
	Main::clearToolbar
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
    
    label .connectDialog.l_serv -text "Server"
    entry .connectDialog.serv -width 20
    .connectDialog.serv configure -background white
    label .connectDialog.l_port -text "Port"
    entry .connectDialog.port -width 10 -textvariable Main::DEFAULT_PORT
    .connectDialog.port configure -background white
    label .connectDialog.l_nick -text "Nick"
    entry .connectDialog.nick -width 20
    .connectDialog.nick configure -background white
    button .connectDialog.go -text "Connect"
    
    grid config .connectDialog.l_serv -row 0 -column 0 -sticky "w"
    grid config .connectDialog.serv   -row 1 -column 0
    grid config .connectDialog.l_port -row 0 -column 1 -sticky "w"
    grid config .connectDialog.port   -row 1 -column 1
    grid config .connectDialog.l_nick -row 2 -column 0 -sticky "w"
    grid config .connectDialog.nick   -row 3 -column 0
    grid config .connectDialog.go     -row 3 -column 1
    bind .connectDialog.go <ButtonPress> Main::connectDialogConfirm
    
    foreground_win .connectDialog
    grab release .
    grab set .connectDialog
}

proc Main::showJoinDialog { } {
    global DEFAULT_PORT;
    
    destroy .joinDialog
    toplevel .joinDialog -padx 10 -pady 10
    wm title .joinDialog "Join"
    wm transient .joinDialog .
    wm resizable .joinDialog 0 0
    
    label .joinDialog.l_chan -text "Channel"
    entry .joinDialog.chan -width 20
    .joinDialog.chan configure -background white
    button .joinDialog.go -text "Join"
    
    grid config .joinDialog.l_chan -row 0 -column 0 -sticky "w"
    grid config .joinDialog.chan   -row 1 -column 0
    grid config .joinDialog.go     -row 1 -column 1
    bind .joinDialog.go <ButtonPress> Main::joinChannel
    
    foreground_win .joinDialog
    grab release .
    grab set .joinDialog
}

proc Main::joinChannel {} {
    set chan [.joinDialog.chan get]
    if { [string length $chan] == 0 } {
	debugE "Main::joinChannel - Insufficient data"
    	tk_messageBox -message "Insufficient data" -parent .connectDialog -title "Error"
    	return
    }
    grab release .joinDialog
    grab set .
    wm state .joinDialog withdrawn
    
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    
    if { [string length [$Main::servers($serv) getconnDesc]] > 0 } {
        $Main::servers($serv) _send "JOIN $chan"
        #$Main::servers($serv) joinChan $chan ""
    }
}

proc Main::createConnection {serv por nick} {
    if [info exists Main::servers($serv)] {
        $Main::servers($serv) _setData $por $nick
        $Main::servers($serv) initServer
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
    grab release .connectDialog
    grab set .
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
    grab release .
    grab set .channelList
}

proc Main::joinChannelList {} {
    set chanName [.channelList.lb get [.channelList.lb curselection] ]
    regexp {(#[^ ]+) .*} $chanName -> chanName

    grab release .channelList
    grab set .
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
    
    label .nickDialog.l_nick -text "New Nick"
    entry .nickDialog.nick -width 20
    label .nickDialog.l_pass -text "NickServ pass\n(if registered)"
    entry .nickDialog.pass -width 20
    .nickDialog.nick configure -background white
    button .nickDialog.change -text "Change"
    
    grid config .nickDialog.l_nick -row 0 -column 0 -sticky "w"
    grid config .nickDialog.nick   -row 0 -column 1
    grid config .nickDialog.l_pass -row 1 -column 0 -sticky "w"
    grid config .nickDialog.pass   -row 1 -column 1
    grid config .nickDialog.change     -row 2 -column 1
    bind .nickDialog.change <ButtonPress> Main::nickDialogConfirm
    
    foreground_win .nickDialog
    grab release .
    grab set .nickDialog
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

Main::init
toplevel .channelList -padx 10 -pady 10
wm state .channelList withdrawn

package require Tk
package require snit
package require BWidget
package require irc

proc debug {arg} {
    puts $arg
}

#Icons: https://github.com/kgn/kgn_icons
#Logo:  http://www.iconarchive.com/show/free-spring-icons-by-ergosign/butterfly-icon.html

namespace eval Main {
    variable APP_VERSION
    variable APP_NAME
    set APP_VERSION 0.01
    set APP_NAME Psyche

    variable DEFAULT_PORT
    set DEFAULT_PORT 6667
    
    variable servers
    variable channelList
    
    variable descmenu
    variable mainframe
    variable toolbar
    variable status_text
    variable status_prog
    variable notebook
    variable nicklist
    
    variable toolbar_reconnect
    variable toolbar_disconnect
    variable toolbar_channellist
    variable toolbar_join
    variable toolbar_part
    variable toolbar_nick
    variable toolbar_properties
    variable toolbar_away
}

namespace eval Pref {
    variable raiseNewTabs
    set raiseNewTabs false
}

source tab.tcl
source toolbar.tcl


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
    $Main::notebook bindtabs <ButtonPress> { Main::pressTab }
    
    
    $Main::notebook compute_size
    pack $Main::notebook -fill both -expand yes -padx 4 -pady 4
    $Main::notebook raise [$Main::notebook page 0]
    pack $Main::mainframe -fill both -expand yes
    
    
    set icondir [pwd]/icons
    wm iconphoto . -default [image create photo -file $icondir/butterfly-icon_48.gif]
    set Main::servers(1) [tab %AUTO%]
    $Main::notebook compute_size
    wm title . "$Main::APP_NAME v$Main::APP_VERSION"
    wm minsize . [winfo width .] [winfo height .]
    $Main::notebook delete [$Main::servers(1) getId] 1
    unset Main::servers(1)
    
    #set Main::servers(1) [tab %AUTO% irc.geekshed.net 6667 byteslol]
    #$Main::notebook raise [$Main::servers(1) getId]
    #$Main::servers(1) joinChan #jupiterBroadcasting
}

proc Main::pressTab { args} {
    set parts [split $args "*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    set chan [lindex $parts 1]
    
    $Main::servers($serv) updateToolbar $chan
}

proc Main::showConnectDialog { } {
    
    destroy .connectDialog
    toplevel .connectDialog -padx 10 -pady 10
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
    	tk_messageBox -message "Insufficient data" -parent .connectDialog -title "Error"
    	return
    }
    grab release .joinDialog
    grab set .
    wm state .joinDialog withdrawn
    
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    
    $Main::servers($serv) joinChan $chan ""
}

proc Main::createConnection {serv por nick} {
    if [info exists Main::servers($serv)] {
        $Main::servers($serv) _setData $por $nick
        $Main::servers($serv) initServer
    } else {
        set Main::servers($serv) [tab %AUTO% SERV $serv $por $nick]
    }
    $Main::notebook raise [$Main::servers($serv) getId]
}

proc Main::connectDialogConfirm {} {
    set serv [.connectDialog.serv get]
    set por [.connectDialog.port get]
    set nick [.connectDialog.nick get]
    if [ expr { [string length $serv] == 0 || \
		[string length $por] == 0  || \
		[string length $nick] == 0}] {
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
    $Main::servers($serv) quit "Leavin"
}

proc Main::part {} {
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    set chan [lindex $parts 1]
    regsub -all "_" $serv "." serv
    $Main::servers($serv) part $chan "Leavin"
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
    wm transient .channelList .
    wm resizable .channelList 400 300

    set nicklistCtrl [listbox .channelList.lb -listvariable Main::channelList($serv) \
			-height 20 -width 40 -highlightthickness 0 \
			-font [list Courier 12] ]
    button .channelList.join -text "Join"
    button .channelList.refresh -text "Refresh"
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
    puts $chanName

    grab release .channelList
    grab set .
    wm state .channelList withdrawn
    
    set parts [split [$Main::notebook raise] "*"]
    set serv [lindex $parts 0]
    regsub -all "_" $serv "." serv
    $Main::servers($serv) joinChan $chanName
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
    wm transient .nickDialog .
    wm resizable .nickDialog 0 0
    
    label .nickDialog.l_nick -text "Channel"
    entry .nickDialog.nick -width 20
    .nickDialog.nick configure -background white
    button .nickDialog.change -text "Change"
    
    grid config .nickDialog.l_nick -row 0 -column 0 -sticky "w"
    grid config .nickDialog.nick   -row 1 -column 0
    grid config .nickDialog.change     -row 1 -column 1
    bind .nickDialog.change <ButtonPress> Main::nickDialogConfirm
    
    foreground_win .nickDialog
    grab release .
    grab set .nickDialog
}

proc Main::nickDialogConfirm {} {
    
}

proc Main::foreground_win { w } {
    wm withdraw $w
    wm deiconify $w
}

Main::init
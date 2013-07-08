proc Main::init_toolbar { } {
    set Main::toolbar  [$Main::mainframe addtoolbar]
    
    set icondir [pwd]/icons
    
        
    ### Connection ###
    set bbox [ButtonBox $Main::toolbar.bbox1 -spacing 0 -padx 1 -pady 1 -homogeneous 0]
    $bbox add -image [image create photo -file $icondir/connect.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Connect" \
        -command Main::showConnectDialog
    # Dropdown button
    $bbox add -image [image create bitmap %AUTO% -data {
	    #define plus_width 11
	    #define plus_height 11
	    static char plus_bits = {
		0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfe,
		0x03, 0xfc, 0x01, 0xf8, 0x00, 0x70, 0x00, 0x20, 0x00, 0x00, 0x00
	    }
	}] -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
	-command {
	    regexp {.*x([0-9]+)\+([0-9]+)\+([0-9]+)} [winfo geometry $Main::toolbar] -> wh wx wy
	    tk_popup .bookmarkMenu [expr [winfo rootx .] + $wx] [expr [winfo rooty .] + $wy + $wh]
	}
    set Main::toolbar_reconnect [\
    $bbox add -image [image create photo -file $icondir/reconnect.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Reconnect" -state disabled \
        -command Main::reconnect]
    set Main::toolbar_disconnect [\
    $bbox add -image [image create photo -file $icondir/disconnect.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Disconnect" -state disabled \
        -command Main::disconnect]
    set Main::toolbar_channellist [\
    $bbox add -image [image create photo -file $icondir/channels.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Channel List" -state disabled \
        -command Main::channelList]
    set Main::toolbar_nick [\
    $bbox add -image [image create photo -file $icondir/nick.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Change Nick" -state disabled \
        -command Main::showNickDialog]
    pack $bbox -side left -anchor w
    set sep [Separator $Main::toolbar.sep1 -orient vertical]
    pack $sep -side left -fill y -padx 4 -anchor w
        
    ### Server/Channel ###
    set bbox [ButtonBox $Main::toolbar.bbox2 -spacing 0 -padx 1 -pady 1]
    set Main::toolbar_join [\
    $bbox add -image [image create photo -file $icondir/join.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Join" -state disabled \
        -command Main::showJoinDialog]
    set Main::toolbar_part [\
    $bbox add -image [image create photo -file $icondir/part.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Part" -state disabled \
        -command Main::part]
    set Main::toolbar_properties [\
    $bbox add -image [image create photo -file $icondir/properties.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Server/Channel Properties" -state disabled \
        -command Main::showProperties]
    set Main::toolbar_away [\
    $bbox add -image [image create photo -file $icondir/away.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Away/Back" -state disabled \
        -command Main::pressAway]
    pack $bbox -side left -anchor w
    set sep [Separator $Main::toolbar.sep2 -orient vertical]
    pack $sep -side left -fill y -padx 4 -anchor w
    
    ### Etc ###
    set bbox [ButtonBox $Main::toolbar.bbox3 -spacing 0 -padx 1 -pady 1]  
    $bbox add -image [image create photo -file $icondir/find.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Find"
    $bbox add -image [image create photo -file $icondir/options.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Options"
        
    #Close Tab
    #Clear Screen?
        
    pack $bbox -side left -anchor w
}
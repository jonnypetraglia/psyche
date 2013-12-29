proc Main::hideToolbar {} {
    Log D "hideToolbar"
    $Main::mainframe showtoolbar 0 true
    $Main::mainframe showtoolbar 1 false
    bind ${Main::win} <F10> { Main::showToolbar }
}

proc Main::showToolbar {} {
    Log D "showToolbar"
    $Main::mainframe showtoolbar 0 false
    $Main::mainframe showtoolbar 1 true
    bind ${Main::win} <F10> { Main::hideToolbar }
}

proc Main::init_toolbar { } {
    #### Meta Toolbar ####
    set toolbar0  [$Main::mainframe addtoolbar]
    set bbox0 [ButtonBox $toolbar0.bbox -spacing 0 -padx 0 -pady 0 -homogeneous 0]
    $bbox0 add -image [image create bitmap meta0 -data {
        #define meta_width 16
        #define meta_height 11
        static char meta_bits = {
        0x00, 0x00,
        0x00, 0x00,
        0x20, 0x08,
        0x10, 0x04,
        0x08, 0x02,
        0x04, 0x01,
        0x08, 0x02,
        0x10, 0x04,
        0x20, 0x08,
        0x00, 0x00,
        0x00, 0x00
        }
    }] -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 0 -pady 0 \
    -command { Main::showToolbar }
    pack $bbox0 -side right -anchor e
    $Main::mainframe showtoolbar 0 false
    
    
    #### Main Toolbar ####
    set Main::toolbar  [$Main::mainframe addtoolbar]
    
    ### Meta button ###
    set bbox1 [ButtonBox $Main::toolbar.bbox0 -spacing 0 -padx 0 -pady 0 -homogeneous 0]
    $bbox1 add -image [image create bitmap meta1 -data {
        #define meta_width 16
        #define meta_height 11
        static char meta_bits = {
        0x00, 0x00,
        0x00, 0x00,
        0x00, 0x00,
        0x41, 0x41,
        0x22, 0x22,
        0x14, 0x14,
        0x08, 0x08,
        0x00, 0x00,
        0x00, 0x00,
        0x00, 0x00,
        0x00, 0x00
        }
    }] -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 0 -pady 0 \
    -command { Main::hideToolbar }
    pack $bbox1 -side right -anchor e
    
    ### Connection ###
    set bbox [ButtonBox $Main::toolbar.bbox -spacing 0 -padx 1 -pady 1 -homogeneous 0]
    $bbox add -image [image create photo -file $About::icondir/connect.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Connect" \
        -command Main::showConnectDialog
    # Dropdown button
    $bbox add -image [image create bitmap bookmarksdropdown -data {
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
    $bbox add -image [image create photo -file $About::icondir/reconnect.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Reconnect" -state disabled \
        -command Main::reconnect]
    set Main::toolbar_disconnect [\
    $bbox add -image [image create photo -file $About::icondir/disconnect.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Disconnect" -state disabled \
        -command Main::disconnect]
    set Main::toolbar_channellist [\
    $bbox add -image [image create photo -file $About::icondir/channels.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Channel List" -state disabled \
        -command Main::channelList]
    set Main::toolbar_nick [\
    $bbox add -image [image create photo -file $About::icondir/nick.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Change Nick" -state disabled \
        -command Main::showNickDialog]
    pack $bbox -side left -anchor w
    set sep [Separator $Main::toolbar.sep1 -orient vertical]
    pack $sep -side left -fill y -padx 4 -anchor w
        
    ### Server/Channel ###
    set bbox [ButtonBox $Main::toolbar.bbox2 -spacing 0 -padx 1 -pady 1]
    set Main::toolbar_join [\
    $bbox add -image [image create photo -file $About::icondir/join.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Join" -state disabled \
        -command Main::showJoinDialog]
    set Main::toolbar_part [\
    $bbox add -image [image create photo -file $About::icondir/part.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Part" -state disabled \
        -command Main::part]
    set Main::toolbar_properties [\
    $bbox add -image [image create photo -file $About::icondir/properties.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Server/Channel Properties" -state disabled \
        -command Main::showProperties]
    set Main::toolbar_away [\
    $bbox add -image [image create photo -file $About::icondir/away.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Away/Back" -state disabled \
        -command Main::pressAway]
    pack $bbox -side left -anchor w
    set sep [Separator $Main::toolbar.sep2 -orient vertical]
    pack $sep -side left -fill y -padx 4 -anchor w
    
    ### Etc ###
    set bbox [ButtonBox $Main::toolbar.bbox3 -spacing 0 -padx 1 -pady 1]  
    set Main::toolbar_find [\
    $bbox add -image [image create photo -file $About::icondir/find.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Find" -state disabled \
        -command Main::find]
    $bbox add -image [image create photo -file $About::icondir/options.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Preferences" \
        -command Pref::show
    $bbox add -image [image create photo -file $About::icondir/about.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "About" \
        -command About::show
        
    #Close Tab
    #Clear Screen?
    
    pack $bbox -side left -anchor w
}

proc Main::clearToolbar {} {
    $Main::toolbar_join configure -state disabled
    $Main::toolbar_disconnect configure -state disabled
    $Main::toolbar_reconnect configure -state disabled
    $Main::toolbar_properties configure -state disabled
    $Main::toolbar_channellist configure -state disabled
    $Main::toolbar_nick configure -state disabled
    $Main::toolbar_away configure -state disabled
    $Main::toolbar_away configure -image [image create photo -file $About::icondir/away.gif]
    $Main::toolbar_find configure -state disabled
}
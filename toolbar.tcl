proc Main::metaToolbar {} {
    # Meta toolbar
    set toolbar2  [$Main::mainframe addtoolbar]
    set bbox2 [ButtonBox $toolbar2.bbox1 -spacing 0 -padx 0 -pady 0 -homogeneous 0]
    set Main::meta_toolbar [\
    $bbox2 add -image [image create bitmap metameta -data {
        #define plus2_width 16
        #define plus2_height 11
        static char plus2_bits = {
        0x00, 0x00,
        0x00, 0x00,
        0x10, 0x02,
        0x20, 0x04,
        0x40, 0x08,
        0x80, 0x10,
        0x40, 0x08,
        0x20, 0x04,
        0x10, 0x02,
        0x00, 0x00,
        0x00, 0x00
        }
    }] -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 0 -pady 0 \
    -command { Main::toggleToolbar }]
    pack $bbox2 -side left -anchor w
    
}

proc Main::toggleToolbar {} {
    set Main::hiddenToolbar [expr {!$Main::hiddenToolbar}]
    $Main::mainframe showtoolbar 1 $Main::hiddenToolbar
    if { $Main::hiddenToolbar } {
        $Main::meta_toolbar configure -image [image create bitmap metameta -data {
            #define plus2_width 16
            #define plus2_height 11
            static char plus2_bits = {
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
        }]
    } else {
        $Main::meta_toolbar configure -image [image create bitmap metameta -data {
            #define plus2_width 16
            #define plus2_height 11
            static char plus2_bits = {
            0x00, 0x00,
            0x00, 0x00,
            0x10, 0x02,
            0x20, 0x04,
            0x40, 0x08,
            0x80, 0x10,
            0x40, 0x08,
            0x20, 0x04,
            0x10, 0x02,
            0x00, 0x00,
            0x00, 0x00
            }
        }]
    }
}

proc Main::init_toolbar { } {
    Main::metaToolbar
    
    set Main::toolbar  [$Main::mainframe addtoolbar]
        
    ### Connection ###
    set bbox [ButtonBox $Main::toolbar.bbox1 -spacing 0 -padx 1 -pady 1 -homogeneous 0]
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
        -helptext "Options"
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
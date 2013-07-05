proc Main::init_toolbar { } {
    set toolbar  [$Main::mainframe addtoolbar]
    
    set icondir [pwd]/icons
        
    ### Connection ###
    set bbox [ButtonBox $toolbar.bbox1 -spacing 0 -padx 1 -pady 1]
    $bbox add -image [image create photo -file $icondir/connect.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Connect" \
        -command Main::showConnectDialog
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
    set sep [Separator $toolbar.sep1 -orient vertical]
    pack $sep -side left -fill y -padx 4 -anchor w
        
    ### Server/Channel ###
    set bbox [ButtonBox $toolbar.bbox2 -spacing 0 -padx 1 -pady 1]
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
        -helptext "Server/Channel Properties" -state disabled]
    set Main::toolbar_away [\
    $bbox add -image [image create photo -file $icondir/away.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Away/Back" -state disabled \
        -command Main::pressAway]
    pack $bbox -side left -anchor w
    set sep [Separator $toolbar.sep2 -orient vertical]
    pack $sep -side left -fill y -padx 4 -anchor w
    
    ### Etc ###
    set bbox [ButtonBox $toolbar.bbox3 -spacing 0 -padx 1 -pady 1]  
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
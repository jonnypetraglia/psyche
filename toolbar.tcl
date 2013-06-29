proc Main::init_toolbar { } {
    set toolbar  [$Main::mainframe addtoolbar]
    
    set icondir [pwd]/icons/kgn_icons
        
    ### Connection ###
    set bbox [ButtonBox $toolbar.bbox1 -spacing 0 -padx 1 -pady 1]
    $bbox add -image [image create photo -file $icondir/connect.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Connect" \
        -command Main::showConnectDialog
    set Main::toolbar_disconnect [\
    $bbox add -image [image create photo -file $icondir/disconnect.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Disconnect"]
    pack $bbox -side left -anchor w
    set sep [Separator $toolbar.sep1 -orient vertical]
    pack $sep -side left -fill y -padx 4 -anchor w
        
    ### Server/Channel ###
    set bbox [ButtonBox $toolbar.bbox2 -spacing 0 -padx 1 -pady 1]
    set Main::toolbar_join [\
    $bbox add -image [image create photo -file $icondir/join.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Join" \
        -command Main::showJoinDialog]
    set Main::toolbar_part [\
    $bbox add -image [image create photo -file $icondir/part.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Part"]
    set Main::toolbar_properties [\
    $bbox add -image [image create photo -file $icondir/properties.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Server/Channel Properties"]
    set Main::toolbar_channellist [\
    $bbox add -image [image create photo -file $icondir/channels.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Channel List"]
    set Main::toolbar_away [\
    $bbox add -image [image create photo -file $icondir/away.gif] \
        -highlightthickness 0 -takefocus 0 -relief link -borderwidth 1 -padx 1 -pady 1 \
        -helptext "Away/Back"]
    pack $bbox -side left -anchor w
    set sep [Separator $toolbar.sep2 -orient vertical]
    pack $sep -side left -fill y -padx 4 -anchor w
    
    $Main::toolbar_disconnect configure -state disabled
    $Main::toolbar_join configure -state disabled
    $Main::toolbar_join configure -state disabled
    $Main::toolbar_part configure -state disabled
    $Main::toolbar_properties configure -state disabled
    $Main::toolbar_channellist configure -state disabled
    $Main::toolbar_away configure -state disabled
        
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
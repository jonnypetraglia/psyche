namespace eval About {
    variable icondir
    variable tk_version
    variable bwidget_version
    variable snit_version
    variable copyright_year
    variable donate_url
    variable BTC

    set icondir [pwd]/icons
    set copyright_year 2013
    set donate_url "http://qweex.com/donate"
    set BTC "1G6cCKnhbESiBXLprxNjzjFDZsES4tH9ZM"
    set LTC "LRthYyVMBUJJqkoJTnnWrTQpuATWfv5s7g"
}



proc About::show {} {
    if [winfo exists .aboutDialog] {
        Main::foreground_win .aboutDialog
        return
    }
    toplevel .aboutDialog -padx 10 -pady 10
    wm title .aboutDialog "About"
    
    set builtonString ""
    set builtonString "${builtonString}        Tcl v[info patchlevel]\n"
    set builtonString "${builtonString}        Tk v$About::tk_version\n"
    set builtonString "${builtonString}        BWidget v$About::bwidget_version\n"
    set builtonString "${builtonString}        snit v$About::snit_version\n"
    
    xlabel .aboutDialog.icon -image [image create photo -file $About::icondir/butterfly-icon_192.gif]
    xlabel .aboutDialog.title -text "$Main::APP_NAME $Main::APP_VERSION" -font {Arial 25}
    xlabel .aboutDialog.cwith -text "Compiled with:\n$builtonString" -justify left
    xlabel .aboutDialog.builton -text "Built on $Main::APP_BUILD_DATE"
    xlabel .aboutDialog.copyright -text "Copyright $About::copyright_year Jon Petraglia of Qweex"
    xlabel .aboutDialog.license -text "Released under the BSD 3-clause license"
    grid config .aboutDialog.icon      -row 0 -column 0 -padx 5 -sticky "w" -rowspan 5
    grid config .aboutDialog.title     -row 0 -column 1 -padx 5 -sticky "w"
    grid config .aboutDialog.cwith     -row 1 -column 1 -padx 5 -sticky "w"
    grid config .aboutDialog.builton   -row 2 -column 1 -padx 5 -sticky "w"
    grid config .aboutDialog.copyright -row 3 -column 1 -padx 5 -sticky "w"
    grid config .aboutDialog.license   -row 4 -column 1 -padx 5 -sticky "w"
    
    label .aboutDialog.hr -foreground grey \
        -text "_________________________________________________________________"
    grid .aboutDialog.hr -row 5 -column 0 -padx 5 -columnspan 2
    
    # Donate
    xlabel .aboutDialog.donate -text "Like Psyche? Support the developer." -foreground blue
    if {$::this(platform) == "macosx"} {
        .aboutDialog.donate configure -cursor pointinghand
    } else {
        .aboutDialog.donate configure -cursor hand2
    }
    .aboutDialog.donate configure -font [linsert [.aboutDialog.donate cget -font] end 12 underline]
    grid config .aboutDialog.donate    -row 6 -column 0 -padx 5 -columnspan 2
    bind .aboutDialog.donate <ButtonRelease> About::donate
    
    # Crypto coins
    xlabel .aboutDialog.btc_l -text "BTC"
    xentry .aboutDialog.btc -textvariable About::BTC -state readonly -width 35 -foreground black
puts [.aboutDialog.btc cget -font]
    xlabel .aboutDialog.ltc_l -text "LTC"
    xentry .aboutDialog.ltc -textvariable About::LTC -state readonly -width 35 -foreground black

    grid config .aboutDialog.btc_l -row 7 -column 0 -padx 5 -sticky "e"
    grid config .aboutDialog.btc   -row 7 -column 1 -padx 5 -sticky "w"
    grid config .aboutDialog.ltc_l -row 8 -column 0 -padx 5 -sticky "e"
    grid config .aboutDialog.ltc   -row 8 -column 1 -padx 5 -sticky "w"
}

proc About::donate {} {
    switch $::this(platform) {
        "windows" {
            set evalString "exec \"[auto_execok START]\" \"$About::donate_url\""
            eval $evalString
        }
        "osx" {
            exec "open" $About::donate_url
        }
        default {
            exec "xdg-open" $About::donate_url
        }
    }
}
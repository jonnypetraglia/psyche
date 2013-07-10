# Run inside main folder
source doc/zdoc.tcl
zdoc::init
zdoc::set_filelist { main.tcl pref.tcl irc.tcl tabServer.tcl tabChannel.tcl toolbar.tcl }
zdoc::set_outdir doc
zdoc::run

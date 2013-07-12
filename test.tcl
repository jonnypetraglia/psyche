package require Tcl
       package require Tk
       package require menubar

       set tout [text .t -width 25 -height 12]
       pack ${tout} -expand 1 -fill both
       set mbar [menubar new \
           -borderwidth 4 \
           -relief groove  \
           -foreground black \
           -background tan \
           ]
       ${mbar} define {
           File M:file {
               Exit                 C      exit
           }
           Edit M:items+ {
           #   Label               Type    Tag Name(s)
           #   -----------------   ----    ---------"Cut" --------"Cut"
               "Cut"               C       cut
               "Copy"              C       copy
               "Paste"             C       paste
               --                  S       s2
               "Options" M:opts {
                   "CheckList" M:chx+ {
                       Coffee      X       coffee+
                       Donut       X       donut
                       Eggs        X       eggs
                       }
                   "RadioButtons" M:btn+ {
                       "Red"       R       color
                       "Green"     R       color+
                       "Blue"      R       color
                       }
               }
           }
           Help M:help {
               About               C       about
           }
       }
       ${mbar} install . {
           ${mbar} tag.add tout ${tout}
           ${mbar} menu.configure -command {
               # file menu
               exit            {Exit}
               # Item menu
               cut             {CB Edit cut}
               copy            {CB Edit copy}
               paste           {CB Edit paste}
               # boolean menu
               coffee          {CB CheckButton}
               donut           {CB CheckButton}
               eggs            {CB CheckButton}
               # radio menu
               color           {CB RadioButton}
               # Help menu
               about           {CB About}
           } -bind {
               exit        {1 Cntl+Q  Control-Key-q}
               cut         {2 Cntl+X  Control-Key-x}
               copy        {0 Cntl+C  Control-Key-c}
               paste       {0 Cntl+V  Control-Key-v}
               coffee      {0 Cntl+A  Control-Key-a}
               donut       {0 Cntl+B  Control-Key-b}
               eggs        {0 Cntl+C  Control-Key-c}
               about       0
           } -background {
               exit red
           } -foreground {
               exit white
           }
       }
       proc pout { txt } {
           global mbar
           set tout [${mbar} tag.cget . tout]
           ${tout} insert end "${txt}\n"
       }
       proc Exit { args } {
           puts "Goodbye"
           exit
       }
       proc CB { args } {
           set alist [lassign ${args} cmd]
           pout "${cmd}: [join ${alist} {, }]"
       }
       wm minsize . 300 300
       wm geometry . +4+4
       wm protocol . WM_DELETE_WINDOW exit
       wm title . "Example"
       wm focusmodel . active
       pout "Example started ..."
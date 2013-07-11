# notebox.tcl ---
#
#       A single instance notifier window where simple messages can be added.
#       
#  Copyright (c) 2004
#  
#  This source file is distributed under the BSD license.
#  
#  $Id: notebox.tcl,v 1.5 2008-06-09 14:24:46 matben Exp $

package provide notebox 1.0

namespace eval ::notebox {
    
    array set fontPlat {
	unix    {Helvetica 12}
	windows {Arial 8}
	macosx  {Geneva 9}
    }

    option add *Notebox.millisecs                  0         widgetDefault
    option add *Notebox.anchor                     nw        widgetDefault

    option add *Notebox.background                 "#ffff9f" 50
    option add *Notebox.foreground                 black     30
    option add *Notebox.Message.width              160       widgetDefault

    option add *Notebox.closeButtonBgWinxp         "#ca2208" widgetDefault
    option add *Notebox.closeButtonImage           ""        widgetDefault
        
    option add *Notebox.font $fontPlat($::this(platform)) widgetDefault

    set MAX_INT 0x7FFFFFFF
    set hex [format {%x} [expr {int($MAX_INT*rand())}]]
    set w .notebox$hex
    
    variable this
    set this(w) $w
    set this(uid) 0
    set this(x_pad) 0	;#-30
    set this(y_pad) 0	;#-30
    set this(x) [expr {[winfo screenwidth .]  + $this(x_pad)}]
    set this(y) [expr {[winfo screenheight .] + $this(y_pad)}]
}

proc ::notebox::setposition {x y} {
    variable this
    
    set this(x) $x
    set this(y) $y
}

proc ::notebox::Build {} {
    variable this

    set w $this(w)
    toplevel $w -class Notebox -bd 0 -relief flat
    
    switch -- [tk windowingsystem] {
	aqua {
	    tk::unsupported::MacWindowStyle style $w floating {sideTitlebar closeBox}
	    frame $w.f -height 32 -width 0
	    pack  $w.f -side left -fill y
	}
	default {
	    wm overrideredirect $w 1
	    wm transient $w
	    frame $w.f -bd 1 -relief raised
	    pack  $w.f -side left -fill y
	    set c $w.f.c
	    set size 13
	    canvas $c -width $size -height $size -highlightthickness 0
	    DrawWinxpButton $c 5
	    pack $c -side top
	}
    }
}

proc ::notebox::DrawWinxpButton {c r} { 
    variable this

    set rm [expr {$r-1}]
    set a  [expr {int(($r-2)/1.4)}]
    set ap [expr {$a+1}]
    set width  [$c cget -width]
    set width2 [expr {$width/2}]

    set im [option get $this(w) closeButtonImage {}]
    if {$im ne ""} {
	$c create image $width2 $width2 -image $im -anchor center
    } else {
	set red [option get $this(w) closeButtonBgWinxp {}]
	
	# Be sure to offset ovals to put center pixel at (1,1).
	if {[tk windowingsystem] eq "aqua"} {
	    $c create oval -$rm -$rm  $r $r -tags bt -outline {} -fill $red
	    set id1 [$c create line -$a -$a $a  $a -tags bt -fill white]
	    set id2 [$c create line -$a  $a $a -$a -tags bt -fill white]
	} else {
	    $c create oval -$rm -$rm $rm $rm -tags bt -outline $red -fill $red
	    set id1 [$c create line -$a -$a $ap  $ap -tags bt -fill white]
	    set id2 [$c create line -$a  $a $ap -$ap -tags bt -fill white]
	}
	$c move bt $width2 $width2
    }
    $c bind bt <ButtonPress-1> [list destroy $this(w)]
}

proc ::notebox::addmsg {str args} {
    variable this

    if {![winfo exists $this(w)]} {
	Build
    }
    array set argsArr {
	-title ""
    }
    array set argsArr $args
    set w $this(w)
    wm title $w $argsArr(-title)
    if {[llength [winfo children $w]] > 1} {
	set wdiv $w.f[incr this(uid)]
	frame $wdiv -height 2
	pack  $wdiv -side top -fill x
    }
    set t $w.t[incr this(uid)]
    set bg   [option get $w background {}]
    set fg   [option get $w foreground {}]
    set font [option get $w font {}]
    message $t -bg $bg -fg $fg -font $font -padx 8 -pady 2 \
      -highlightthickness 0 -justify left -text $str
    pack $t -side top -anchor w
        
    after idle [list ::notebox::SetGeometry $t]
    
    if {[info exists this(afterid)]} {
	after cancel $this(afterid)
    }
    set ms [option get $w millisecs {}]
    if {$ms > 0} {
	after $ms ::notebox::Destroy
    }
}

proc ::notebox::getxyFromAnchor {} {
    variable this
    set w $this(w)
    set anchor [option get $w anchor {}]
    if {[string first "n" $anchor] > -1} {
	set this(y) [expr {0 + 30}]
    } else {
	set this(y) [expr {[winfo screenheight $w] - 30}]
	set this(y) [expr {$this(y) - [winfo reqheight $w]}]
    }
    
    if {[string first "w" $anchor] > -1} {
	set this(x) [expr {0 + 30}]
    } else {
	set this(x) [expr {[winfo screenwidth $w] - 30}]
	set this(x) [expr {$this(x) - [winfo reqwidth $w]}]
    }
}

proc ::notebox::SetGeometry {t} {
    variable this
    
    update idletasks
    set w $this(w)
    
    ::notebox::getxyFromAnchor
    
    set x $this(x)
    set y $this(y)
    
    puts "setgeometry  1  x=$this(x)  y=$this(y)"
    wm geometry $w +${x}+${y}
}

proc ::notebox::Destroy {} {
    variable this
    
    catch {destroy $this(w)}
}

#-------------------------------------------------------------------------------


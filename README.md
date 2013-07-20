Psyche - IRC in Tlc/Tk
===============

I wrote/am writing/have written Psyche for the following reasons:

Psyche is:

Tiny
---
This summer semester at school, I am forced to use Windows machines with a temporary
profile, meaning my options are either Mibbit or re-downloading Hexchat, or even irssi,
every day. Most clients I prefer (Konversation, Quassel, Hexchat, etc) are hefty,
and I'm still not into using irssi on Windows.

All the small GUI programs I found for Windows either required .NET (which, on a school
computer, is a gamble), were feature incomplete/hard to use, and -most importantly- were
abandoned.

Tcl/Tk
---
As a user and a dev, I love Qt. But there are already some fantastic Qt clients out there,
and it's a little hefty to ship with the DLL and all, or -on Linux- the huge Qt package.

As a user, I love Tcl/Tk because it's cross platform, incredibly small, and incredibly fast.
(I'm not sure what I think of it as a dev just yet. I can definitely say that it's different.)

Open-source
---
Duh.

A butterfly
---
In case you're curious, this semester I'm taking a "Concepts of the Soul" philosophy class for
my philosophy minor, and one recurring theme is that in various cultures, a butterfly or moth
is often associated with the soul. And in Greek, the word for "butterfly" is actually the same
as the word for "soul", and that word is "psyche".


Further notes
=====
As much as I have enjoyed working on Psyche so far, I have more of an obligation to my open-source apps
that I already have existing, so Psyche will most likely be an 'on the weekends' thing....hopefully.


Dependencies
----
Psyche uses just a few dependencies, all of which are written in pure Tcl/Tk:

## Tk ##

Duh!

## tcllib ##
Psyche mainly uses parts of a library called **tcllib**, which is available in most Linux repositories, in MacPorts, or can be downloaded for any of Linux/Mac/Windows. You can also download just the separate libraries and manually install them.
tcllib is released under the same [BSD-style license](http://www.tcl.tk/software/tcltk/license.html) used by Tcl and Tk.

[tcllib Website](http://core.tcl.tk/tcllib/home)
[tcllib Download](http://core.tcl.tk/tcllib/wiki?name=Downloads)
[tcllib Github](https://github.com/tcltk/tcllib)
[tcllib Gutter](http://www.flightlab.com/~joe/gutter/packages/tcllib.html)

#### BWidget ####

BWidget provides a variety of advanced widgets for Tk and is written in pure Tcl/Tk.

The current version of Psyched was tested with BWidget **1.9.6**.

[BWidget Download](http://sourceforge.net/projects/tcllib/files/BWidget)
[BWidget Github](https://github.com/tcltk/bwidget)
[BWidget Gutter](http://www.flightlab.com/~joe/gutter/packages/bwidget.html)

I chose BWidget purely for the Notebook (tabs) widget. It's pure Tcl, doesn't look like crap, and is included inside tcllib.

#### snit ####

snit is a "type system", which means that it's kinda sorta like OO for Tcl.

The current version of Psyched was tested with snit **2.3.2**.

[snit Home](http://www.flightlab.com/~joe/gutter/packages/snit.html)
[snit Github](https://github.com/tcltk/tcllib/tree/master/modules/snit)
[snit Gutter](http://www.flightlab.com/~joe/gutter/packages/snit.html)


I chose snit as the "OO-esque" extension because it really doesn't get in your way, and it doesn't seem out of place in Tcl. Another extension I've looked at is [stooop](http://jfontain.free.fr/stooop.html), which is very C++like, but really doesn't fit well with Tcl (imo). The only real plus I saw in stooop that is not in snit is inheritance, but that went out the window when I realized that because Tcl does not do type checking, inheritance doesn't really play too much of a role; you can just create two very similar snit types and yeah, you have to copy a few functions between both, but you don't gain abstraction by overriding functions differently. You can do that anyway.


License
---
I've decided to go ahead and release Psyche under the BSD license. Because Fuck yeah, free software!

Icons & Sounds
---
The icons I am (currently) using for Psyche are compliments of David Keegan[https://github.com/kgn/kgn_icons],
which are released under a loose license. He's totally cool like that.

The logo icon (the butterfly) is compliments of Ergosign
[http://www.iconarchive.com/show/free-spring-icons-by-ergosign/butterfly-icon.html],
which is released under the CC BY-NC-ND 3.0. Which is still pretty cool.

The sound for mentions is from on freesound by DJ Chronos. Bless his mouth. [http://www.freesound.org/people/DJ%20Chronos/sounds/29927/]
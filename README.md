# Psyche - IRC in Tlc/Tk #
#### Copyright 2013-2014 Jon Petraglia of Qweex ####
#### http://qweex.com ####

### Contents: ###
  1. Configuration
  2. What is Psyche
  3. Dependencies
  4. License
  5. Icons & Sounds
  6. Compiling

------------------------------------------------------

1. Configuration
----------------

Of course, you can use the nice GUI preferences dialog to configure Psyche, but you can also manually write the config file, which is surprisingly easy!

Psyche's user configuration is stored in one file located at ~/.psyche/config.tcl (the '~' means your home directory, for you Windows users). 

To set a value, use the same nomenclature as regular Tcl:

    set defaultKick "You have done something bad. You should not do that."

#### Values: ###

  * timeout = (integer)
    * the time in milliseconds to wait for a server to connect
  * raiseNewTabs = (boolean)
    * when opening a new tab if you want to immediately switch to it
  * useTheme = (boolean)
    * if you want to use ttk themed Tk widgets
  * defaultQuit = (string)
    * the default message when issuing the /quit command or pressing the Quit button
  * defaultKick = (string)
    * the default message when issuing the /kick command or using the Ban/Kick menu
  * defaultBan = (string) 
    * the default message when issuing the /kb command or using the Ban/Kick menu; used specifically for the Kick message in kickbans
  * defaultPart = (string)
    * the default message when issuing the /part command or pressing the Part button
  * defaultAway = (string)
    * the default message when issuing the /away command or pressing the Away button
  * banMask = (*!*@*.host | *!*@domain | *!user@*.host | *!user@domain)
    * the default mask to be used when using /ban or the "Ban" menu item
  * logServers = (boolean)
    * if you want all messages to be logged for servers
  * logChannels = (boolean)
    * if you want all messages to be logged for channels
  * logPMs = (boolean)
    * if you want all messages to be logged for PMs
  * logDir = (string)
    * the location of the log
  * popupTimeout = (integer)
    * the duration in milliseconds the popup notification for mentions should stay on the screen; set to 0 for it to stay indefinitely until manually dismissed
  * popupLocation =
    * (n|s+e|w) the location on the screen for the popup; should contain one of 'n' or 's' for the vertical and one of 'e' or 'w' for the horizontal; example: 'nw'
  * popupFont = (list)
    * the font to be used in the mention popup; see the Tcl/Tk documentation on fonts for syntax
  * maxSendHistory = (integer)
    * how many of your past commands to keep
  * maxScrollback = (integer)
    * how many lines on screen the chats should be limited
  * mentionColor = (string/hex)
    * the color to change a tab to when it has been mentioned; can use the strings builtin to Tcl/Tk or a custom RGB value
  * mentionSound = (string)
    * the path to the sound file to be played when you are mentioned; set to the empty string "" if you want to disable sounds
  * toolbarHidden = (boolean)
    * whether or not the toolbar is hidden by default.
  * bookmarks = (array entry containing list)
    * bookmarks are slightly more complicated, in that they are stored in the array 'bookmarks' with a list of the values needed to connect.
    * each entry for a bookmark is a list containing 3 sublists: (1) connection info, (2) nick info, and optionally (3) channels.
      1. Connection info: server, port, and (optionally) whether or not to use SSL (a boolean)
      2. Nick Info: nick, and (optionally) the NickServ pass
      3. Channels: Any channels to join upon connecting
    * Syntax:   bookmarks($nickname) { {$server $port _$ssl_} {$nick _$pass_} _{$channel1 $channel2 ...}_}
    * Example:  bookmarks(Geekshed) {{irc.geekshed.net 6697 true} {notbryant} {#qweex #help}}

For default values, see the "pref.tcl" file.

** Note:** Even though the file is all written in Tcl, it is filtered before being executed, so you can't just throw in any old Tcl. Currently the only thing currently accepted is calling "set" on the listed values. Anything else will be ignored.
And it's currently up to you use the right data types/domains when entering values.


2. What is Psyche?
------------------

I wrote/am writing/have written Psyche for the following reasons:

Psyche is:

### Tiny ###
This summer semester at school, I am forced to use Windows machines with a temporary
profile, meaning my options are either Mibbit or re-downloading Hexchat, or even irssi,
every day. Most clients I prefer (Konversation, Quassel, Hexchat, etc) are hefty,
and I'm still not into using irssi on Windows.

All the small GUI programs I found for Windows either required .NET (which, on a school
computer, is a gamble), were feature incomplete/hard to use, and -most importantly- were
abandoned.

### Tcl/Tk ###
As a user and a dev, I love Qt. But there are already some fantastic Qt clients out there,
and it's a little hefty to ship with the DLL and all, or -on Linux- the huge Qt package.

As a user, I love Tcl/Tk because it's cross platform, incredibly small, and incredibly fast.
(I'm not sure what I think of it as a dev just yet. I can definitely say that it's different.)

### Open-source ###
Duh.

### A butterfly ###
In case you're curious, this semester I'm taking a "Concepts of the Soul" philosophy class for
my philosophy minor, and one recurring theme is that in various cultures, a butterfly or moth
is often associated with the soul. And in Greek, the word for "butterfly" is actually the same
as the word for "soul", and that word is "psyche".



3. Dependencies
---------------
Psyche uses just a few dependencies, all of which are written in pure Tcl/Tk:

### Tk ###

Duh!

### tcllib ###
Psyche mainly uses parts of a library called **tcllib**, which is available in most Linux
repositories, in MacPorts, or can be downloaded for any of Linux/Mac/Windows. You can also download
just the separate libraries and manually install them.
tcllib is released under the same [BSD-style license](http://www.tcl.tk/software/tcltk/license.html)
used by Tcl and Tk.

  * [tcllib Website](http://core.tcl.tk/tcllib/home)
  * [tcllib Download](http://core.tcl.tk/tcllib/wiki?name=Downloads)
  * [tcllib Github](https://github.com/tcltk/tcllib)
  * [tcllib Gutter](http://www.flightlab.com/~joe/gutter/packages/tcllib.html)

##### BWidget #####

BWidget provides a variety of advanced widgets for Tk and is written in pure Tcl/Tk.

The current version of Psyche was tested with BWidget **1.9.6**.

  * [BWidget Download](http://sourceforge.net/projects/tcllib/files/BWidget)
  * [BWidget Github](https://github.com/tcltk/bwidget)
  * [BWidget Gutter](http://www.flightlab.com/~joe/gutter/packages/bwidget.html)

I chose BWidget purely for the Notebook (tabs) widget. It's pure Tcl, doesn't look like crap, and is
included inside tcllib.

#### snit ####

snit is a "type system", which means that it's kinda sorta like OO for Tcl.

The current version of Psyche was tested with snit **2.3.2**.

  * [snit Home](http://www.flightlab.com/~joe/gutter/packages/snit.html)
  * [snit Github](https://github.com/tcltk/tcllib/tree/master/modules/snit)
  * [snit Gutter](http://www.flightlab.com/~joe/gutter/packages/snit.html)


I chose snit as the "OO-esque" extension because it really doesn't get in your way, and it
doesn't seem out of place in Tcl. Another extension I've looked at is
[stooop](http://jfontain.free.fr/stooop.html), which is very C++like, but really doesn't
fit well with Tcl (imo). The only real plus I saw in stooop that is not in snit is inheritance,
but that went out the window when I realized that because Tcl does not do type checking,
inheritance doesn't really play too much of a role; you can just create two very similar snit
types and yeah, you have to copy a few functions between both, but you don't gain abstraction
by overriding functions differently. You can do that anyway.


4. License
----------
I've decided to go ahead and release Psyche under the BSD license.
Because Fuck yeah, free software!


5. Icons & Sounds
-----------------
The icons I am (currently) using for Psyche are compliments of David Keegan[https://github.com/kgn/kgn_icons],
which are released under a loose license. He's totally cool like that.

The logo icon (the butterfly) is compliments of Ergosign
[http://www.iconarchive.com/show/free-spring-icons-by-ergosign/butterfly-icon.html],
which is released under the CC BY-NC-ND 3.0. Which is still pretty cool.

The sound for mentions is from freesound by DJ Chronos [http://www.freesound.org/people/DJ%20Chronos/sounds/29927/]
and is released under the CC BY 3.0. Bless his mouth.

5. Compiling
-----------------
The preferred method of "compiling" Psyche is by using another one of my projects named [tclkitty](https://github.com/notbryant/tclkitty).

More information about how to "compile" Psyche into a single executable should be found at tclkitty's wiki portion on its Github.
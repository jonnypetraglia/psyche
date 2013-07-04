
#Unreal ircu Hybrid IRCnet aircd Bahamut PTLink KineIRCd AustHex Anothernet GameSurge Ithildin RatBox
set IrcCodes(290_Unreal) Help 
set IrcCodes(290_aircd) Info
set IrcCodes(290_QuakeNet) Data
set IrcCodes(292_Unreal) Help 
set IrcCodes(292_aircd) Info

# https://www.alien.net.au/irc/irc2numerics.html
proc getTitle {mCode} {
    switch $mCode {
	001 {
	    #RPL_WELCOME (RFC2812)
	    return \[Welcome\]
	}
	002 {
	    #RPL_YOURHOST (RFC2812)
	    return \[Welcome\]
	}
	003 {
	    #RPL_CREATED (RFC2812)
	    return \[Welcome\]
	}
	004 {
	    #RPL_MYINFO (KineIRCd)
	    return \[Welcome\]
	}
	005 {
	    #RPL_BOUNCE (RFC2812)
	    return \[Support\]
	}
	250 {
	    #RPL_STATSDLINE (RFC1459)
	    #RPL_STATSCONN (ircu, Unreal)
	    return \[Stats\]
	}
	251 {
	    #RPL_LUSERCLIENT (RFC2812)
	    return \[Users\]
	}
	252 {
	    #RPL_LUSEROP (RFC2812)
	    return \[Users\]
	}
	253 {
	    #RPL_LUSERUNKNOWN (RFC2812)
	    return \[Users\]
	}
	254 {
	    #RPL_LUSERCHANNELS (RFC2812)
	    return \[Users\]
	}
	255 {
	    #RPL_LUSERME (RFC2812)
	    return \[Users\]
	}
	265 {
	    #RPL_LOCALUSERS (aircd, Hybrid, Bahamut)
	    return \[Users\]
	}
	266 {
	    #RPL_GLOBALUSERS (aircd, Hybrid, Bahamut)
	    return \[Users\]
	}
	290 {
	    #RPL_HELPHDR (Unreal)
	    return \[Help\]
	    #RPL_CHANINFO_OPERS (aircd)
	    #RPL_DATASTR (QuakeNet)
	}
	292 {
	    #RPL_HELPTLR (Unreal)
	    return \[Help\]
	    #RPL_CHANINFO_BANS (aircd)
	}
	321 {
	    #RPL_LISTSTART (RFC1459)
	    return \[List\]
	}
	322 {
	    #RPL_LIST (RFC1459)
	    # Use this to update channel list
	    return \[List\]
	}
	323 {
	    #RPL_LISTEND (RFC1459)
	    # Use this to update channel list
	    return \[List\]
	}
	328 {
	    #RPL_CHANNEL_URL (Bahamut, AustHex)
	    # ???
	    # Received after joining a channel, I think
	}
	332 {
	    #RPL_TOPIC (RFC1459)
	    return \[Topic\]
	}
	333 {
	    #RPL_TOPICWHOTIME (ircu)
	    return \[Topic\]
	}
	353 {
	    #RPL_NAMREPLY (RFC1459)
	    # Use this to update nicklist
	    return ""
	}
	366 {
	    #RPL_ENDOFNAMES (RFC1459)
	    # Use this to update nicklist
	    return ""
	}
	372 {
	    #RPL_MOTD (RFC1459)
	    return \[MOTD\]
	}
	375 {
	    #RPL_MOTDSTART (RFC1459)
	    return \[MOTD\]
	}
	376 {
	    #RPL_ENDOFMOTD (RFC1459)
	    return \[MOTD\]
	}
	401 {
	    #ERR_NOSUCHNICK (RFC1459)
	    return \[ERROR\]
	}
	433 {
	    #ERR_NICKNAMEINUSE (RFC1459)
	    return \[ERROR\]
	}
	477 {
	    #ERR_NEEDREGGEDNICK (Bahamut, ircu, Unreal)
	    #ERR_NOCHANMODES (RFC1459)
	    return \[ERROR\]
	}
	482 {
	    #ERR_CHANOPRIVSNEEDED 
	    return \[ERROR\]
	}
	486 {
	    #ERR_NONONREG (???)
	    #ERR_HTMDISABLED (Unreal)
	    #ERR_ACCOUNTONLY (QuakeNet)
	    return \[ERROR\]
	}
	default {
	    return \[$mCode\]
	}
    }
}

# returns 1 if it was handled (if it was a special case), 0 otherwise
proc performSpecialCase {msg obj} {
	puts "!!!!!!$msg"

	#/connect
	if [regexp {^connect ([^ ]+) ?([0-9]*)} $msg -> serv port] {
	    if {[string length $port] == 0} {
		    set port $Main::DEFAULT_PORT
	    }
	    debug "Connecting: $serv $port"
	    Main::createConnection $serv $port [$obj getNick]
	    return true
	}
	#/join
	if [regexp {^join ([^ ]+) ?(.*)} $msg -> chann channPass] {
	    debug "Joining: $chann"
	    $obj joinChan $chann $channPass
	    return true
	}
	#/msg
	if [regexp {^msg ([^ ]+) (.*)} $msg -> nick msg] {
	    debug "Msging: $nick"
	    $obj sendPM $nick $msg
	    #$obj _send "PRIVMSG notbryant Hello"
	    return true
	}
	#/quit
	if [regexp {^quit ?(.*)} $msg -> reason] {
	    debug "Quitting: $reason"
	    $obj quit $reason
	    return true
	}
	#/part
	if [regexp {^part ?(.*)} $msg -> msg] {
	    debug "Parting: $msg"
	    if [$obj isServer] {
		regexp {([^ ]+) (.*)} $msg -> channs msg
		set channlist [split $channs ","]
		#TODO: Test this
		foreach chann $channlist {
		    $obj part $chann $msg
		}
	    } else {
		$obj part [$obj getChannel] $msg
	    }
	    return true
	}
	#/nick
	if [regexp {^nick ([^ ]+)} $msg -> newnick] {
	    debug "Newnick: $newnick"
	    #Sends what is, essentially, a request to the server to change the nick.
	    #The server responds, and then [$obj nickChanged] handles the response
	    $obj _send "NICK $newnick"
	    return true
	}
	#/me
	if [regexp {^me (.*)} $msg -> msg] {
	    $obj _send "PRIVMSG [$obj getChannel] :\001ACTION $msg\001"
	    set timestamp [clock format [clock seconds] -format \[%H:%M\] ]
	    $obj handleReceived $timestamp " \*" bold "[$obj getNick] $msg" italic
	    return true
	}
	
	#/invite
	set thingsToChannelizePost "(invite)"
	if [regexp "^$thingsToChannelizePost \(.*\)" $msg -> cmd target] {
	    debug "CMD: ^\(\[[$obj getChannPrefixes]\]\[^ \]+\) \(.*\)"
	    if [regexp "\(\[^ \]+\) \(\[[$obj getChannPrefixes]\].*\)" $msg -> target chann] {
		set chann $chann
	    } else {
		set chann [$obj getChannel]
	    }
	    debug "INVITE: $target $chann"
	    $obj _send "$cmg $target $chann"
	    return true
	}
	
	#/kick
	#/topic
	set thingsToChannelize "(kick|topic)"
	if [regexp "^$thingsToChannelize \(.*\)" $msg -> cmd target] {
	    debug "CMD: ^\(\[[$obj getChannPrefixes]\]\[^ \]+\) \(.*\)"
	    if [regexp "^\(\[[$obj getChannPrefixes]\]\[^ \]+\) \(.*\)" $msg -> chann target] {
		set chann $chann
	    } else {
		set chann [$obj getChannel]
	    }
	    debug "CMD: $cmd $chann $target"
	    $obj _send "$cmd $chann $target"
	    return true
	}
	#/list
	#/help
	#/motd
	#/credits
	set thingsToIgnore "(list|help|motd|credits)"
	if [regexp "^$thingsToIgnore\(.*\)" $msg -> cmd derp] {
	    return false
	}
	return true

	
	#/partall
	#/notice
	#/ping
	#/query?
	#/ignore
	#/chat
	#/whois
	#/who
	#/whowas
	#/ison
	#/cycle?
	#/lusers
	#/map
	#/version
	#/links
	#/admin
	#/userhost
	#/topic
	#/away
	#/watch
	#/helpop
	#/list
	#/knock
	#/setname
	#/vhost
	#/modes
	#/credits
	#/license
	#/time
	#/botmotd
	#/identify
	#/dns
	#/userip
	#/stats
	#/module
}
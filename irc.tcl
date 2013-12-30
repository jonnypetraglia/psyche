
#Unreal ircu Hybrid IRCnet aircd Bahamut PTLink KineIRCd AustHex Anothernet GameSurge Ithildin RatBox
set IrcCodes(232_Unreal) Rules
set IrcCodes(290_Unreal) Help 
set IrcCodes(290_aircd) Info
set IrcCodes(290_QuakeNet) Data
set IrcCodes(292_Unreal) Help 
set IrcCodes(292_aircd) Info
set IrcCodes(309_aircd) Trace
set IrcCodes(309_Bahamut) Admin
set IrcCodes(309_AustHex) WhoIs
set IrcCodes(378_aircd) BanExpired
set IrcCodes(378_Unreal) Whois
set IrcCodes(378_AustHex) MotD

# https://www.alien.net.au/irc/irc2numerics.html
# http://www.godspeak.net/chat/basic_irc.html
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
        006 {
            #RPL_MAP (Unreal)
            return \[Map\]
        }
        007 {
            #RPL_MAPEND (Unreal)
            return \[Map\]
        }
        210 {
            #RPL_TRACERECONNECT (RFC2812)
            #RPL_STATS (aircd)
            return \[Stats\]
        }
        219 {
            #RPL_ENDOFSTATS (RFC1459)
            return \[Stats\]
        }
        232 {
            #RPL_RULES (Unreal)
            return \[Rules\]
            #RPL_ENDOFSERVICES (RFC1459)
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
        302 {
            #RPL_USERHOST
            return \[UserHost\]
        }
        303 {
            #RPL_ISON (RFC1459)
            return \[IsOn\]
        }
        305 {
            #RPL_UNAWAY (RFC1459)
            return \[Away\]
        }
        306 {
            #RPL_NOWAWAY (RFC1459)
            return \[Away\]
        }
        307 {
            #RPL_USERIP (???)
            #RPL_WHOISREGNICK (Bahamut, Unreal)
            #RPL_SUSERHOST (AustHex)
            return \[Whois\]
        }
        309 {
            #RPL_NICKTRACE (aircd)
            #RPL_WHOISSADMIN (Bahamut)
            #RPL_ENDOFRULES (Unreal)
            return \[Rules\]
            #RPL_WHOISHELPER (AustHex)
        }
        311 {
            #RPL_WHOISUSER (RFC1459)
            return \[Whois\]
        }
        312 {
            #RPL_WHOISSERVER (RFC1459)
            return \[Whois\]
        }
        315 {
            #RPL_ENDOFWHO (RFC1459)
            return \[Who\]
        }
        317 {
            #RPL_WHOISIDLE (RFC1459)
            return \[Whois\]
            #TODO
        }
        318 {
            #RPL_ENDOFWHOIS (RFC1459)
            return \[Whois\]
        }
        319 {
            #RPL_WHOISCHANNELS (RFC1459)
            return \[Whois\]
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
        324 {
            #RPL_CHANNELMODEIS (RFC1459)
            return \[Mode\]
        }
        329 {
            #RPL_CREATIONTIME (Bahamut)
            return \[Info\]
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
        340 {
            #RPL_USERIP (ircu)
            return \[UserIP\]
        }
        351 {
            #RPL_VERSION (RFC1459)
            return \[Version\]
        }
        352 {
            #RPL_WHOREPLY (RFC1459)
            return \[Who\]
        }
        353 {
            #RPL_NAMREPLY (RFC1459)
            # Use this to update nicklist
            return ""
        }
        364 {
            #RPL_LINKS
            return \[Links\]
        }
        365 {
            #RPL_ENDOFLINKS 
            return \[Links\]
        }
        366 {
            #RPL_ENDOFNAMES (RFC1459)
            # Use this to update nicklist
            return ""
        }
        367 {
            #RPL_BANLIST (RFC1459)
            return \[Banlist\]
        }
        368 {
            #RPL_ENDOFBANLIST (RFC1459)
            return \[Banlist\]
        }
        371 {
            #RPL_INFO
            return \[Info\]
        }
        372 {
            #RPL_MOTD (RFC1459)
            return \[MotD\]
        }
        374 {
            #RPL_ENDOFINFO
            return \[Info\]
        }
        375 {
            #RPL_MOTDSTART (RFC1459)
            return \[MotD\]
        }
        376 {
            #RPL_ENDOFMOTD (RFC1459)
            return \[MotD\]
        }
        378 {
            #RPL_BANEXPIRED (aircd)
            #RPL_WHOISHOST (Unreal)
            #RPL_MOTD (AustHex)
        }
        401 {
            #ERR_NOSUCHNICK (RFC1459)
            return \[Error\]
        }
        402 {
            #ERR_NOSUCHSERVER
            return \[Error\]
        }
        404 {
            #ERR_CANNOTSENDTOCHAN
            return \[Error\]
        }
        409 {
            #ERR_NOORIGIN
            return \[Error\]
        }
        421 {
            #ERR_UNKNOWNCOMMAND
            return \[Error\]
        }
        433 {
            #ERR_NICKNAMEINUSE (RFC1459)
            return \[Error\]
        }
        442 {
            #ERR_NOTONCHANNEL (RFC1459)
            return \[Error\]
        }
        474 {
            #ERR_BANNEDFROMCHAN (RFC1459)
            return \[Error\]
        }
        477 {
            #ERR_NEEDREGGEDNICK (Bahamut, ircu, Unreal)
            #ERR_NOCHANMODES (RFC1459)
            return \[Error\]
        }
        480 {
            #ERR_NOULINE (AustHex)
            #ERR_CANNOTKNOCK (Unreal)
            return \[Error\]
        }
        482 {
            #ERR_CHANOPRIVSNEEDED 
            return \[Error\]
        }
        486 {
            #ERR_NONONREG (???)
            #ERR_HTMDISABLED (Unreal)
            #ERR_ACCOUNTONLY (QuakeNet)
            return \[Error\]
        }
        default {
            return \[$mCode\]
        }
    }
}

# http://static.quadpoint.org/irssi-docs/help-full.html
# http://www.user-com.undernet.org/documents/ctcpdcc.txt
# returns 1 if it was handled (if it was a special case), 0 otherwise
proc performSpecialCase {msg obj} {
    Log D "performSpecialCase !!!! $msg"

    #/connect
    if [regexp {^connect ([^ ]+) ?([0-9]*)} $msg -> serv port] {
        if {[string length $port] == 0} {
            set port $Main::DEFAULT_PORT
        }
        Log D "Connecting: $serv $port"
        Main::createConnection $serv $port false [$obj getNick]
        return true
    }
    #/join
    if [regexp {^join ([^ ]+) ?(.*)} $msg -> chann channPass] {
        Log D "Joining: $chann"
        $obj _send "$msg"
        return true
    }
    #/msg OR /query
    if [regexp {^(msg|query) ([^ ]+) (.*)} $msg -> derp nick msg] {
        Log D "Msging: $nick"
        $obj sendPM $nick $msg
        return true
    }
    #/quit
    if [regexp {^quit ?(.*)} $msg -> reason] {
        Log D "Quitting: $reason"
        set reason [string trim $reason]
        if { [string length $reason] == 0 } {
            set reason $Pref::defaultQuit
        }
        $obj quit $reason
        return true
    }
    #/part
    if [regexp {^part ?(.*)} $msg -> msg] {
        Log D "Parting: $msg"
        if { [string length $msg] > 0 } {
            set reason $Pref::defaultPart
        }
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
    
    #/kick
    #/topic
    set thingsToChannelize "(kick|topic)"
    if [regexp "^$thingsToChannelize \(.*\)" $msg -> cmd target] {
        #TODO form should be
        #    'KICK #chan nick :reason'    with a colon
        #    'TOPIC #test :words'         with a colon
        #    'TOPIC #test'                to check the topic
        Log D "CMD: ^\(\[[$obj getChannPrefixes]\]\[^ \]+\) \(.*\)"
        if [regexp "^\(\[[$obj getChannPrefixes]\]\[^ \]+\) \(.*\)" $msg -> chann target] {
            set chann $chann
        } else {
            set chann [$obj getChannel]
        }
        Log D "CMD: $cmd $chann $target"
        $obj _send "$cmd $chann $target"
        return true
    }
    
    #/invite
    set thingsToChannelizePost "(invite)"
    if [regexp "^$thingsToChannelizePost \(.*\)" $msg -> cmd target] {
        Log D "CMD: ^\(\[[$obj getChannPrefixes]\]\[^ \]+\) \(.*\)"
        if [regexp "\(\[^ \]+\) \(\[[$obj getChannPrefixes]\].*\)" $msg -> target chann] {
            set chann $chann
        } else {
            set chann [$obj getChannel]
        }
        Log D "INVITE: $target $chann"
        $obj _send "$cmd $target $chann"
        return true
    }
    
    #/away
    if [regexp "^away ?\(.*\)" $msg -> reason] {
        $obj _send "AWAY :$reason"
        # This is the only place we can get the reason, so we have to signal from here
        $obj awaySignalServer $reason
        return true
    }
    
    #/ping
    if [regexp "^ping \(.*\)" $msg -> target] {
        $obj _send "PRIVMSG $target :\001PING [clock seconds]\001"
        return true
    }
    
    #/ctcp
    if [regexp {^ctcp ([^ ]+) ?(.*)} $msg -> target cmd] {
        $obj _send "PRIVMSG $target :\001$cmd\001"
        return true
    }
    
    #/clear
    if [regexp {^clear.*} $msg] {
        $obj clearScrollback
        return true
    }
    
    #/mode
    if [regexp {^mode ?(.*)} $msg -> msg] {
        #if [regexp {^(\[^ \]+) (.*)} $msg -> channOrNick msg] {
        #    puts herp
        #} else {
        #    set channOrNick [$obj getChannel]
        #}
        
        # Ban
        if [regexp "\\+b (\[^ \]+) ?(.*)" $msg -> target reason] {
            if { [string length $reason] > 0 } {
                set reason $Pref::defaultBan
            }
            $obj _send "mode +b $target $reason"
            return true
        }
    }
    
    #/ban
    if [regexp "^ban (\[^ \]+) ?(.*)" $msg -> mTarget mReason] {
        if {[string length $mReason] > 0} {
            set mReason $Pref::defaultBan
        }
        $obj requestBan $mTarget "*!user@domain" false $mReason
        return true
    }
    #/kb
    if [regexp "^kb (\[^ \]+) ?(.*)" $msg -> mTarget mReason] {
        if {[string length $mReason] > 0} {
            set mReason $Pref::defaultBan
        }
        $obj requestBan $mTarget "*!user@domain" true $mReason
        return true
    }

    
    #### Misc commands that are tested to work ###
    #/admin
    #/botmotd
    #/credits
    #/dns
    #/help
    #/helpop
    #/ignore
    #/ison
    #/knock
    #/license
    #/links
    #/list
    #/lusers
    #/map
    #/module
    #/motd
    #/notify | /watch
    #/rules
    #/stats
    #/time
    #/userhost
    #/userip
    #/version (to Server)
    #/vhost
    #/who
    #/whois
    #/whowas
    set thingsToIgnore "(admin|botmotd|credits|dns|help|helpop|ignore|ison|license|links|list|lusers|map|motd|module|notify|watch|stats|time|userhost|userip|version|vhost|who|whois|whowas)"
    if [regexp "^$thingsToIgnore\(.*\)" $msg -> cmd derp] {
        return false
    }
    #return true
    Log D "SENDING:    $msg"
    return false

    
    ############TODO
    #/chat
    #/notice
    #/partall
    #/slap {nick}
    
    #/cycle?
        #/mode {#channel|nick} [[+|-]modechars [parameters]]
    #/modes
    #/setname
    #/silence {+/-nick}
}

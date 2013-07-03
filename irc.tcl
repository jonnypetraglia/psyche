#input is mCode, mTarget (channel? nick?), mMsg

proc getTitle {mCode} {
    switch $mCode {
	001 {
	    #RPL_WELCOME
	    return \[Welcome\]
	}
	002 {
	    #RPL_YOURHOST
	    return \[Welcome\]
	}
	003 {
	    #RPL_CREATED
	    return \[Welcome\]
	}
	004 {
	    #RPL_MYINFO
	    return \[Welcome\]
	}
	005 {
	    #RPL_BOUNCE
	    return \[Support\]
	}
	250 {
		#RPL_STATSDLINE (Freenode)
		return \[Stats\]
	}
	251 {
	    #RPL_LUSERCLIENT
	    return \[Users\]
	}
	252 {
	    #RPL_LUSEROP
	    return \[Users\]
	}
	254 {
	    #RPL_LUSERCHANNELS
	    return \[Users\]
	}
	253 {
	    #RPL_LUSERUNKNOWN 
	    return \[Users\]
	}
	255 {
	    #RPL_LUSERME
	    return \[Users\]
	}
	265 {
	    #RPL_LOCALUSERS
	    return \[Users\]
	}
	266 {
	    #RPL_GLOBALUSERS
	    return \[Users\]
	}
	322 {
	    #RPL_LIST 
	    # Use this to update channel list
	    return ""
	}
	323 {
	    #RPL_LISTEND
	    # Use this to update channel list
	    return ""
	}
	328 {
	    #RPL_CHANNEL_URL 
	    # ???
	    # Received after joining a channel, I think
	}
	332 {
	    #RPL_TOPIC
	    return \[Topic\]
	}
	333 {
	    #RPL_TOPICWHOTIME
	    return \[Topic\]
	}
	353 {
	    #RPL_NAMREPLY 
	    # Use this to update nicklist
	    return ""
	}
	366 {
	    #RPL_ENDOFNAMES
	    # Use this to update nicklist
	    return ""
	}
	372 {
	    #RPL_MOTD
	    return \[MOTD\]
	}
	375 {
	    #RPL_MOTDSTART
	    return \[MOTD\]
	}
	376 {
	    #RPL_ENDOFMOTD
	    return \[MOTD\]
	}
	433 {
		#ERR_NICKNAMEINUSE 
		return \[ERROR\]
	}
	477 {
	    #ERR_NEEDREGGEDNICK
	    return \[ERROR\]
	}
	486 {
		#ERR_NONONREG 
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
		debug "Joining: $"
		$obj joinChan $chann $channPass
	}
	return true

	
	#/msg
	#/part
	#/partall
	#/quit
	#/me
	#/nick
	    #"You are now known as"
	#/notice
	#/ping
	#/query?
	#/ignore
	#/chat
	#/help
	#/whois
	#/who
	#/whowas
	#/ison
	#/cycle?
	#/motd
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
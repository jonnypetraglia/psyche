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
	328 {
	    
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
	477 {
	    #ERR_NEEDREGGEDNICK
	    return \[Err\]
	}
	default {
	    return \[$mCode\]
	}
    }
}
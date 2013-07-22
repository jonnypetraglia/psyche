variable which_linux_player
variable LINUX_ALL_PLAYERS

proc playSound {sound} {
    if {![info exists LINUX_ALL_PLAYERS]} {
        set LINUX_ALL_PLAYERS [list \
            [list mplayer "-really-quiet"] \
            [list play ""] \
            [list cvlc ""] \
            [list mpg123 ""] \      ;# Only works for mp3
            ]   ;# wav only: aplay || cat $sount > /dev/pcsp
    }
    switch $::PLATFORM {
        $::PLATFORM_MAC {
            catch {exec "afplay" "[file nativename [file normalize $sound]]" "&"}
        }
        $::PLATFORM_WIN {
            catch {exec "[pwd]/sap" "[file nativename [file normalize $sound]]" "&"}
        }
        default {
            if {![info exists which_linux_player]} {
                foreach pl $LINUX_ALL_PLAYERS {
                    catch {
                        exec which [lindex $pl 0]
                        set which_linux_player $pl
                    }
                    if {[info exists which_linux_player]} {
                        break
                    }
                }
                if {![info exists which_linux_player]} { puts "NO PLAYER FOUND"; return;}
            }
            catch {exec [lindex $which_linux_player 0] [lindex $which_linux_player 1] "[file nativename [file normalize $sound]]" "&"}
        }
    }
}
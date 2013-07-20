 proc playSound {sound} {
 
	switch $::this(platform) {
		"macosx" {
			exec "afplay" "[file nativename [file normalize $sound]]" "&"
		}
		"windows" {
			catch {exec "[pwd]/sap" "[file nativename [file normalize $sound]]" "&"}
		}
		default {
			exec "mplayer" "[file nativename [file normalize $sound]]" "&"
		}
	}
 }
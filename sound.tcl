 proc playSound {sound} {
 
	switch $::this(platform) {
		"macosx" {
			catch {exec "afplay" "[file nativename [file normalize $sound]]" "&"}
		}
		"windows" {
			catch {exec "[pwd]/sap" "[file nativename [file normalize $sound]]" "&"}
		}
		default {
			catch {exec "mplayer" "[file nativename [file normalize $sound]]" "&"}
		}
	}
 }
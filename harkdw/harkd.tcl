#l:
package provide harkdw 0.1
package require Tk
proc harkdc-set-handle { args } {
    global HARKD_HANDLE
    foreach {var val} $args {
	set HARKD_HANDLE($var) $val
    }
}
proc harkdc-stop { } {
    global HARKD_FP HARKD_HANDLE tcl_platform
    if {[info exists HARKD_FP]} {
	catch { close $HARKD_FP }
	catch { unset HARKD_FP }
	if {$tcl_platform(platform) eq {windows}} {
	    catch { exec taskkill /f /im harkdc.exe }
	}
	if {[info exists HARKD_HANDLE(-stop)]} {
	    eval $HARKD_HANDLE(-stop)
	}
	
    }
}
proc harkdc-isrunning { } {
    global HARKD_FP
    return [info exists HARKD_FP]
}
proc harkdc { args } {
    global HARKD_FP HARKD_HANDLE env
    harkdc-stop
    puts stderr "harkdc $args"
    fconfigure stderr -buffering none
    set env(UTERM_NO_STDERR) 1
    set HARKD_FP [open |[list harkdc {*}$args] rb]
    fconfigure $HARKD_FP -blocking 0 
    fileevent $HARKD_FP readable {
	global HARKD_FP 
	if {[gets $HARKD_FP line] < 0} {
	    if {[eof $HARKD_FP]} {
		harkdc-stop
	    }
	} else {
	    puts stderr "Line: $line"
	    if {[info exists HARKD_HANDLE(-line)]} {
		$HARKD_HANDLE(-line) $line
	    }
	}
    }
}
proc harkd-open { url } {
    global tcl_platform
    if {$tcl_platform(platform) eq {windows}} {
	puts $url
	exec cmd.exe /C start $url $url &
    } else {
	catch { exec xdg-open $url } 
    }
}

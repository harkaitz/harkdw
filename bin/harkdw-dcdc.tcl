#!/usr/bin/env wish
lappend auto_path [file normalize [file dirname [info script]]/..]
package require harkdw
package require Tk
proc harkdw-dcdc { args } {
    global env tcl_platform
    set env(harkd_DEBUG) 1
    if { $tcl_platform(platform) eq {unix}} {
	set env(PATH) [file dirname [info nameofexecutable]]:$env(PATH)
    }
    harkd-show-interface -title "DC/DC Tester."
    harkdw-define-option-number 1 0 Vin    "Vin"   4      "(V)   Input tension."                      0   20     0.1
    harkdw-define-option-number 2 0 CH     "CH"    1      "(1|2) Channel to use."                     1   2      1
    harkdw-define-option-number 3 0 Imaxin "Iin"   5      "(A)   Maximun input current."              0.1 10     0.1   
    harkdw-define-option-number 1 1 Imax   "Iout"  0.8    "(A)   Maximun output current."             0.1 10     0.1
    harkdw-define-option-number 2 1 N      "N"     10     "(N)   Number of points."                   1   200    1
    harkdw-define-option-number 3 1 Tstep  "Tstep" 1000   "(ms)  Time to wait for each measurement."  1   100000 1
}
if {[file tail [info script]] eq {harkdw-dcdc.tcl}} { harkdw-dcdc }

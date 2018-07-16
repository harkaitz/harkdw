#!/usr/bin/env tclsh
lappend auto_path [file normalize [file dirname [info script]]/../..]
package require harkdw
package require Tk
proc harkdw-dcdc { args } {
    harkd-show-interface -title "DC/DC Tester."
    harkdw-define-option-number Vin   4     "(V) Input tension."         0   20  0.1
    harkdw-define-option-number  Imax 0.8     "(A) Maximun input tension."  0.1 10  0.1
    harkdw-define-option-number N     10    "(N)  Number of points."      1   200 1
    harkdw-define-option-number Tstep 1000  "(ms) Time to wait for each measurement." \
	1 100000 1
    harkdw-define-option-number CH    1     "(1|2) Channel to use." \
	1 2 1
}
harkdw-dcdc

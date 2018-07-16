#l:
package provide harkdw 0.1
package require Tk
set HARKDW_URL "https://github.com/harkaitz/harkdw"
set EHU_URL "https://www.ehu.eus/es/web/ingeniaritza-bilbo/"
proc harkd-show-interface { args } {
    global HARKD_TEST_OPTIONS
    set o(-title)      "DC/DC Tester."
    set o(-width)      750
    set o(-height)     600
    set o(-tool-opts)  [list -compound left -borderwidth 0 -padx 1]
    set o(-title-cmd)  { }
    set o(-test)       {DC/DC}
    set o(-test-doc)   {test-dcdc.gif}
    set frame_options { -relief raised -borderwidth 1 -width 700}
    foreach {var val} $args {
	set o($var) $val
    }
    ######################################################################################
    ## Set title.
    wm title . "HARKD - $o(-title)"
    wm minsize . $o(-width) $o(-height)
    wm maxsize . $o(-width) $o(-height)
    


    ######################################################################################
    ## Configure toolbar.
    pack [frame .top -width 1000 {*}$frame_options] \
	-side top -fill both
    ## Create About buttons.
    button .top.about_harkd -text "About HARKD" -image harkd.gif -borderwidth 0 -command {
	global HARKDW_URL
	harkd-open $HARKDW_URL
    }
    button .top.about_ehu -text "About UPV/EHU" -image ehu.gif -borderwidth 0 -command {
	global EHU_URL
	harkd-open $EHU_URL
    }
    pack .top.about_harkd .top.about_ehu -side right
    ## Create Title logo and text.
    font create TitleFont -family Arial -size 22 -weight bold
    pack [button .top.title -text $o(-title) \
	      -font TitleFont -background red -foreground white {*}$o(-tool-opts)] \
	-side left
    label .top.sep1 -text "|" ; pack .top.sep1 -side left
    ## Create controls.
    harkdc-set-handle -stop {
	.top.start configure -text "RESTART" -image restart.gif
    }
    button .top.start -text "START  " -image start.gif {*}$o(-tool-opts) \
	-command [string map [list %t $o(-test)] {
	    global HARKD_TEST_OPTIONS
	    if {[harkdc-isrunning]} {
		harkdc-stop
	    } else {
		.body.c.output delete 1.0 end
		.top.start configure -text "STOP" -image stop.gif
		set command [list %t]
		foreach name [array names HARKD_TEST_OPTIONS] {
		    lappend command $name=$HARKD_TEST_OPTIONS($name)
		}
		harkdc {*}$command
	    }
	}]
    ## Output control.
    set HARKD_TEST_OPTIONS(output) output.xlsx
    button .top.open -text "OPEN" -image spreadsheet.gif {*}$o(-tool-opts) -command {
	global HARKD_TEST_OPTIONS
	if {[file exists $HARKD_TEST_OPTIONS(output)] == 0} {
	    error "Please rerun the test."
	}
	harkd-open $HARKD_TEST_OPTIONS(output)
    }
    button .top.saveto -text "SAVE TO" -image saveto.gif {*}$o(-tool-opts) -command {
	global HARKD_TEST_OPTIONS
	set f [tk_getSaveFile              \
		   -defaultextension .xlsx \
		   -filetypes {
		       {Excel {.xlsx}}
		   } \
		   -initialfile $HARKD_TEST_OPTIONS(output)]
	if {[file exists $f]} { file delete $f }
    }

    pack .top.start .top.saveto .top.open -side left
    ###############################################################################
    ## Body.
    # Create body.
    proc scrollpane_cfg {w wide high} {
	set newSR [list 0 0 $wide $high]
	if {![string equal [$w.c cget -scrollregion] $newSR]} {
	    $w.c configure -scrollregion $newSR
	}
    }

    pack [frame     .body  {*}$frame_options] -side top -expand yes -fill both
    
    pack [canvas    .body.c    \
	      -relief flat     \
	     ]  \
	-side left -expand yes -fill both 
    
    
    
    # Layout body with grid.
    frame .body.c.manual {*}$frame_options
    frame .body.c.options {*}$frame_options
    font create LogFont -family Courier -size 9
    text  .body.c.output -font LogFont
    pack .body.c.manual .body.c.options .body.c.output -fill both
    
    
    #.text window create end -window .f3
    # Set image.
    catch {
	label .body.c.manual.image -image $o(-test-doc)
	pack  .body.c.manual.image
    }

    harkdc-set-handle -line harkdw-handle-input
}




proc harkdw-handle-input { line } {
    if {[regexp {^Error: (.*)} $line ign err]} {
	.body.c.output insert end $line\n
    } else {
	.body.c.output insert end $line\n
    }
}





###########################################################################
proc harkdw-define-option { name value descr widget args } {
    global HARKD_TEST_OPTIONS
    set HARKD_TEST_OPTIONS($name) $value
    set fr .body.c.options.f$name
    pack [frame $fr] -side top -fill both
    pack [label $fr.l -text "$name: " -width 10 -anchor nw] -side left
    pack [$widget $fr.e {*}$args] -side left
    pack [label $fr.d -text $descr] -side left -padx 0
}
proc harkdw-define-option-text { name value descr } {
    harkdw-define-option $name $value $descr \
	entry \
	-textvariable HARKD_TEST_OPTIONS($name)
}
proc harkdw-define-option-number { name value descr min max step } {
    harkdw-define-option $name $value $descr    \
	spinbox -from $min -to $max -increment $step -width 5 \
	-textvariable HARKD_TEST_OPTIONS($name)
}

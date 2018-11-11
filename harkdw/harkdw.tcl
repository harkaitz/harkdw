#l:
package provide harkdw 0.1
package require Tk
source [file dirname [info script]]/images.tcl
set HARKDW_URL "http://www.harkaitzv.dynu.com/harkd"
set EHU_URL    "https://www.ehu.eus/es/web/ingeniaritza-bilbo/"
set AUTHOR     "Harkaitz Agirre Ezama"


set HELP_URL   [file native [file dirname [info nameofexecutable]]/harkd-manual.pdf]
if {[file exists $HELP_URL] == 0} {
    set HELP_URL "http://www.harkaitzv.dynu.com/files/harkd-manual.pdf"
}
set HARKD_GUI_OPTIONS(-title)      "DC/DC Tracer"
set HARKD_GUI_OPTIONS(-width)      820
set HARKD_GUI_OPTIONS(-height)     600
set HARKD_GUI_OPTIONS(-tool-opts)  [list -compound top -borderwidth 0 -padx 1]
set HARKD_GUI_OPTIONS(-title-cmd)  { }
set HARKD_GUI_OPTIONS(-test)       {DC/DC}
set HARKD_GUI_OPTIONS(-test-doc)   {test-dcdc.gif}
set HARKD_GUI_OPTIONS(-version)    0.1


font create Options -family Arial -size 9 -weight bold



proc harkd-show-interface { args } {
    global HARKD_TEST_OPTIONS HARKD_GUI_OPTIONS AUTHOR
    set frame_options { -relief raised -borderwidth 1 -width 700}
    foreach {var val} $args {
	set o($var) $val
    }
    
    ######################################################################################
    ## Set title.
    wm title . "HARKD - $HARKD_GUI_OPTIONS(-title)"
    wm minsize . $HARKD_GUI_OPTIONS(-width) $HARKD_GUI_OPTIONS(-height)
    wm maxsize . $HARKD_GUI_OPTIONS(-width) $HARKD_GUI_OPTIONS(-height)
    wm iconphoto . -default harkd.gif


    ######################################################################################
    ## Configure toolbar.
    pack [frame .top -width 1000 {*}$frame_options] \
	-side top -fill both
    ## Create About buttons.
    button .top.about_harkd -text "" -image harkd.gif -width 70 -borderwidth 0 -command {
	global HARKDW_URL
	harkd-open $HARKDW_URL
    }
    button .top.about_ehu -text "v$HARKD_GUI_OPTIONS(-version) $AUTHOR" -image ehu.gif \
	-compound top -borderwidth 0 -command {
	global EHU_URL
	harkd-open $EHU_URL
    }
    pack .top.about_harkd .top.about_ehu -side right
    ## Create Title logo and text.
    font create TitleFont -family Arial -size 23 -weight bold
    pack [button .top.title -text $HARKD_GUI_OPTIONS(-title) \
	      -font TitleFont -foreground "#0f70b7" {*}$HARKD_GUI_OPTIONS(-tool-opts)] \
	-side left
    label .top.sep1 -text "|" ; pack .top.sep1 -side left
    ## Create controls.
    harkdc-set-handle -stop {
	.top.start configure -text "Restart" -image restart.gif
    }
    button .top.start -text " Start " -image start.gif {*}$HARKD_GUI_OPTIONS(-tool-opts) \
	-command [string map [list %t $HARKD_GUI_OPTIONS(-test)] {
	    global HARKD_TEST_OPTIONS
	    if {[harkdc-isrunning]} {
		harkdc-stop
	    } else {
		.body.c.output delete 1.0 end
		.top.start configure -text "  Stop " -image stop.gif
		set command [list %t]
		foreach name [array names HARKD_TEST_OPTIONS] {
		    lappend command $name=$HARKD_TEST_OPTIONS($name)
		}
		harkdc {*}$command
	    }
	}]
    ## Output control.
    set HARKD_TEST_OPTIONS(output) output.xlsx
    button .top.open -text "  Open " -image spreadsheet.gif {*}$HARKD_GUI_OPTIONS(-tool-opts) -command {
	global HARKD_TEST_OPTIONS
	if {[file exists $HARKD_TEST_OPTIONS(output)] == 0} {
	    error "Please rerun the test."
	}
	harkd-open $HARKD_TEST_OPTIONS(output)
    }
    button .top.saveto -text "Save to" -image saveto.gif {*}$HARKD_GUI_OPTIONS(-tool-opts) -command {
	global HARKD_TEST_OPTIONS
	set f [tk_getSaveFile              \
		   -defaultextension .xlsx \
		   -filetypes {
		       {Excel {.xlsx}}
		   } \
		   -initialfile $HARKD_TEST_OPTIONS(output)]
	if {[file exists $f]} { file delete $f }
    }
    button .top.help -text "  Help " -image help.gif {*}$HARKD_GUI_OPTIONS(-tool-opts) -command {
	global HELP_URL
	harkd-open $HELP_URL
    }
    button .top.exit -text "  Exit " -image exit.gif {*}$HARKD_GUI_OPTIONS(-tool-opts) -command {
	exit 0
    }
    pack .top.start .top.saveto .top.open .top.help .top.exit -side left
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
	label .body.c.manual.image -image $HARKD_GUI_OPTIONS(-test-doc)
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
proc harkdw-define-option { r c name txt value descr widget args } {
    global HARKD_TEST_OPTIONS
    set HARKD_TEST_OPTIONS($name) $value
    set fr .body.c.options.f$name
    # pack [frame $fr] -side top -fill both
    grid [frame $fr -width 450] -row $r -column $c -sticky W
    
    pack [label $fr.l -text "$txt: " -width 7 -anchor nw -font Options] -side left -padx 5
    pack [$widget $fr.e {*}$args] -side left
    pack [label $fr.d -text $descr -font Options] -side left -padx 0
}
proc harkdw-define-option-text { r c name txt value descr } {
    harkdw-define-option $r $c $name $txt $value $descr \
	entry \
	-textvariable HARKD_TEST_OPTIONS($name)
}
proc harkdw-define-option-number { r c name txt value descr min max step } {
    harkdw-define-option $r $c $name $txt $value $descr    \
	spinbox -from $min -to $max -increment $step -width 5 \
	-textvariable HARKD_TEST_OPTIONS($name)
}

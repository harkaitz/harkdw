#l:
TCL_SOURCES ?=$(shell ls *.tcl | sed '/pkgIndex.tcl/d')
help: help-tcl
help-tcl:
	@echo "==== TCL VARIABLES ===================="
	@echo "TCL_SOURCES=$(TCL_SOURCES)"
	@echo "==== Targets =========================="
	@echo "pkgIndex.tcl : Creates a package index. (all) (all-tcl)"
	@echo "tcl-wrappers : Creates wrappers in bin. (all) (all-tcl)"
	@echo ""
all: all-tcl

## -----------------------------------------------------------------------------------
all-tcl: pkgIndex.tcl
pkgIndex.tcl: $(TCL_SOURCES) 
	echo 'pkg_mkIndex -verbose . $(TCL_SOURCES)' | tclsh

TCL_SCRIPT_DIR  =bin
TCL_SCRIPT_LOAD =[file dirname [file normalize [info script]]]/../..
all-tcl: tcl-wrappers
tcl-wrappers: pkgIndex.tcl
	@mkdir -p $(TCL_SCRIPT_DIR)
	@sed -n 's/.*@tclrun://gp' *.tcl | while read line;do                       \
	  name="`echo "$$line" | sed 's|:.*||'`";                                   \
	  prog="`echo "$$line" | sed 's|^[^:]*:||'`";                               \
	  echo Generating "bin/$$name ...";                                         \
	  echo '#!/usr/bin/env tclsh'                  > $(TCL_SCRIPT_DIR)/$$name ; \
	  echo 'lappend auto_path $(TCL_SCRIPT_LOAD)' >> $(TCL_SCRIPT_DIR)/$$name ; \
	  echo 'package require hrkbase'              >> $(TCL_SCRIPT_DIR)/$$name ; \
	  echo 'package require $(notdir $(PWD))'     >> $(TCL_SCRIPT_DIR)/$$name ; \
	  echo "$$prog"                               >> $(TCL_SCRIPT_DIR)/$$name ; \
	  chmod +x $(TCL_SCRIPT_DIR)/$$name;                                        \
	done
install:

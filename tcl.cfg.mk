TARGET  ?=x86_64-linux-gnu
PATH    :=/home/harkaitz/.local/bin:$(PATH)
TCLC    :=$(TARGET)-htcl
PREFIX  :=/usr/local
EXE     :=
LIBS    ?=
DESTDIR ?=
ifneq ($(TCL_PACKAGE),)
all: pkgIndex.tcl
pkgIndex.tcl : $(shell echo *.tcl | sed 's|pkgIndex.tcl||')
	     echo 'pkg_mkIndex -verbose .' | tclsh
install: all
	mkdir -p $(DESTDIR)$(PREFIX)/lib/tcl8.6/$(TCL_PACKAGE)
	cp -vr * $(DESTDIR)$(PREFIX)/lib/tcl8.6/$(TCL_PACKAGE)
endif

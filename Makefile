all:
include tcl.mk
####### ICONS ##############################################################
ICONS += $(shell echo ico/*.gif)
ICONS += ico/test-dcdc.gif
ico/test-dcdc.gif: img/tests/dcdc/DCDC.dia
	hrkdia -c png $< && hrkgimp -o $@ $(basename $<).png
pkgIndex.tcl : images.tcl
images.tcl: $(ICONS)
	echo "package provide harkdw 0.1" > images.tcl
	hrkbase64 -t $(ICONS) >> images.tcl
####### BINARY DISTRIBUTION ################################################
OUTDIR=/tmp/harkdw
DISTDIR=$(HOME)/.local/harkdw
WIN_HARKDC=$(HOME)/.local/i686-w64-mingw32/usr/bin/harkdc.exe
WIN_HARKDW_TESTS=\
  $(OUTDIR)/windows/harkdw-dcdc-32.exe \
  $(OUTDIR)/windows/harkdw-dcdc-64.exe
DISTFILES=$(WIN_HARKDC) $(WIN_HARKDW_TESTS)
dist: $(DISTFILES)
	mkdir -p $(DISTDIR)
	cp -rv $(DISTFILES) $(DISTDIR)
$(OUTDIR)/windows/%-32.exe : bin/%.tcl $(shell echo *.tcl) img/harkdw.ico
	mkdir -p $(dir $@)
	hrktcl -o $@ -b 32 -m wish -w $< harkdw img/harkdw.ico
$(OUTDIR)/windows/%-64.exe : bin/%.tcl $(shell echo *.tcl) img/harkdw.ico
	mkdir -p $(dir $@)
	hrktcl -o $@ -b 64 -m wish -w $< harkdw img/harkdw.ico





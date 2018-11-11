HCONV=hconv
HENC=henc

all:
include ../tcl.cfg.mk
####### ICONS ##############################################################
ICONS += $(addsuffix .gif,$(basename $(shell find ../ico -path *.gif -or -path *.png)))
../ico/harkd.gif : ../img/harkd.gif
	convert -resize 55x55 $< $@
../ico/%.gif : ../ico/%.png
	convert -resize 32x32 $< $@



ICONS += ../ico/test-dcdc.gif
../ico/test-dcdc.gif: ../img/tests/dcdc/DCDC.dia
	$(HCONV) -o $@ $<
pkgIndex.tcl : images.tcl
images.tcl: $(ICONS)
	echo "package provide harkdw 0.1" > images.tcl
	$(HENC) -f tcl $(ICONS)          >> images.tcl

####### BINARY ##############################################################
B_BINARY=../dist/$(TARGET)/bin/harkdw$(EXE)
I_BINARY=$(DESTDIR)$(PREFIX)/bin/harkdw$(EXE)

binary: $(B_BINARY)
$(B_BINARY): ../bin/harkdw-dcdc.tcl pkgIndex.tcl $(shell echo *.tcl)
	mkdir -p $(dir $@)
	htcl --host=$(TARGET) -- -tk -o $@ ../bin/harkdw-dcdc.tcl -lharkdw
install-binary: $(I_BINARY)
$(I_BINARY): $(B_BINARY)
	mkdir -p $(dir $(I_BINARY))
	cp -v $(B_BINARY) $(I_BINARY)

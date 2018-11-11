all:
	$(MAKE) -C harkdw
install:
	$(MAKE) -C harkdw install
install-binary:
	$(MAKE) -C harkdw install-binary
binary:
	$(MAKE) -C harkdw binary
clean:
	rm -rf dist

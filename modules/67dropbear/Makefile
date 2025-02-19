INSTDIR=$(MODULEDIR)/67dropbear

.PHONY: install

install:
	mkdir -p $(INSTDIR)
	install -m 0644 50-udev-pty.rules $(INSTDIR)/
	install -m 0755 dropbear-start.sh dropbear-stop.sh $(INSTDIR)/
	install -m 0755 module-setup.sh $(INSTDIR)/

include config.mk

export DESTDIR=
export MODULEDIR=${DESTDIR}$(DRACUT_MODULEDIR)

SUBDIRS=modules/67dropbear
DISTNAME=dracut-dropbear-$(shell git describe --tags | sed s:v::)

.PHONY: install all clean dist $(SUBDIRS)

all: $(SUBDIRS)

install: $(SUBDIRS)
	mkdir -p $(DESTDIR)/etc/dracut.conf.d/
	cp 04-dropbear.conf $(DESTDIR)/etc/dracut.conf.d/

clean: $(SUBDIRS)
	rm -f dracut-dropbear-*gz config.mk

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

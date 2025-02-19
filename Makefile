include config.mk

export DESTDIR=
export MODULEDIR=${DESTDIR}$(DRACUT_MODULEDIR)

SUBDIRS=modules/67dropbear

.PHONY: install all clean dist $(SUBDIRS)

all: $(SUBDIRS)

install: $(SUBDIRS)
	mkdir -p $(DESTDIR)/etc/dracut.conf.d/
	cp 04-dracut-dropbear.conf $(DESTDIR)/etc/dracut.conf.d/

clean: $(SUBDIRS)
	rm -f dracut-dropbear-*gz config.mk

$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

DISTNAME=dracut-dropbear-$(shell git describe --tags | sed s:v::)
dist:
	git archive --format=tar --prefix=$(DISTNAME)/ HEAD | gzip -9 > $(DISTNAME).tar.gz

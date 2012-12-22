NULL :=
FULL_LZMA := $(wildcard full/*.lzma)
WEBKIT_LZMA := $(wildcard webkit/*.lzma)
QUICK_LZMA := $(wildcard benchmark/*.lzma)
ALL_LZMA:= $(FULL_LZMA) $(WEBKIT_LZMA) $(QUICK_LZMA)
ALL_TRACES := $(ALL_LZMA:.lzma=.trace)

all: $(ALL_TRACES)
benchmarks: $(QUICK_LZMA:.lzma=.trace)

%.trace: %.lzma csi-bind
	lzma -cd $< | ./csi-bind > $@

csi-bind: csi-bind.c
	$(CC) $(CFLAGS) $(shell pkg-config cairo --cflags) $^ $(shell pkg-config cairo --libs) -lcairo-script-interpreter -o $@
csi-trace: csi-trace.c
	$(CC) $(CFLAGS) $(shell pkg-config cairo --cflags) $^ $(shell pkg-config cairo --libs) -lcairo-script-interpreter -o $@

##########################################################
# Some targets to make and upload a snapshot of the traces
# Based on cairo/build/Makefile.am.releasing
# Use:
# 	make snapshot snapshot-upload

TAR_OPTIONS = --owner=0 --group=0

RELEASE_OR_SNAPSHOT   = snapshot
RELEASE_UPLOAD_HOST   = cairographics.org
RELEASE_UPLOAD_BASE   = /srv/cairo.freedesktop.org/www
RELEASE_UPLOAD_DIR    = $(RELEASE_UPLOAD_BASE)/$(RELEASE_OR_SNAPSHOT)s
RELEASE_URL_BASE      = http://cairographics.org/$(RELEASE_OR_SNAPSHOT)s
RELEASE_ANNOUNCE_LIST = cairo-announce@cairographics.org

snapshots := snapshots
snapshot_name := $(shell date '+%Y%m%d')-$(shell git rev-parse HEAD | cut -c 1-6)
tar_file := $(snapshots)/cairo-traces-$(snapshot_name).tar.gz
sha1_file := $(tar_file).sha1
gpg_file := $(sha1_file).asc

SNAPSHOT_DIST := Makefile README $(wildcard *.c) $(QUICK_LZMA)
$(tar_file): $(SNAPSHOT_DIST)
	@mkdir -p $(snapshots)
	@echo Generating snapshot tarball: $(tar_file)
	@tar $(TAR_OPTIONS) --transform 's#^#cairo-traces-$(snapshot_name)/#' -czvf $(tar_file) $(SNAPSHOT_DIST)

$(sha1_file): $(tar_file)
	sha1sum $^ > $@

$(gpg_file): $(sha1_file)
	@echo "Please enter your GPG password to sign the checksum."
	gpg --armor --sign $^

snapshot-dirty:
	@if test -n "$(shell git ls-files -m $(SNAPSHOT_DIST))"; then \
		echo "Local tree has uncommitted modifications. Please commit these changes before making a snapshot." ; \
		exit 1; \
	fi

snapshot: snapshot-dirty $(gpg_file)

snapshot-upload: snapshot
	scp $(tar_file) $(sha1_file) $(gpg_file) $(RELEASE_UPLOAD_HOST):$(RELEASE_UPLOAD_DIR)

############################################################

clean:
	rm -f $(ALL_TRACES) csi-bind csi-trace $(snapshots)

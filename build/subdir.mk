# SUBDIR:          subdirs
MODE=subdir

all: subdirs

.PHONY: subdirs
subdirs:
	@for dir in $(SUBDIR); do \
		$(MAKE) -C $$dir all MAKEFLAGS= || exit 1; \
	done

.PHONY: clean
clean:
	@for dir in $(SUBDIR); do \
		$(MAKE) -C $$dir clean  MAKEFLAGS= || exit ?; \
	done

.PHONY: debug
debug:
	for dir in $(SUBDIR); do \
		$(MAKE) -C $$dir debug || exit ?; \
	done

.PHONY: help
help:
	@echo "subdir: Build Sub Directories"
	@echo ""
	@echo "    SUBDIR:          subdirs"
	@echo ""

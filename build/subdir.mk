# SUBDIR:          subdirs

all: subdirs

.PHONY: subdirs
subdirs:
	@for dir in $(SUBDIR); do \
		$(MAKE) -C $$dir all BUILD_OUTPUT=$(BUILD_OUTPUT) MAKEFLAGS= || exit ?; \
	done

.PHONY: clean
clean:
	@for dir in $(SUBDIR); do \
		$(MAKE) -C $$dir clean BUILD_OUTPUT=$(BUILD_OUTPUT) MAKEFLAGS= || exit ?; \
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

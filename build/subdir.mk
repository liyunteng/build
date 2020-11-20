# SUBDIR:          subdirs
MODE=subdir

default: all

all: subdirs

subdirs:
	@for dir in $(SUBDIR); do \
		$(MAKE) -C $$dir all BUILD_OUTPUT=$(BUILD_OUTPUT) MAKEFLAGS= || exit 1; \
	done

.PHONY: clean
clean:
	@for dir in $(SUBDIR); do \
		$(MAKE) -C $$dir clean BUILD_OUTPUT=$(BUILD_OUTPUT) MAKEFLAGS= || exit 1;\
	done
ifeq ($(MAKELEVEL),0)
	@echo "clean done"
endif

.PHONY: showall
showall: show
	@for dir in $(SUBDIR); do \
		$(MAKE) -C $$dir show BUILD_OUTPUT=$(BUILD_OUTPUT) || exit 1; \
	done

.PHONY: help
help:
	@echo "subdir: Build Sub Directories"
	@echo ""
	@echo "    SUBDIR:          subdirs"
	@echo ""

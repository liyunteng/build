MODE := subdir
MODULE_ROOT ?= $(shell pwd)
MODULE_NAME ?= $(shell basename $(MODULE_ROOT))

SUBDIRS ?=

SUBDIRS_BUILD     := $(addsuffix -build, $(SUBDIRS))
SUBDIRS_INSTALL   := $(addsuffix -install, $(SUBDIRS))
SUBDIRS_UNINSTALL := $(addsuffix -uninstall, $(SUBDIRS))
SUBDIRS_CLEAN     := $(addsuffix -clean, $(SUBDIRS))
SUBDIRS_DISTCLEAN := $(addsuffix -distclean, $(SUBDIRS))
SUBDIRS_SHOW      := $(addsuffix -show, $(SUBDIRS))
SUBDIRS_HELP      := $(addsuffix -help, $(SUBDIRS))

unexport MODE MODULE_ROOT MODULE_NAME
unexport SUBDIRS SUBDIRS_BUILD SUBDIRS_INSTALL SUBDIRS_UNINSTALL
unexport SUBDIRS_CLEAN SUBDIRS_DISTCLEAN SUBDIRS_SHOW

include $(PROJECT_ROOT)/scripts/def.mk
######################################################################
all: build

.PHONY: build $(SUBDIRS_BUILD)
build : $(SUBDIRS_BUILD)
$(SUBDIRS_BUILD):
	$(Q1)$(MAKE) -C $(patsubst %-build,%,$@) all || exit 1

.PHONY: install $(SUBDIRS_INSTALL)
install: $(SUBDIRS_INSTALL)
$(SUBDIRS_INSTALL):
	$(Q1)$(MAKE) -C $(patsubst %-install,%,$@) install || exit 1

.PHONY: uninstall $(SUBDIRS_UNINSTALL)
uninstall: $(SUBDIRS_UNINSTALL)
$(SUBDIRS_UNINSTALL):
	$(Q1)$(MAKE) -C $(patsubst %-uninstall,%,$@) uninstall || exit 1

.PHONY: clean $(SUBDIRS_CLEAN)
clean: $(SUBDIRS_CLEAN)
$(SUBDIRS_CLEAN):
	$(Q1)$(MAKE) -C $(patsubst %-clean,%,$@) clean || exit 1


.PHONY: distclean $(SUBDIRS_DISTCLEAN)
distclean: $(SUBDIRS_DISTCLEAN) clean
$(SUBDIRS_DISTCLEAN):
	$(Q1)$(MAKE) -C $(patsubst %-distclean,%,$@) distclean || exit 1


.PHONY: showall $(SUBDIRS_SHOW) show
showall: $(SUBDIRS_SHOW) show
$(SUBDIRS_SHOW):
	$(Q1)$(MAKE) -C $(patsubst %-show,%,$@) show || exit 1


.PHONY: helpall $(SUBDIRS_HELP) help
helpall: $(SUBDIRS_HELP) help
$(SUBDIRS_HELP):
	$(Q1)$(MAKE) -C $(patsubst %-help,%,$@) help || exit 1

show: show-common
	@echo "MODE               = " $(MODE)
	@echo "MODULE_ROOT        = " $(MODULE_ROOT)
	@echo "MODULE_NAME        = " $(MODULE_NAME)
	@echo "SUBDIRS            = " $(SUBDIRS)
	@echo ""

.PHONY: help
help: help-common
	@echo "subdir.mk : Build Sub Directories"
	@echo ""
	@echo "    MODULE_ROOT         the root directory of this module"
	@echo "    MODULE_NAME         the name of this mudule"
	@echo "    SUBDIRS             subdirs"
	@echo ""

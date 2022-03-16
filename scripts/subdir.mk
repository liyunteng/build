include $(PROJECT_ROOT)/scripts/def.mk

MODE := subdir
MODULE_ROOT ?= $(shell pwd)

ifneq ($(BUILD_PWD),$(MODULE_ROOT))
X := $(MODULE_ROOT:$(BUILD_PWD)/%=%)
MODULE_NAME ?= $(X)
else
X :=
MODULE_NAME ?= $(shell basename $(MODULE_ROOT))
endif

ifneq ($(strip $(X)),)
OUTPUT_OBJ := $(OUTPUT_OBJ)/$(X)
endif

SUBDIRS ?=

SUBDIRS_BUILD     := $(SUBDIRS)
SUBDIRS_INSTALL   := $(addsuffix -install, $(SUBDIRS))
SUBDIRS_UNINSTALL := $(addsuffix -uninstall, $(SUBDIRS))
SUBDIRS_CLEAN     := $(addsuffix -clean, $(SUBDIRS))
SUBDIRS_DISTCLEAN := $(addsuffix -distclean, $(SUBDIRS))
SUBDIRS_SHOW      := $(addsuffix -show, $(SUBDIRS))
SUBDIRS_HELP      := $(addsuffix -help, $(SUBDIRS))

unexport MODE MODULE_ROOT MODULE_NAME X
unexport SUBDIRS SUBDIRS_BUILD SUBDIRS_INSTALL SUBDIRS_UNINSTALL
unexport SUBDIRS_CLEAN SUBDIRS_DISTCLEAN SUBDIRS_SHOW SUBDIRS_HELP

######################################################################
all: build

.PHONY: build $(SUBDIRS_BUILD)
build : $(SUBDIRS_BUILD)
$(SUBDIRS_BUILD):
	$(Q1)$(MAKE) -C $@ all || exit 1

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
	$(Q1)$(MAKE) -C $(patsubst %-show,%,$@) showall || exit 1

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

# MODULE_ROOT:     The root directory of this module
# MODULE_NAME:     The name of this mudule
# LIB_TYPE:        Library type [static/dynamic/all]
# SOURCE_ROOT:     Source Root Directory (default MODULE_ROOT)
# SOURCE_DIRS:     Source directories (default src)
# SOURCE_OMIT:     Ignored files
# INCLUDE_DIRS:    Include directories (default include)
# EXPORT_DIR:     Export include directories (default include)
# CONFIG_FILES:    Files copy to OUT_CONFIG
# ADDED_FILES:     Files copy to OUT_BIN
# CFLAGS:          gcc -c Flags (added -fPIC)
# CPPFLAGS:        cpp Flags
# CXXFLAGS:        g++ -c Flags
# ARFLAGS:         ar Flags (Default rcs)
# LDFLAGS:         ld Flags (Added -shared for shared)
# BUILD_VERBOSE:   verbose output (MUST Before def.mk)
# BUILD_OUTPUT:    output dir (MUST Before def.mk)
######################################################################
MODE := library
MODULE_ROOT ?= $(shell pwd)
MODULE_NAME ?= $(shell basename $(MODULE_ROOT))

# static/dynamic/all
LIB_TYPE    ?= all

# Source FileList
SOURCE_ROOT  ?= $(MODULE_ROOT)
SOURCE_DIRS  ?= src
SOURCE_OMIT  ?=

SOURCE_C   ?= $(foreach dir, $(SOURCE_DIRS), $(shell find $(abspath $(dir)) -name "*.c"))
SOURCE_CXX ?= $(foreach dir, $(SOURCE_DIRS), $(shell find $(abspath $(dir)) -name "*.cpp"))
ifneq ($(strip $(SOURCE_OMIT)),)
SOURCE_OMIT := $(addprefix $(SOURC_ROOT)/, $(SOURCE_OMIT))
SOURCE_C   := $(filter-out $(SOURCE_OMIT), $(SOURCE_C))
SOURCE_CXX := $(filter-out $(SOURCE_OMIT), $(SOURCE_CXX))
endif

include $(PROJECT_ROOT)/scripts/def.mk
include $(PROJECT_ROOT)/scripts/cmd.mk
# Object FileList
OBJECT_C   := $(SOURCE_C:$(SOURCE_ROOT)/%.c=$(OUT_OBJECT)/%.o)
OBJECT_CXX := $(SOURCE_CXX:$(SOURCE_ROOT)/%.cpp=$(OUT_OBJECT)/%.o)
DEPEND_C   := $(OBJECT_C:%.o=%.o.d)
DEPEND_CXX := $(OBJECT_CXX:%.o=%.o.d)

# Include FileList
INCLUDE_DIRS ?= $(SOURCE_ROOT)/include
# CPPFLAGS += $(foreach dir, $(SOURCE_ROOT)/$(INCLUDE_DIRS), -I$(dir))
CPPFLAGS += $(foreach dir, $(INCLUDE_DIRS), -I$(dir))
CFLAGS += -fPIC

# Config FileList
CONFIG_FILES  ?=
OUT_CONFIG_FILES := $(addprefix $(OUT_CONFIG)/, $(CONFIG_FILES))
CONFIG_FILES     := $(addprefix $(SOURCE_ROOT)/, $(CONFIG_FILES))

# Added FileList
ADDED_FILES  ?=
OUT_ADDED_FILES := $(addprefix $(OUT_BIN)/, $(ADDED_FILES))
ADDED_FILES     := $(addprefix $(SOURCE_ROOT)/, $(ADDED_FILES))

# Export dirs
EXPORT_DIR ?= $(SOURCE_ROOT)/include
EXPORT_FILES := $(foreach dir, $(EXPORT_DIR), $(shell find $(dir) -type f))
OUT_EXPORT_FILES := $(EXPORT_FILES:$(EXPORT_DIR)/%=$(OUT_INCLUDE)/%)
CPPFLAGS += -I$(EXPORT_DIR)

# Lib Name
LIB   := $(OUT_LIB)/lib$(MODULE_NAME).a
SOLIB := $(OUT_LIB)/lib$(MODULE_NAME).so

# CreateDirectory
OUT_DIRS += $(sort $(patsubst %/,%, $(OUT_ROOT) $(OUT_LIB) $(OUT_OBJECT) \
	$(dir $(OBJECT_C) $(OBJECT_CXX) $(OUT_EXPORT_FILES) $(OUT_CONFIG_FILES) $(OUT_ADDED_FILES))))

######################################################################
all: library

.PHONY: success
ifeq ($(strip $(LIB_TYPE)),static)
library: before header $(OBJECT_C) $(OBJECT_CXX) $(LIB)  after success
else ifeq ($(strip $(LIB_TYPE)),dynamic)
library: before header $(OBJECT_C) $(OBJECT_CXX) $(SOLIB) after success
else ifeq ($(strip $(LIB_TYPE)),all)
library: before header $(OBJECT_C) $(OBJECT_CXX) $(LIB) $(SOLIB) after success
endif

before: $(OUT_DIRS)

after: $(OUT_CONFIG_FILES) $(OUT_ADDED_FILES)

success:

header: $(OUT_EXPORT_FILES)


$(OBJECT_C):  $(OUT_OBJECT)/%.o : $(SOURCE_ROOT)/%.c
	$(call cmd_c,$(MODULE_NAME),$<,$@)
-include $(DEPEND_C)

$(OBJECT_CXX): $(OUT_OBJECT)/%.o : $(SOURCE_ROOT)/%.cpp
	$(call cmd_cxx,$(MODULE_NAME),$<,$@)
-include $(DEPEND_CXX)

$(LIB): $(OBJECT_C) $(OBJECT_CXX)
ifneq ($(join $(OBJECT_C),$(OBJECT_CXX)),)
ifeq ($(OBJECT_CXX),)
	$(call cmd_lib,$(MODULE_NAME),$^,$@)
else
	$(call cmd_cxxlib,$(MODULE_NAME),$^,$@)
endif
	$(call cmd_strip,$(MODULE_NAME),$^,$@)
endif

$(SOLIB): $(OBJECT_C) $(OBJECT_CXX)
ifneq ($(join $(OBJECT_C),$(OBJECT_CXX)),)
ifeq ($(OBJECT_CXX),)
	$(call cmd_solib,$(MODULE_NAME),$^,$@)
else
	$(call cmd_cxxsolib,$(MODULE_NAME),$^,$@)
endif
	$(call cmd_debuginfo,$(MODULE_NAME),$^,$@)
	$(call cmd_strip,$(MODULE_NAME),$^,$@)
endif

$(OUT_DIRS):
	$(call cmd_mkdir,$(MODULE_NAME),$@)

$(OUT_EXPORT_FILES) : $(OUT_INCLUDE)/% : $(EXPORT_DIR)/%
	$(call cmd_cp,$(MODULE_NAME),$<,$@)

$(OUT_CONFIG_FILES) : $(OUT_CONFIG)/% : $(SOURCE_ROOT)/%
	$(call cmd_cp,$(MODULE_NAME),$<,$@)

$(OUT_ADDED_FILES) : $(OUT_BIN)/% : %(SOURCE_ROOT)/%
	$(call cmd_cp,$(MODULE_NAME),$<,$@)

.PHONY: install
install:

.PHONY: uninstall
uninstall:

.PHONY: show
show: show-common
	@echo "MODE               = " $(MODE)
	@echo "MODULE_ROOT        = " $(MODULE_ROOT)
	@echo "MODULE_NAME        = " $(MODULE_NAME)
	@echo "LIB_TYPE           = " $(LIB_TYPE)
	@echo "LIB                = " $(LIB)
	@echo "SOLIB              = " $(SOLIB)
	@echo "SOURCE_ROOT        = " $(SOURCE_ROOT)
	@echo "SOURCE_DIRS        = " $(SOURCE_DIRS)
	@echo "SOURCE_OMIT        = " $(SOURCE_OMIT)
	@echo "SOURCE_C           = " $(SOURCE_C)
	@echo "OBJECT_C           = " $(OBJECT_C)
	@echo "DPEND_C            = " $(DEPEND_C)
	@echo "SOURCE_CXX         = " $(SOURCE_CXX)
	@echo "OBJECT_CXX         = " $(OBJECT_CXX)
	@echo "DEPEND_CXX         = " $(DEPEND_CXX)
	@echo "INCLUDE_DIRS       = " $(INCLUDE_DIRS)
	@echo "CONFIG_FILES       = " $(CONFIG_FILES)
	@echo "ADDED_FILES        = " $(ADDED_FILES)
	@echo "OUT_DIRS           = " $(OUT_DIRS)
	@echo "OUT_EXPORT_FILES   = " $(OUT_EXPORT_FILES)
	@echo "OUT_CONFIG_FILES   = " $(OUT_CONFIG_FILES)
	@echo "OUT_ADDED_FILES    = " $(OUT_ADDED_FILES)
	@echo "CreateResult       = " $(CreateResult)
	@echo ""


.PHONY: help
help: help-common
	@echo "library.mk : Build Library"
	@echo ""
	@echo "    MODULE_ROOT         the root directory of this module"
	@echo "    MODULE_NAME         the name of this mudule"
	@echo "    LIB_TYPE            library type [static/dynamic/all]"
	@echo "    SOURCE_ROOT         source Root Directory (default MODULE_ROOT)"
	@echo "    SOURCE_DIRS         source directories (default src)"
	@echo "    SOURCE_OMIT         ignored files"
	@echo "    INCLUDE_DIRS        include directories (default include)"
	@echo "    EXPORT_DIR          export include directory (default include)"
	@echo "    CONFIG_FILES        files copy to OUT_CONFIG"
	@echo "    ADDED_FILES         files copy to OUT_BIN "
	@echo ""

	@echo "    BUILD_VERBOSE       verbose output (MUST Before def.mk)"
	@echo "    BUILD_OUTPUT        output dir (MUST Before def.mk)"
	@echo ""
	@echo "    CFLAGS              gcc -c Flags (add -fPIC)"
	@echo "    CPPFLAGS            cpp Flags"
	@echo "    CXXFLAGS            g++ -c Flags"
	@echo "    ARFLAGS             ar Flags (Default rcs)"
	@echo "    LDFLAGS             ld Flags (Added -shared for shared)"
	@echo ""

.PHONY: clean
clean:
	$(call cmd_rm,$(MODULE_NAME),$(OUT_ROOT))

.PHONY: distclean
distclean: clean

include $(PROJECT_ROOT)/scripts/def.mk
include $(PROJECT_ROOT)/scripts/cmd.mk

MODE := bin
MODULE_ROOT := $(BUILD_PWD)

ifeq ($(MODULE_ROOT),$(BUILD_ROOT))
MODULE_PATH :=
MODULE_NAME ?= $(shell basename $(MODULE_ROOT))
else
MODULE_PATH := $(MODULE_ROOT:$(BUILD_ROOT)/%=%)
MODULE_NAME ?= $(MODULE_PATH)
endif

ifneq ($(strip $(MODULE_PATH)),)
OUTPUT_OBJ := $(OUTPUT_OBJ)/$(MODULE_PATH)
endif

ifeq ($(BUILD_VERSION),1)
	VERSIONOBJ = $(OUTPUT_OBJ)/version.o
endif

ifneq ($(VERSION),)
ifneq ($(origin VERSION), environment)
	CFLAGS += -DVERSION=\"$(VERSION)\"
	CXXFLAGS += -DVERSION=\"$(VERSION)\"
endif
endif

# Source FileList
SOURCE_ROOT  ?= $(MODULE_ROOT)
SOURCE_DIRS  ?= src
SOURCE_OMIT  ?=

SOURCE_C_FILES     ?= $(foreach dir, $(SOURCE_DIRS), $(wildcard $(dir)/*.c))
SOURCE_CXX_FILES   ?= $(foreach dir, $(SOURCE_DIRS), $(wildcard $(dir)/*.cpp))
SOURCE_FILES ?= $(SOURCE_C_FILES) $(SOURCE_CXX_FILES)
SOURCE_FILES := $(SOURCE_FILES:./%=%)
ifneq ($(strip $(SOURCE_OMIT)),)
SOURCE_FILES := $(filter-out $(foreach x,$(SOURCE_OMIT),$(x)), $(SOURCE_FILES))
endif

# object/dep files
OBJECT_FILES := $(patsubst %.c,%.o,$(patsubst %.cpp,%.o,$(SOURCE_FILES)))
OBJECT_FILES := $(addprefix $(OUTPUT_OBJ)/, $(OBJECT_FILES))
DEPEND_FILES := $(OBJECT_FILES:%.o=%.o.d)
SOURCE_FILES := $(addprefix $(SOURCE_ROOT)/, $(SOURCE_FILES))

# CPPFLAGS/CFLAGS/CXXFLAGS
INCLUDES ?= include
DEFINES  ?=
CPPFLAGS += $(addprefix -I, $(INCLUDES))
CPPFLAGS += $(addprefix -D, $(DEFINES))
# CFLAGS += -fPIC
# CXXFLAGS += -fPIC

# export header
EXPORT_HEADER_DIR   ?= include
EXPORT_HEADER_FILES ?= $(wildcard $(EXPORT_HEADER_DIR)/*)
EXPORT_HEADER_FILES := $(EXPORT_HEADER_FILES:$(EXPORT_HEADER_DIR)/%=%)
TARGET_HEADER_FILES := $(addprefix $(OUTPUT_INC)/, $(EXPORT_HEADER_FILES))

# export configs
EXPORT_CONFIG_DIR   ?= .
EXPORT_CONFIG_FILES ?=
EXPORT_CONFIG_FILES := $(EXPORT_CONFIG_FILES:$(EXPORT_CONFIG_DIR)/%=%)
TARGET_CONFIG_FILES := $(addprefix $(OUTPUT_ETC)/, $(EXPORT_CONFIG_FILES))

# export files
EXPORT_FILES_DIR ?= .
EXPORT_FILES ?=
EXPORT_FILES := $(EXPORT_FILES:$(EXPORT_FILES_DIR)/%=%)
TARGET_FILES := $(addprefix $(OUTPUT_BIN)/, $(EXPORT_FILES))

# BIN Name
BIN   ?= $(notdir $(MODULE_NAME))
ifeq ($(strip $(SOURCE_FILES)),)
BIN =
endif
BIN := $(addprefix $(OUTPUT_BIN)/, $(BIN))

######################################################################
all: build

.PHONY: build before version header bin after success
build: before version header bin after success

before:

version: $(VERSIONOBJ)

header: $(TARGET_HEADER_FILES)

after: $(TARGET_CONFIG_FILES) $(TARGET_FILES)

success:

bin: version header $(BIN)

$(BIN): $(OUTPUT_BIN)/% : $(OBJECT_FILES) $(VERSIONOBJ)
ifneq ($(strip $(OBJECT_FILES)),)
	$(call cmd_mkdir,$(MODULE_NAME),$@)
ifneq ($(strip $(SOURCE_CXX_FILES)),)
	$(call cmd_cxxbin,$(MODULE_NAME),$^,$@)
else
	$(call cmd_bin,$(MODULE_NAME),$^,$@)
endif
	$(call cmd_debuginfo,$(MODULE_NAME),$^,$@)
	$(call cmd_strip,$(MODULE_NAME),$^,$@)
endif

$(OUTPUT_OBJ)/%.o : %.c
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(call cmd_c,$(MODULE_NAME),$<,$@)

$(OUTPUT_OBJ)/%.o : %.cpp
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(call cmd_cxx,$(MODULE_NAME),$<,$@)

$(VERSIONOBJ): $(PROJECT_ROOT)/scripts/version.ver $(SOURCE_FILES)
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(Q2)$(PROJECT_ROOT)/scripts/gitver.sh $< $(OUTPUT_OBJ)/version.c
	$(call cmd_c,${MODULE_NAME},$(OUTPUT_OBJ)/version.c,$@)

# $(OUTPUT_OBJ)/%.o.d: %.c
#   $(call cmd_mkdir,$(MODULE_NAME),$@)
#   $(call cmd_cdep,$(MODULE_NAME),$<,$@,$*)

# $(OUTPUT_OBJ)/%.o.d: %.cpp
#   $(call cmd_mkdir,$(MODULE_NAME),$@)
#   $(call cmd_cxxdep,$(MODULE_NAME),$<,$@,$*)

$(TARGET_HEADER_FILES) : $(OUTPUT_INC)/% : $(EXPORT_HEADER_DIR)/%
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(call cmd_cp,$(MODULE_NAME),$^,$@)

$(TARGET_CONFIG_FILES) : $(OUTPUT_ETC)/% : $(EXPORT_CONFIG_DIR)/%
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(call cmd_cp,$(MODULE_NAME),$^,$@)

$(TARGET_FILES) : $(OUTPUT_BIN)/% : $(EXPORT_FILES_DIR)/%
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(call cmd_cp,$(MODULE_NAME),$^,$@)

ifeq ($(MAKECMDGOALS),all)
sinclude $(DEPEND_FILES)
else ifeq ($(MAKECMDGOALS),build)
sinclude $(DEPEND_FILES)
else ifeq ($(MAKECMDGOALS),)
sinclude $(DEPEND_FILES)
endif

.PHONY: install
install:


.PHONY: uninstall
uninstall:

.PHONY: show help showall
showall: show
show: show-common
	@echo "MODE                = " $(MODE)
	@echo "MODULE_ROOT         = " $(MODULE_ROOT)
	@echo "MODULE_PATH         = " $(MODULE_PATH)
	@echo "MODULE_NAME         = " $(MODULE_NAME)
	@echo "BIN                 = " $(BIN)
	@echo "SOURCE_ROOT         = " $(SOURCE_ROOT)
	@echo "SOURCE_DIRS         = " $(SOURCE_DIRS)
	@echo "SOURCE_OMIT         = " $(SOURCE_OMIT)
	@echo "SOURCE_FILES        = " $(SOURCE_FILES)
	@echo "OBJECT_FILES        = " $(OBJECT_FILES)
	@echo "DPEND_FILES         = " $(DEPEND_FILES)
	@echo "INCLUDES            = " $(INCLUDES)
	@echo "DEFINES             = " $(DEFINES)
	@echo "EXPORT_HEADER_FILES = " $(EXPORT_HEADER_FILES)
	@echo "EXPORT_CONFIG_FILES = " $(EXPORT_CONFIG_FILES)
	@echo "EXPORT_FILES        = " $(EXPORT_FILES)
	@echo "TAREGE_HEADER_FILES = " $(TARGET_HEADER_FILES)
	@echo "TARGET_CONFIG_FILES = " $(TARGET_CONFIG_FILES)
	@echo "TARGET_FILES        = " $(TARGET_FILES)
	@echo ""

.PHONY: help helpall
helpall: help
help: help-common
	@echo "bin.mk : Build executable"
	@echo ""
	@echo "    MODULE_NAME         the name of this mudule"
	@echo "    SOURCE_ROOT         source root directory (default MODULE_ROOT)"
	@echo "    SOURCE_DIRS         source directories (default src)"
	@echo "    SOURCE_OMIT         ignored files"
	@echo "    SOURCE_C_FILES      binary c source files"
	@echo "    SOURCE_CXX_FILES    binary cpp source files"
	@echo "    SOURCE_FILES        source files"
	@echo "    INCLUDES            include directories (default include)"
	@echo "    DEFINES             definitions"
	@echo "    EXPORT_HEADER_DIR   EXPORT_HEADER_FILES's directory (default include)"
	@echo "    EXPORT_CONFIG_DIR   EXPORT_CONFIG_FILES's directory"
	@echo "    EXPORT_FILES_DIR    EXPORT_FILES's directory"
	@echo "    EXPORT_HEADER_FILES files copy to OUTPUT_INC"
	@echo "    EXPORT_CONFIG_FILES files copy to OUTPUT_ETC"
	@echo "    EXPORT_FILES        files copy to OUTPUT_BIN"
	@echo "    BIN                 the target binary"
	@echo ""
	@echo "    BUILD_VERBOSE       verbose output (MUST before def.mk)"
	@echo "    BUILD_OUTPUT        output dir (MUST before def.mk)"
	@echo ""
	@echo "    CFLAGS              gcc -c Flags"
	@echo "    CPPFLAGS            cpp Flags"
	@echo "    CXXFLAGS            g++ -c Flags"
	@echo "    LDFLAGS             ld Flags"
	@echo "    LDLIBS              ld libs"
	@echo "    LOADLIBES           ld libs"
	@echo ""

.PHONY: clean
clean:
	$(call cmd_rm,$(MODULE_NAME),$(OUTPUT_ROOT))

.PHONY: distclean
distclean: clean

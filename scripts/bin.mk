include $(PROJECT_ROOT)/scripts/def.mk
include $(PROJECT_ROOT)/scripts/cmd.mk

MODE := bin
MODULE_ROOT  ?= $(shell pwd)

ifneq ($(BUILD_PWD),$(MODULE_ROOT))
X := $(MODULE_ROOT:$(BUILD_PWD)/%=%)
MODULE_NAME ?= $(X)
else
X :=
MODULE_NAME ?= $(shell basename $(MODULE_ROOT))
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
OBJECT_FILES := $(addprefix $(OUTPUT_OBJ)$(X)/, $(OBJECT_FILES))
DEPEND_FILES := $(OBJECT_FILES:%.o=%.o.d)
SOURCE_FILES := $(addprefix $(SOURCE_ROOT)/, $(SOURCE_FILES))

# CPPFLAGS/CFLAGS/CXXFLAGS
INCLUDES ?= include
DEFINES  ?=
CPPFLAGS += $(foreach x,$(INCLUDES), -I$(x))
CPPFLAGS += $(foreach x,$(DEFINES), -D$(x))
CFLAGS += -fPIC
CXXFLAGS += -fPIC

# export header
EXPORT_HEADER_DIRS  ?= include
EXPORT_HEADER_FILES ?= $(foreach dir,$(EXPORT_HEADER_DIRS), $(wildcard $(dir)/*))
EXPORT_HEADER_FILES := $(EXPORT_HEADER_FILES:$(EXPORT_HEADER_DIRS)/%=%)
TARGET_HEADER_FILES := $(addprefix $(OUTPUT_INC)/, $(EXPORT_HEADER_FILES))

# export configs
EXPORT_CONFIG_FILES ?=
TARGET_CONFIG_FILES := $(addprefix $(OUTPUT_ETC)/, $(EXPORT_CONFIG_FILES))

# export files
EXPORT_FILE_FILES ?=
TARGET_FILE_FILES := $(addprefix $(OUTPUT_BIN)/, $(EXPORT_FILE_FILES))

# BIN Name
BIN   := $(MODULE_NAME)
ifeq ($(SOURCE_FILES),)
BIN =
endif
BIN := $(addprefix $(OUTPUT_BIN)/, $(BIN))

######################################################################
all: build

.PHONY: build before after success bin
build: before bin after success

before: $(TARGET_HEADER_FILES)

after: $(TARGET_CONFIG_FILES) $(TARGET_FILE_FILES)

success:

bin: $(BIN)

$(OUTPUT_BIN)/%: $(OBJECT_FILES)
ifneq ($(OBJECT_FILES),)
	$(call cmd_mkdir,$(MODULE_NAME),$@)
ifneq ($(SOURCE_CXX_FILES),)
	$(call cmd_cxxbin,$(MODULE_NAME),$^,$@)
else
	$(call cmd_cbin,$(MODULE_NAME),$^,$@)
endif
	$(call cmd_debuginfo,$(MODULE_NAME),$^,$@)
	$(call cmd_strip,$(MODULE_NAME),$^,$@)
endif

$(OUTPUT_OBJ)$(X)/%.o : %.c
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(call cmd_c,$(MODULE_NAME),$<,$@)

$(OUTPUT_OBJ)$(X)/%.o : %.cpp
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(call cmd_cxx,$(MODULE_NAME),$<,$@)

$(OUTPUT_OBJ)$(X)/%.o.d: %.c
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(call cmd_cdep,$(MODULE_NAME),$<,$@,$*)

$(OUTPUT_OBJ)$(X)/%.o.d: %.cpp
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(call cmd_cxxdep,$(MODULE_NAME),$<,$@,$*)

$(TARGET_HEADER_FILES) : $(OUTPUT_INC)/% : $(EXPORT_HEADER_DIRS)/%
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(call cmd_cp,$(MODULE_NAME),$<,$@)

$(TARGET_CONFIG_FILES) : $(OUTPUT_ETC)/% : %
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(call cmd_cp,$(MODULE_NAME),$<,$@)

$(TARGET_FILE_FILES) : $(OUTPUT_BIN)/% : %
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(call cmd_cp,$(MODULE_NAME),$<,$@)

ifeq ($(MAKECMDGOALS),clean)
else ifeq ($(MAKECMDGOALS),show)
else ifeq ($(MAKECMDGOALS),help)
else ifeq ($(MAKECMDGOALS),install)
else ifeq ($(MAKECMDGOALS),distclean)
else
sinclude $(DEPEND_FILES)
endif

.PHONY: install
install:


.PHONY: uninstall
uninstall:

.PHONY: show help
show: show-common
	@echo "MODE                = " $(MODE)
	@echo "MODULE_ROOT         = " $(MODULE_ROOT)
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
	@echo "EXPORT_FILE_FILES   = " $(EXPORT_FILE_FILES)
	@echo "TAREGE_HEADER_FILES = " $(TARGET_HEADER_FILES)
	@echo "TARGET_CONFIG_FILES = " $(TARGET_CONFIG_FILES)
	@echo "TARGET_FILE_FILES   = " $(TARGET_FILE_FILES)
	@echo ""

help: help-common
	@echo "bin.mk : Build executable"
	@echo ""
	@echo "    MODULE_ROOT         the root directory of this module"
	@echo "    MODULE_NAME         the name of this mudule"
	@echo "    SOURCE_ROOT         source root directory (default MODULE_ROOT)"
	@echo "    SOURCE_DIRS         source directories (default src)"
	@echo "    SOURCE_OMIT         ignored files"
	@echo "    INCLUDES            include directories (default include)"
	@echo "    DEFINES             definitions"
	@echo "    EXPORT_HEADER_DIRS  directory (default include) copy to OUTPUT_INC"
	@echo "    EXPORT_CONFIG_FILES files copy to OUTPUT_ETC"
	@echo "    EXPORT_FILE_FILES   files copy to OUTPUT_BIN"
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

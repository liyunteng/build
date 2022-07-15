include $(PROJECT_ROOT)/scripts/def.mk
include $(PROJECT_ROOT)/scripts/cmd.mk

MODE := multibin
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

# Source FileList
SOURCE_ROOT  ?= $(MODULE_ROOT)
SOURCE_DIRS  ?= .
SOURCE_OMIT  ?=


SOURCE_C_FILES     ?= $(shell find $(SOURCE_DIRS) -name "*.c")
SOURCE_CXX_FILES   ?= $(shell find $(SOURCE_DIRS) -name "*.cpp")
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
CPPFLAGS += $(foreach x,$(INCLUDES), -I$(x))
CPPFLAGS += $(foreach x,$(DEFINES), -D$(x))
CFLAGS += -fPIC
CXXFLAGS += -fPIC

# export header
EXPORT_HEADER_DIR   ?= include
EXPORT_HEADER_FILES ?= $(wildcard $(EXPORT_HEADER_DIR)/*)
EXPORT_HEADER_FILES := $(EXPORT_HEADER_FILES:$(EXPORT_HEADER_DIR)/%=%)
TARGET_HEADER_FILES := $(addprefix $(OUTPUT_INC)/, $(EXPORT_HEADER_FILES))

# export configs
EXPORT_CONFIG_DIR   ?= test
EXPORT_CONFIG_FILES ?=
EXPORT_CONFIG_FILES := $(EXPORT_CONFIG_FILES:$(EXPORT_CONFIG_DIR)/%=%)
TARGET_CONFIG_FILES := $(addprefix $(OUTPUT_ETC)/, $(EXPORT_CONFIG_FILES))

# export files
EXPORT_FILES_DIR ?= test
EXPORT_FILES ?=
EXPORT_FILES := $(EXPORT_FILES:$(EXPORT_FILES_DIR)/%=%)
TARGET_FILES := $(addprefix $(OUTPUT_BIN)/, $(EXPORT_FILES))

# BINS
BINS := $(addprefix $(OUTPUT_BIN)/, $(basename $(SOURCE_FILES:$(SOURCE_ROOT)/%=%)))

######################################################################
all: build

.PHONY: build before after success bins
build: before bins after success

before: $(TARGET_HEADER_FILES)

after: $(TARGET_CONFIG_FILES) $(TARGET_FILES)

success:

bins: $(BINS)

$(BINS): $(OUTPUT_BIN)/% : $(OBJECT_FILES)
ifneq ($(strip $(OBJECT_FILES)),)
	$(call cmd_mkdir,$(MODULE_NAME),$@)
ifneq ($(strip $(SOURCE_CXX_FILES)),)
	$(call cmd_cxxbins,$(MODULE_NAME),$<,$@)
else
	$(call cmd_bins,$(MODULE_NAME),$<,$@)
endif
	$(call cmd_debuginfo,$(MODULE_NAME),$<,$@)
	$(call cmd_strip,$(MODULE_NAME),$<,$@)
endif

$(OUTPUT_OBJ)/%.o : %.c
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(call cmd_c,$(MODULE_NAME),$<,$@)

$(OUTPUT_OBJ)/%.o : %.cpp
	$(call cmd_mkdir,$(MODULE_NAME),$@)
	$(call cmd_cxx,$(MODULE_NAME),$<,$@)

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

.PHONY: show showall
showall: show
show: show-common
	@echo "MODE                = " $(MODE)
	@echo "MODULE_ROOT         = " $(MODULE_ROOT)
	@echo "MODULE_NAME         = " $(MODULE_NAME)
	@echo "BINS                = " $(BINS)
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
	@echo "multibin.mk : Build executable for every file"
	@echo ""
	@echo "    MODULE_ROOT         the root directory of this module"
	@echo "    SOURCE_ROOT         source root directory (default MODULE_ROOT)"
	@echo "    SOURCE_DIRS         source directories (default src)"
	@echo "    SOURCE_OMIT         ignored files"
	@echo "    SOURCE_C_FILES      binary c source files"
	@echo "    SOURCE_CXX_FILES    binary cpp source files"
	@echo "    SOURCE_FILES        source files"
	@echo "    INCLUDES            include directories (default include)"
	@echo "    DEFINES             definitions"
	@echo "    EXPORT_HEADER_FILES files copy to OUTPUT_INC"
	@echo "    EXPORT_CONFIG_FILES files copy to OUTPUT_ETC"
	@echo "    EXPORT_FILES        files copy to OUTPUT_BIN"
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

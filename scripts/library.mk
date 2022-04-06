include $(PROJECT_ROOT)/scripts/def.mk
include $(PROJECT_ROOT)/scripts/cmd.mk

MODE := library
MODULE_ROOT ?= $(shell pwd)

ifneq ($(BUILD_PWD),$(MODULE_ROOT))
X := $(MODULE_ROOT:$(BUILD_PWD)/%=%)
MODULE_NAME ?=  $(X)
else
X :=
MODULE_NAME ?= $(shell basename $(MODULE_ROOT))
endif

ifneq ($(strip $(X)),)
OUTPUT_OBJ := $(OUTPUT_OBJ)/$(X)
endif

# static/dynamic/all
LIB_NAME    ?= $(notdir $(MODULE_NAME))
LIB_TYPE    ?= all

# Source FileList
SOURCE_ROOT  ?= $(MODULE_ROOT)
SOURCE_DIRS  ?= src
SOURCE_OMIT  ?=

SOURCE_C_FILES   = $(foreach dir, $(SOURCE_DIRS), $(wildcard $(dir)/*.c))
SOURCE_CXX_FILES = $(foreach dir, $(SOURCE_DIRS), $(wildcard $(dir)/*.cpp))
SOURCE_FILES  += $(SOURCE_C_FILES) $(SOURCE_CXX_FILES)
SOURCE_FILES  := $(SOURCE_FILES:./%=%)
ifneq ($(strip $(SOURCE_OMIT)),)
SOURCE_FILES := $(filter-out $(foreach x,$(SOURCE_OMIT),$(x)), $(SOURCE_FILES))
endif

TEST_DIRS  ?= test
TEST_C_FILES   += $(foreach dir,$(TEST_DIRS),$(wildcard $(dir)/*.c))
TEST_CXX_FILES += $(foreach dir,$(TEST_DIRS),$(wildcard $(dir)/*.cpp))
TEST_FILES ?= $(TEST_C_FILES) $(TEST_CXX_FILES)
TEST_FILES := $(TEST_FILES:./%=%)


# object/dep files
OBJECT_FILES := $(patsubst %.c,%.o,$(patsubst %.cpp,%.o,$(SOURCE_FILES)))
OBJECT_FILES := $(addprefix $(OUTPUT_OBJ)/, $(OBJECT_FILES))
DEPEND_FILES := $(OBJECT_FILES:%.o=%.o.d)
SOURCE_FILES := $(addprefix $(SOURCE_ROOT)/, $(SOURCE_FILES))

TEST_OBJECT_FILES := $(patsubst %.c,%.o,$(patsubst %.cpp,%.o, $(TEST_FILES)))
TEST_OBJECT_FILES := $(addprefix $(OUTPUT_OBJ)/, $(TEST_OBJECT_FILES))
DEPEND_FILES += $(TEST_OBJECT_FILES:%.o=%.o.d)
TEST_FILES := $(addprefix $(SOURCE_ROOT)/, $(TEST_FILES))

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

# Lib Name
STATIC_LIBS  ?= lib$(LIB_NAME).a
DYNAMIC_LIBS ?= lib$(LIB_NAME).so

STATIC_LIBS := $(addprefix $(OUTPUT_LIB)/, $(STATIC_LIBS))
DYNAMIC_LIBS := $(addprefix $(OUTPUT_LIB)/, $(DYNAMIC_LIBS))

ifeq ($(strip $(LIB_TYPE)),dynamic)
LIBS ?= $(DYNAMIC_LIBS)
else ifeq ($(strip $(LIB_TYPE)),static)
LIBS ?= $(STATIC_LIBS)
else
LIBS ?= $(STATIC_LIBS) $(DYNAMIC_LIBS)
endif

TESTS ?= $(notdir $(MODULE_NAME))-test
ifeq ($(strip $(TEST_FILES)),)
TESTS =
endif
TESTS := $(addprefix $(OUTPUT_BIN)/, $(TESTS))


######################################################################
all: build

.PHONY: build before header after success libs test
build: before header libs test after success

before:

header: $(TARGET_HEADER_FILES)

after: $(TARGET_CONFIG_FILES) $(TARGET_FILES)

success:

libs: $(STATIC_LIBS) $(DYNAMIC_LIBS)

test: libs $(TESTS)

$(STATIC_LIBS): $(OBJECT_FILES)
ifneq ($(strip $(OBJECT_FILES)),)
	$(call cmd_mkdir,$(MODULE_NAME),$@)
ifneq ($(strip $(SOURCE_CXX_FILES)),)
	$(call cmd_cxxlib,$(MODULE_NAME),$^,$@)
else
	$(call cmd_lib,$(MODULE_NAME),$^,$@)
endif
	$(call cmd_strip_static,$(MODULE_NAME),$^,$@)
endif

$(DYNAMIC_LIBS): $(OBJECT_FILES)
ifneq ($(strip $(OBJECT_FILES)),)
	$(call cmd_mkdir,$(MODULE_NAME),$@)
ifneq ($(strip $(SOURCE_CXX_FILES)),)
	$(call cmd_cxxsolib,$(MODULE_NAME),$^,$@)
else
	$(call cmd_solib,$(MODULE_NAME),$^,$@)
endif
	$(call cmd_debuginfo,$(MODULE_NAME),$^,$@)
	$(call cmd_strip,$(MODULE_NAME),$^,$@)
endif

$(TESTS): LDFLAGS += -l$(LIB_NAME)
ifeq ($(words $(TESTS)),1)
$(TESTS): $(OUTPUT_BIN)/%: $(TEST_OBJECT_FILES)
ifneq ($(strip $(TEST_OBJECT_FILES)),)
	$(call cmd_mkdir,$(MODULE_NAME),$@)
ifneq ($(strip $(TEST_CXX_FILES)),)
	$(call cmd_cxxbin,$(MODULE_NAME),$^,$@)
else
	$(call cmd_bin,$(MODULE_NAME),$^,$@)
endif
	$(call cmd_debuginfo,$(MODULE_NAME),$^,$@)
	$(call cmd_strip,$(MODULE_NAME),$^,$@)
endif
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
	@echo "LIB_TYPE            = " $(LIB_TYPE)
	@echo "LIB_NAME            = " $(LIB_NAME)
	@echo "LIBS                = " $(LIBS)
	@echo "TESTS               = " $(TESTS)
	@echo "SOURCE_ROOT         = " $(SOURCE_ROOT)
	@echo "SOURCE_DIRS         = " $(SOURCE_DIRS)
	@echo "SOURCE_OMIT         = " $(SOURCE_OMIT)
	@echo "SOURCE_FILES        = " $(SOURCE_FILES)
	@echo "OBJECT_FILES        = " $(OBJECT_FILES)
	@echo "TEST_DIRS           = " $(TEST_DIRS)
	@echo "TEST_FILES          = " $(TEST_FILES)
	@echo "TEST_OBJECT_FILES   = " $(TEST_OBJECT_FILES)
	@echo "DPEND_FILES         = " $(DEPEND_FILES)
	@echo "INCLUDES            = " $(INCLUDES)
	@echo "DEFINES             = " $(DEFINES)
	@echo "EXPORT_HEADER_FILES = " $(EXPORT_HEADER_FILES)
	@echo "EXPORT_CONFIG_FILES = " $(EXPORT_CONFIG_FILES)
	@echo "EXPORT_FILES        = " $(EXPORT_FILES)
	@echo "TARGET_HEADER_FILES = " $(TARGET_HEADER_FILES)
	@echo "TARGET_CONFIG_FILES = " $(TARGET_CONFIG_FILES)
	@echo "TARGET_FILES        = " $(TARGET_FILES)
	@echo ""


.PHONY: help helpall
helpall: help
help: help-common
	@echo "library.mk : Build Library"
	@echo ""
	@echo "    MODULE_ROOT         the root directory of this module"
	@echo "    MODULE_NAME         the name of this mudule"
	@echo "    LIB_TYPE            library type [static/dynamic/all]"
	@echo "    LIB_NAME            library name"
	@echo "    SOURCE_ROOT         source Root Directory (default MODULE_ROOT)"
	@echo "    SOURCE_DIRS         source directories (default src)"
	@echo "    SOURCE_OMIT         ignored files"
	@echo "    INCLUDES            include directories (default include)"
	@echo "    DEFINES             definitions"
	@echo "    EXPORT_HEADER_FILES files copy to OUTPUT_INC"
	@echo "    EXPORT_CONFIG_FIlES files copy to OUTPUT_ETC"
	@echo "    EXPORT_FILES        files copy to OUTPUT_BIN "
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
	$(call cmd_rm,$(MODULE_NAME),$(OUTPUT_ROOT))

.PHONY: distclean
distclean: clean

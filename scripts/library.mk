MODE := library
MODULE_ROOT ?= $(shell pwd)
MODULE_NAME ?= $(shell basename $(MODULE_ROOT))

# static/dynamic/all
LIB_TYPE    ?= all

# Source FileList
SOURCE_ROOT  ?= $(MODULE_ROOT)
SOURCE_DIRS  ?= src
SOURCE_OMIT  ?=

SOURCE_C_FILES   = $(foreach dir, $(SOURCE_DIRS), $(wildcard $(dir)/*.c))
SOURCE_CXX_FILES = $(foreach dir, $(SOURCE_DIRS), $(wildcard $(dir)/*.cpp))
SOURCE_FILES  ?= $(SOURCE_C_FILES) $(SOURCE_CXX_FILES)
SOURCE_FILES  := $(SOURCE_FILES:./%=%)
ifneq ($(strip $(SOURCE_OMIT)),)
SOURCE_FILES := $(filter-out $(foreach x,$(SOURCE_OMIT),$(x)), $(SOURCE_FILES))
endif

TEST_DIRS  ?= test
TEST_C_FILES   += $(foreach dir,$(TEST_DIRS),$(wildcard $(dir)/*.c))
TEST_CXX_FILES += $(foreach dir,$(TEST_DIRS),$(wildcard $(dir)/*.cpp))
TEST_FILES ?= $(TEST_C_FILES) $(TEST_CXX_FILES)
TEST_FILES := $(TEST_FILES:./%=%)

include $(PROJECT_ROOT)/scripts/def.mk
include $(PROJECT_ROOT)/scripts/cmd.mk

# object/dep files
X := $(MODULE_ROOT:$(BUILD_PWD)%=%)
OBJECT_FILES := $(patsubst %.c,%.o,$(patsubst %.cpp,%.o,$(SOURCE_FILES)))
OBJECT_FILES := $(addprefix $(OUTPUT_OBJ)$(X)/, $(OBJECT_FILES))
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

# Lib Name
STATIC_LIBS  ?= lib$(MODULE_NAME).a
DYNAMIC_LIBS ?= lib$(MODULE_NAME).so

STATIC_LIBS := $(addprefix $(OUTPUT_LIB)/, $(STATIC_LIBS))
DYNAMIC_LIBS := $(addprefix $(OUTPUT_LIB)/, $(DYNAMIC_LIBS))

ifeq ($(LIB_TYPE),dynamic)
LIBS ?= $(DYNAMIC_LIBS)
else ifeq ($(LIB_TYPE),static)
LIBS ?= $(STATIC_LIBS)
else
LIBS ?= $(STATIC_LIBS) $(DYNAMIC_LIBS)
endif

TESTS ?= $(MODULE_NAME)-test
ifeq ($(TEST_FILES),)
TESTS =
endif
TESTS := $(addprefix $(OUTPUT_BIN)/, $(TESTS))

######################################################################
all: build

.PHONY: build before header after success libs test
build: before header libs test after success

before:

header: $(TARGET_HEADER_FILES)

after: $(TARGET_CONFIG_FILES) $(TARGET_FILE_FILES)

success:

libs: $(STATIC_LIBS) $(DYNAMIC_LIBS)

test: libs $(TESTS)

$(STATIC_LIBS): $(OBJECT_FILES)
ifneq ($(OBJECT_FILES),)
	$(call cmd_mkdir,$(MODULE_NAME),$@)
ifneq ($(SOURCE_CXX_FILES),)
	$(call cmd_cxxlib,$(MODULE_NAME),$^,$@)
else
	$(call cmd_clib,$(MODULE_NAME),$^,$@)
endif
	$(call cmd_strip_static,$(MODULE_NAME),$^,$@)
endif

$(DYNAMIC_LIBS): $(OBJECT_FILES)
ifneq ($(OBJECT_FILES),)
	$(call cmd_mkdir,$(MODULE_NAME),$@)
ifneq ($(SOURCE_CXX_FILES),)
	$(call cmd_cxxsolib,$(MODULE_NAME),$^,$@)
else
	$(call cmd_csolib,$(MODULE_NAME),$^,$@)
endif
	$(call cmd_debuginfo,$(MODULE_NAME),$^,$@)
	$(call cmd_strip,$(MODULE_NAME),$^,$@)
endif

$(OUTPUT_BIN)$(X)/%: $(TEST_OBJECT_FILES)
ifneq ($(TEST_OBJECT_FILES),)
	$(call cmd_mkdir,$(MODULE_NAME),$@)
ifneq ($(TEST_CXX_FILES),)
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

.PHONY: show
show: show-common
	@echo "MODE                = " $(MODE)
	@echo "MODULE_ROOT         = " $(MODULE_ROOT)
	@echo "MODULE_NAME         = " $(MODULE_NAME)
	@echo "LIB_TYPE            = " $(LIB_TYPE)
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
	@echo "EXPORT_FILE_FILES   = " $(EXPORT_FILE_FILES)
	@echo "TARGET_HEADER_FILES = " $(TARGET_HEADER_FILES)
	@echo "TARGET_CONFIG_FILES = " $(TARGET_CONFIG_FILES)
	@echo "TARGET_FILE_FILES   = " $(TARGET_FILE_FILES)
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
	@echo "    INCLUDES            include directories (default include)"
	@echo "    DEFINES             definitions"
	@echo "    EXPORT_HEADER_DIRS  directory (default include) copy to OUTPUT_INC"
	@echo "    EXPORT_CONFIG_FIlES files copy to OUTPUT_ETC"
	@echo "    EXPORT_FILE_FILES   files copy to OUTPUT_BIN "
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

# MODULE_ROOT:     The root directory of this module
# MODULE_NAME:     The name of this mudule
# SOURCE_ROOT:     Source Root Directory (default MODULE_ROOT)
# SOURCE_DIR:      Source directory (default src)
# SOURCE_OMIT:     Ignored files
# INCLUDE_DIR:     Include directory (default include)
# CFLAGS:          gcc -c Flags (Added -fPIC)
# CPPFLAGS:        cpp Flags
# CXXFLAGS:        g++ -c Flags
# ARFLAGS:         ar Flags (Default rcs)
# LDFLAGS:         ld Flags (Added -shared -fPIC for shared)
# BUILD_VERBOSE:   Verbose output (MUST Before def.mk)
# BUILD_OUTPUT:    Output dir (MUST Before def.mk)

MODE=bin
MODULE_ROOT ?= $(shell pwd)
MODULE_NAME ?= $(shell basename $(MODULE_ROOT))

# Source FileList
SOURCE_ROOT ?= $(MODULE_ROOT)
SOURCE_DIR  ?= src
SOURCE_OMIT ?=

SOURCE_C   := $(foreach dir, $(SOURCE_DIR), $(shell find $(SOURCE_ROOT)/$(dir) -name "*.c"))
SOURCE_CXX := $(foreach dir, $(SOURCE_DIR), $(shell find $(SOURCE_ROOT)/$(dir) -name "*.cpp"))
ifneq ($(strip $(SOURCE_OMIT)),)
SOURCE_C   := $(filter-out $(SOURCE_OMIT), $(SOURCE_C))
SOURCE_CXX := $(filter-out $(SOURCE_OMIT), $(SOURCE_CXX))
endif
# Object FileList
OBJECT_C   := $(SOURCE_C:$(SOURCE_ROOT)%.c=$(OUT_OBJECT)%.o)
OBJECT_CXX := $(SOURCE_CXX:$(SOURCE_ROOT)%.cpp=$(OUT_OBJECT)%.o)
DEPEND_C   := $(OBJECT_C:%.o=%.d)
DEPEND_CXX := $(OBJECT_CXX:%.o=%.d)

# Include Configure
INCLUDE_DIR ?= $(SOURCE_ROOT)/include
INCLUDE_PATH += $(foreach dir, $(INCLUDE_DIR), -I$(dir))
CPPFLAGS += $(INCLUDE_PATH)

# Lib Name
BIN   := $(OUT_BIN)/$(MODULE_NAME)

# CreateDirectory
OUT_OBJECT_DIR := $(sort $(dir $(OBJECT_C)))
OUT_OBJECT_DIR += $(sort $(dir $(OBJECT_CXX)))
CreateResult :=
dummy := $(call CreateDirectory, $(OUT_ROOT))
dummy += $(call CreateDirectory, $(OUT_OBJECT))
dummy += $(call CreateDirectory, $(OUT_BIN))
dummy += $(foreach dir, $(OUT_OBJECT_DIR), CreateResult += $(call CreateDirectory, $(dir)))
ifneq ($(strip $(CreateResult)),)
	err = $(error create directory failed: $(CreateResult))
endif

# Compiler
.PHONY: all prepare success
default: all
all: before $(DEPEND_C) $(OBJECT_C) $(DEPEND_CXX) $(OBJECT_CXX) $(BIN) after success

before:

after:

success:

$(DEPEND_C): $(OUT_DEPEND)/%.d : $(SOURCE_ROOT)/%.c
	@set -e;$(CC) -MM $< $(CPPFLAGS) $(CFLAGS) > $@.$$$$; \
	sed 's,.*\.o[ :]*,$(@:%.d=%.o) $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

ifeq ($(MAKECMDGOALS),all)
sinclude $(DEPEND_C)
endif

$(OBJECT_C):  $(OUT_OBJECT)/%.o : $(SOURCE_ROOT)/%.c
	@echo -e "[CC]      $@"
	$(Q) $(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

$(DEPEND_CXX) : $(OUT_DEPEND)/%.d : $(SOURCE_ROOT)/%.cpp
	@set -e;$(CC) -MM $< $(CPPFLAGS) $(CXXFLAGS) > $@.$$$$; \
	sed 's,.*\.o[ :]*,$(@:%.d=%.o) $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$
ifeq ($(MAKECMDGOALS),all)
sinclude $(DEPEND_CXX)
endif

$(OBJECT_CXX):  $(OUT_OBJECT)/%.o : $(SOURCE_ROOT)/%.cpp
	@echo "[CXX]     $@"
	$(Q) $(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

$(BIN): $(DEPEND_C) $(OBJECT_C) $(DEPEND_CXX) $(OBJECT_CXX)
	@echo "[LINK]    $@"
	$(Q)$(CC) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) $(OBJECT_C) $(OBJECT_CXX) -o $@
ifeq ($(BUILD_ENV),release)
	@echo "[STRIP]   $@"
	$(Q)$(STRIP) $@
endif

.PHONY: help
help:
	@echo "library: Build Library"
	@echo ""
	@echo "    MODULE_ROOT:     The root directory of this module"
	@echo "    MODULE_NAME:     The name of this mudule"
	@echo "    SOURCE_ROOT:     Source Root Directory (default MODULE_ROOT)"
	@echo "    SOURCE_DIR:      Source directory (default src)"
	@echo "    SOURCE_OMIT:     Ignored files"
	@echo "    INCLUDE_DIR:     Include directory (default include)"
	@echo ""
	@echo "    BUILD_VERBOSE:   Verbose output (MUST Before def.mk)"
	@echo "    BUILD_OUTPUT:    Output dir (MUST Before def.mk)"
	@echo ""
	@echo "    CFLAGS:          gcc -c Flags (Added -fPIC)"
	@echo "    CPPFLAGS:        cpp Flags"
	@echo "    CXXFLAGS:        g++ -c Flags"
	@echo "    ARFLAGS:         ar Flags (Default rcs)"
	@echo "    LDFLAGS:         ld Flags (Added -shared -fPIC for shared)"
	@echo ""

.PHONY: clean
clean:
# $(Q)$(RM) -rf $(OBJECT_C) $(OBJECT_CXX)
# $(Q)$(RM) -rf $(BIN)
# $(Q)$(RM) -rf $(DEPEND_C) $(DEPEND_CXX)
# $(Q)[ -n $(OUT_OBJECT) ] && rm -rf $(OUT_OBJECT)
# $(Q)[ -n $(OUT_BIN) ] && rm -rf $(OUT_BIN)
# $(Q)[ -n $(OUT_DEPEND) ] && rm -rf $(OUT_DEPEND)
	$(Q)[ -n $(OUT_ROOT) ] && rm -rf $(OUT_ROOT)

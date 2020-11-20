# TARGET:          Build library name
# CFLAGS:          gcc -c Flags (Added -fPIC)
# CPPFLAGS:        cpp Flags
# CXXFLAGS:        g++ -c Flags
# ARFLAGS:         ar Flags (Default rcs)
# LDFLAGS:         ld Flags (Added -shared for shared)
# BUILD_SHARED:    build shared library (Default true)
# BUILD_STATIC:    build static library (Default true)
# BUILD_VERBOSE:   Verbose output (MUST Before def.mk)
# BUILD_OUTPUT:    Output dir (MUST Before def.mk)

all: library

SOURCE_C   := $(wildcard src/*.c)
OBJECT_C   := $(SOURCE_C:%.c=%.o)
SOURCE_CXX := $(wildcard src/*.cpp)
OBJECT_CXX := $(SOURCE_CXX:%.cpp=%.o)

BUILD_SHARED ?= 1
BUILD_STATIC ?= 1
VPATH += $(realpath $(shell pwd)/include)
CPPFLAGS += $(patsubst %,-I%,$(subst :, ,$(VPATH)))
CFLAGS += -fPIC

ifeq ($(BUILD_STATIC),1)
LIBRARY_STATIC=lib$(TARGET).a
library : build_static
endif

ifeq ($(BUILD_SHARED),1)
LIBRARY_SHARED=lib$(TARGET).so
library : build_shared
endif

build_static: $(LIBRARY_STATIC)
build_shared: $(LIBRARY_SHARED)

$(LIBRARY_STATIC): $(OBJECT_C) $(OBJECT_CXX)
	@echo "[AR]    $@"
	$(Q)$(AR) $(ARFLAGS) $(BUILD_OUTPUT)/$@ $(addprefix $(BUILD_OUTPUT)/,$(notdir $^))

$(LIBRARY_SHARED): $(OBJECT_C) $(OBJECT_CXX)
	@echo "[SHARE] $@"
	$(Q)$(CC) -shared $(LDFLAGS) $(addprefix $(BUILD_OUTPUT)/,$(notdir $^)) -o $(BUILD_OUTPUT)/$@

.PHONY: debug
debug:
	@$(MAKE) BUILD_ENV=debug all MAKEFLAGS=

.PHONY: help
help:
	@echo "static_lib: Build Library"
	@echo ""
	@echo "    TARGET:          Build library name"
	@echo "    CFLAGS:          gcc -c Flags"
	@echo "    CPPFLAGS:        cpp Flags"
	@echo "    CXXFLAGS:        g++ -c Flags"
	@echo "    ARFLAGS:         ar Flags (Default rcs)"
	@echo "    BUILD_SHARED:    Build shared library (Default true)"
	@echo "    BUILD_STATIC:    Build static library (Default true)"
	@echo "    BUILD_VERBOSE:   Verbose output (MUST Before def.mk)"
	@echo "    BUILD_OUTPUT:    Output dir (MUST Before def.mk)"
	@echo ""

.PHONY: clean
clean1:
	$(Q)$(RM) -rf $(addprefix $(BUILD_OUTPUT)/, $(notdir $(OBJECT_C)))
	$(Q)$(RM) -rf $(addprefix $(BUILD_OUTPUT)/, $(notdir $(OBJECT_CXX)))

clean: clean1
	$(Q)$(RM) -rf $(addprefix $(BUILD_OUTPUT)/,$(LIBRARY_SHARED))
	$(Q)$(RM) -rf $(addprefix $(BUILD_OUTPUT)/,$(LIBRARY_STATIC))
	$(Q)[[ $(BUILD_OUTPUT) == $(BUILD_PWD) ]] || rm -rf $(BUILD_OUTPUT)

%.o : %.c
	@echo "[CC]    $@"
	$(Q)$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $(BUILD_OUTPUT)/$(notdir $@)

%.o : %.cpp
	@echo "[CXX]   $@"
	$(Q)$(CC) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $(BUILD_OUTPUT)/$(notdir $@)

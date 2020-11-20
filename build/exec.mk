# TARGET:          Build target name
# LIBS:            Library
# CFLAGS:          gcc -c Flags
# CPPFLAGS:        cpp Flags
# CXXFLAGS:        g++ -c Flags
# LDFLAGS:         ld Flags
# LOADLIBES:       ld Library
# LDLIBS:          ld Library
# BUILD_VERBOSE:   Verbose output (MUST Before def.mk)
# BUILD_OUTPUT:    Output dir (MUST Before def.mk)

all: app

SOURCE_C   := $(wildcard src/*.c)
OBJECT_C   := $(SOURCE_C:%.c=%.o)
SOURCE_CXX := $(wildcard src/*.cpp)
OBJECT_CXX := $(SOURCE_CXX:%.cpp=%.o)

VPATH += $(foreach s, $(LIBS), $(s))
CPPFLAGS += $(patsubst %, -I%/include, $(VPATH))
LOADLIBES += $(patsubst %, -L%, $(VPATH))
LDLIBS += $(patsubst %, -l%, $(notdir $(LIBS)))

.PHONY: app
app: $(TARGET)

$(TARGET): $(OBJECT_C) $(OBJECT_CXX)
	@echo "[LINK]  $@"
	$(Q)$(CC) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) $(addprefix $(BUILD_OUTPUT)/,$(notdir $^)) -o $(BUILD_OUTPUT)/$(notdir $@)


.PHONY: debug
debug:
	@$(MAKE) BUILD_ENV=debug all  MAKEFLAGS=

.PHONY: help
help:
	@echo "exec: Build Executable Binary"
	@echo ""
	@echo "    TARGET:          Build target name"
	@echo "    CFLAGS:          gcc -c Flags"
	@echo "    CPPFLAGS:        cpp Flags"
	@echo "    CXXFLAGS:        g++ -c Flags"
	@echo "    LDFLAGS:         ld Flags"
	@echo "    LOADLIBES:       ld Library"
	@echo "    LDLIBS:          ld Library"
	@echo "    BUILD_VERBOSE:   Verbose output (MUST Before def.mk)"
	@echo "    BUILD_OUTPUT:    Output dir (MUST Before def.mk)"
	@echo ""

.PHONY: clean
clean:
	$(Q)$(RM) -rf $(addprefix $(BUILD_OUTPUT)/, $(notdir $(TARGET)))
	$(Q)$(RM) -rf $(addprefix $(BUILD_OUTPUT)/, $(notdir $(OBJECT_C)))
	$(Q)$(RM) -rf $(addprefix $(BUILD_OUTPUT)/,$(notdir $(OBJECT_CXX)))
	$(Q)[[ $(BUILD_OUTPUT) == $(BUILD_PWD) ]] || rm -rf $(BUILD_OUTPUT)

%.o : %.c
	@echo "[CC]    $@"
	$(Q)$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $(BUILD_OUTPUT)/$(notdir $@)

%.o : %.cpp
	@echo "[CXX]   $@"
	$(Q)$(CC) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $(BUILD_OUTPUT)/$(notdir $@)

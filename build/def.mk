MAJOR_VERSION := 0
MINOR_VERSION := 0
PATCH_VERSION := 1

CC				  := $(CROSS_COMPILE)gcc
CXX               := $(CROSS_COMPILE)g++
CPP				  := $(CC) -E
AS				  := $(CROSS_COMPILE)as
LD				  := $(CROSS_COMPILE)ld
AR				  := $(CROSS_COMPILE)ar
NM				  := $(CROSS_COMPILE)nm
STRIP			  := $(CROSS_COMPILE)strip
OBJCOPY			  := $(CROSS_COMPILE)objcopy
OBJDUMP			  := $(CROSS_COMPILE)objdump
OBJSIZE			  := $(CROSS_COMPILE)size

CPPFLAGS    :=
CFLAGS      := -Wall -Wmissing-prototypes -Wstrict-prototypes
CXXFLAGS    := $(BUILD_CFLAGS)
ASFLAGS     := -D__ASSEMBLY__ -fno-PIE
LDFLAGS     :=
LOADLIBES   :=
LDLIBS      :=
ARFLAGS     := rcs

BUILD_ENV := release
ifeq ($(BUILD_ENV), release)
	CFLAGS += -O2 -DNDEBUG
	CXXFLAGS += -O2 -DNDEBUG
else
	CFLAGS += -g -ggdb
	CXXFLAGS += -g -ggdb
endif

BUILD_VERBOSE := 0
ifeq ("$(origin V)", "command line")
	BUILD_VERBOSE = $(V)
endif
ifeq ($(BUILD_VERBOSE),1)
	Q =
else
	Q = @
endif

BUILD_PWD    := $(realpath $(CURDIR))
BUILD_OUTPUT := $(realpath $(CURDIR))
ifeq ("$(origin O)", "command line")
BUILD_OUTPUT = $(O)
endif

ifneq ($(BUILD_OUTPUT),$(BUILD_PWD))
abs_objtree := $(shell mkdir -p $(BUILD_OUTPUT) && cd $(BUILD_OUTPUT) && pwd)
$(if $(abs_objtree),, \
	$(error failed to create output directory "$(BUILD_OUTPUT)"))
BUILD_OUTPUT = $(realpath $(abs_objtree))
endif
$(info BUILD_OUTPUT is $(BUILD_OUTPUT))

ifeq ($(BUILD_OUTPUT),$(BUILD_PWD))
	MAKEFLAGS += --no-print-directory
endif

# ifneq ($(words $(subst :, ,$(BUILD_PWD))),1)
# $(error source directory cannot contain spaces or colons)
# endif
ifneq ($(BUILD_OUTPUT),$(BUILD_PWD))
	MAKEFLAGS += --include-dir=$(BUILD_PWD)
	need-sub-make := 1
endif
export

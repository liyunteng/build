MAJOR_VERSION := 0
MINOR_VERSION := 0
PATCH_VERSION := 1
BUILD_ENV := release

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

BUILD_AFLAGS      := -D__ASSEMBLY__ -fno-PIE
BUILD_CPPFLAGS    :=
BUILD_CFLAGS      := -Wall -Wmissing-prototypes -Wstrict-prototypes
BUILD_CXXFLAGS    := $(BUILD_CFLAGS)
BUILD_LDFLAGS     :=

ifeq ($(BUILD_ENV), release)
	BUILD_CFLAGS += -O2 -DNDEBUG
	BUILD_CXXFLAGS += -O2 -DNDEBUG
else
	BUILD_CFLAGS += -g -ggdb
	BUILD_CXXFLAGS += -g -ggdb
endif

ifeq ("$(origin V)", "command line")
	BUILD_VERBOSE := $(V)
endif
ifndef BUILD_VERBOSE
	BUILD_VERBOSE := 0
endif

ifeq ($(BUILD_VERBOSE),1)
	Q =
else
	Q = @
endif

ifeq ("$(origin O)", "command line")
	OO := $(O)
endif
ifneq ($(OO),)
abs_objtree := $(shell mkdir -p $(OO) && cd $(OO) && pwd)
$(if $(abs_objtree),, \
	$(error failed to create output directory "$(OO)"))
abs_objtree := $(abs_objtree)
else
abs_objtree := $(CURDIR)
endif
BUILD_PWD    := $(realpath $(CURDIR))
BUILD_OUTPUT := $(realpath $(abs_objtree))

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

INCLUDEDIR :=
LIBDIR     :=
LIBS       :=

SOURCE_C   := $(wildcard *.c)
OBJECT_C   := $(patsubst %.c, $(BUILD_OUTPUT)/%.o, $(SOURCE_C))
DEPEND_C   := $(patsubst %.c, $(BUILD_OUTPUT)/%.d, $(SOURCE_C))

SOURCE_CXX := $(wildcard *.cpp)
OBJECT_CXX := $(patsubst %.cpp, $(BUILD_OUTPUT)/%.o, $(SOURCE_CXX))
DEPEND_CXX := $(patsubst %.cpp, $(BUILD_OUTPUT)/%.o, $(SOURCE_CXX))

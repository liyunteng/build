ifeq ($(MAKELEVEL),0)
BUILD_ROOT := $(abspath $(CURDIR))
endif

# Env
D ?= 0
BUILD_ENV ?= release
ifeq ("$(origin D)", "command line")
ifeq ($(D),0)
	BUILD_ENV := release
else ifeq ($(D), 1)
	BUILD_ENV := debug
else ifeq ($(D),2)
	BUILD_ENV := debuginfo
else ifeq ($(D),3)
	BUILD_ENV := map
else
$(error Invalid D=$(D) D=[0|1|2|3])
endif
endif

# Version
VERSION ?=
BUILD_VERSION ?= 0

# Verbose
V ?= 0
BUILD_VERBOSE ?= 0
ifeq ("$(origin V)", "command line")
	BUILD_VERBOSE = $(V)
endif
ifeq ($(BUILD_VERBOSE),0)
    Q1 := @
    Q2 := @
    Q3 := @
    MAKEFLAGS += --no-print-directory -s
else ifeq ($(BUILD_VERBOSE),1)
    Q1 :=
    Q2 := @
    Q3 := @
    MAKEFLAGS += --no-print-directory
else ifeq ($(BUILD_VERBOSE),2)
    Q1 :=
    Q2 :=
    Q3 := @
    MAKEFLAGS += --no-print-directory
else ifeq ($(BUILD_VERBOSE),3)
    Q1 :=
    Q2 :=
    Q3 :=
else
	Q1 :=
	Q2 :=
	Q3 :=
endif

# Output
BUILD_PWD    = $(abspath $(CURDIR))
BUILD_OUTPUT ?= $(abspath $(CURDIR))/out
ifeq ("$(origin O)", "command line")
    BUILD_OUTPUT = $(abspath $(O))
endif
ifneq ($(BUILD_OUTPUT),$(BUILD_PWD))
# MAKEFLAGS += --include-dir=$(BUILD_PWD)
endif

OUTPUT_ROOT	  ?= $(BUILD_OUTPUT)
OUTPUT_INC    ?= $(OUTPUT_ROOT)/include
OUTPUT_BIN    ?= $(OUTPUT_ROOT)/bin
OUTPUT_LIB    ?= $(OUTPUT_ROOT)/lib
OUTPUT_OBJ    ?= $(OUTPUT_ROOT)/obj
OUTPUT_ETC    ?= $(OUTPUT_ROOT)/etc

# Tools
SHELL       := /bin/sh
OS_TYPE     := $(shell uname)
CP          := cp -rf
RM          := rm -rf
MKDIR       := mkdir -p

# Compiler
# ******************************
ifeq ($(LLVM),1)
CC          = clang
CXX         = clang++
CPP         = $(CC) -E

# LD          = ld.lld
LD          = llvm-link
AR          = llvm-ar
NM          = llvm-nm
STRIP       = llvm-strip
OBJCOPY     = llvm-objcopy
OBJDUMP     = llvm-objdump
READELF     = llvm-readelf
OBJSIZE     = llvm-size
else
CC          = $(CROSS_COMPILE)gcc
CXX         = $(CROSS_COMPILE)g++
CPP         = $(CC) -E

LD          = $(CROSS_COMPILE)ld
AR          = $(CROSS_COMPILE)ar
NM          = $(CROSS_COMPILE)nm
STRIP       = $(CROSS_COMPILE)strip
OBJCOPY     = $(CROSS_COMPILE)objcopy
OBJDUMP     = $(CROSS_COMPILE)objdump
READELF     = $(CROSS_COMPILE)readelf
OBJSIZE     = $(CROSS_COMPILE)size
RANLIB      = $(CROSS_COMPILE)ranlib
endif
AS		    = $(CROSS_COMPILE)as

# Flags
CFLAGS      ?=
CXXFLAGS    ?=
# CFLAGS      ?= -Wall -fstack-protector -Wmissing-prototypes -Wstrict-prototypes
# CXXFLAGS    ?= -Wall -fstack-protector
CPPFLAGS    ?=
ASFLAGS     ?= -D__ASSEMBLY__ -fno-PIE
LDFLAGS     ?=
LOADLIBES   ?=
LDLIBS      ?=
ARFLAGS     := rcs

ifeq ($(LLVM),1)
ifneq ($(LLVM_TARGET),)
	CFLAGS += --target=$(LLVM_TARGET)
	CXXFLAGS += --target=$(LLVM_TARGET)
endif
endif

ifeq ($(BUILD_ENV), release)
	# CFLAGS += -O2 -DNDEBUG
	# CXXFLAGS += -O2 -DNDEBUG
else ifeq ($(BUILD_ENV), debug)
	CFLAGS += -g -ggdb
	CXXFLAGS += -g -ggdb
else ifeq ($(BUILD_ENV), debuginfo)
	CFLAGS += -g -ggdb -gdwarf
	CXXFLAGS += -g -ggdb
else ifeq ($(BUILD_ENV), map)
	CFLAGS += -g -ggdb
	CXXFLAGS += -g -ggdb
endif

# MacOS clang not support --build-id
ifneq ($(OS_TYPE), Darwin)
LDFLAGS += -Wl,--build-id
endif

CPPFLAGS += -I$(OUTPUT_INC)
LDFLAGS += -L$(OUTPUT_LIB) -Wl,-rpath,$(OUTPUT_LIB)

export

######################################################################

default: all
.PHONY: show-common help-common
show-common:
	@echo "=============== $(CURDIR) ==============="
	@echo "BUILD_ENV          = " $(BUILD_ENV)
	@echo "BUILD_VERBOSE      = " $(BUILD_VERBOSE)
	@echo "BUILD_ROOT         = " $(BUILD_ROOT)
	@echo "BUILD_PWD          = " $(BUILD_PWD)
	@echo "BUILD_OUTPUT       = " $(BUILD_OUTPUT)
	@echo "BUILD_VERSION      = " $(BUILD_VERSION)
	@echo "VERSION            = " $(VERSION)
	@echo "LLVM               = " $(LLVM)
	@echo "LLVM_TARGET        = " $(LLVM_TARGET)
	@echo "D                  = " $(D)
	@echo "O                  = " $(O)
	@echo "Q1                 = " $(Q1)
	@echo "Q2                 = " $(Q2)
	@echo "Q3                 = " $(Q3)
	@echo ""

	@echo "SHELL              = " $(SHELL)
	@echo "OS_TYPE            = " $(OS_TYPE)
	@echo "CP                 = " $(CP)
	@echo "RM                 = " $(RM)
	@echo "MKDIR              = " $(MKDIR)
	@echo ""

	@echo "CURDIR             = " $(CURDIR)
	@echo "MAKEFLAGS          = " $(MAKEFLAGS)
	@echo "MAKEFILE_LIST      = " $(MAKEFILE_LIST)
	@echo "MAKECMDGOALS       = " $(MAKECMDGOALS)
	@echo "MAKEOVERRIDES      = " $(MAKEOVERRIDES)
	@echo "MAKELEVEL          = " $(MAKELEVEL)
	@echo "VPATH              = " $(VPATH)
	@echo ""

	@echo "OUTPUT_ROOT        = " $(OUTPUT_ROOT)
	@echo "OUTPUT_INC         = " $(OUTPUT_INC)
	@echo "OUTPUT_BIN         = " $(OUTPUT_BIN)
	@echo "OUTPUT_LIB         = " $(OUTPUT_LIB)
	@echo "OUTPUT_OBJ         = " $(OUTPUT_OBJ)
	@echo "OUTPUT_ETC         = " $(OUTPUT_ETC)
	@echo ""

	@echo "CROSS_COMPILE      = " $(CROSS_COMPILE)
	@echo "CC                 = " $(CC)
	@echo "CXX                = " $(CXX)
	@echo "CPP                = " $(CPP)
	@echo "AS                 = " $(AS)
	@echo "LD                 = " $(LD)
	@echo "AR                 = " $(AR)
	@echo "NM                 = " $(NM)
	@echo "STRIP              = " $(STRIP)
	@echo "OBJCOPY            = " $(OBJCOPY)
	@echo "OBJDUMP            = " $(OBJDUMP)
	@echo "OBJSIZE            = " $(OBJSIZE)
	@echo ""

	@echo "CPPFLAGS           = " $(CPPFLAGS)
	@echo "CFLAGS             = " $(CFLAGS)
	@echo "CXXFLAGS           = " $(CXXFLAGS)
	@echo "ASFLAGS            = " $(ASFLAGS)
	@echo "LDFLAGS            = " $(LDFLAGS)
	@echo "LOADLIBES          = " $(LOADLIBES)
	@echo "LDLIBS             = " $(LDLIBS)
	@echo "ARFLAGS            = " $(ARFLAGS)
	@echo ""

help-common:
	@echo "make <BUILD_ENV=[release|debug|debuginfo|map]> <BUILD_VERBOSE=[0|1|2|3]>"
	@echo "     <BUILD_VERSION=1> <VERSION=xxx>"
	@echo "     <CROSS_COMPILE=arm-linux-gnueabi-> <LLVM=[0|1]> <LLVM_TARGET=xxx>"
	@echo "     <D=[0|1|2|3]> <V=[0|1|2|3]> <O=/opt/out> <show> <help>"

	@echo ""
	@echo "    CROSS_COMPILE       cross compile toolchain"
	@echo "    BUILD_ENV           [release|debug|debuginfo|map] default is release"
	@echo "    BUILD_VERBOSE       [0 breif | 1 compile message | 2 with debug message | 3 all message] default is 0"
	@echo "    BUILD_OUTPUT        output default is out"
	@echo "    BUILD_VERSION       build version.c from version.ver"
	@echo "    VERSION             -DVERSION=xxx to CFLAGS and CXXFLAGS"
	@echo "    LLVM                use clang/clang++"
	@echo "    LLVM_TARGET         llvm cross compile target"
	@echo "    D                   [0 release | 1 debug | 2 debuginfo | 3 map] default is 0, same as BUILD_ENV"
	@echo "    V                   same as BUILD_VERBOSE"
	@echo "    O                   same as BUILD_OUTPUT"
	@echo "    show                show current configuration"
	@echo "    help                show this help"
	@echo ""
	@echo ""


.DELETE_ON_ERROR:

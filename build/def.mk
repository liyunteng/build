ifeq ($(MAKELEVEL),0)

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

# Verbose
V ?= 0
BUILD_VERBOSE ?=0
ifeq ("$(origin V)", "command line")
	BUILD_VERBOSE = $(V)
endif
ifeq ($(BUILD_VERBOSE),0)
    Q1 := @
    Q2 := @
    Q3 := @
	Q  := @
    MAKEFLAGS += --no-print-directory -s
else ifeq ($(BUILD_VERBOSE),1)
    Q1 :=
    Q2 := @
    Q3 := @
	Q  := @
    MAKEFLAGS += --no-print-directory
else ifeq ($(BUILD_VERBOSE),2)
    Q1 :=
    Q2 :=
    Q3 := @
	Q  := @
    MAKEFLAGS += --no-print-directory
else ifeq ($(BUILD_VERBOSE),3)
    Q1 :=
    Q2 :=
    Q3 :=
	Q  := @
else
	Q1 :=
	Q2 :=
	Q3 :=
	Q  :=
endif

# Output
BUILD_PWD    := $(abspath $(CURDIR))
BUILD_OUTPUT ?= $(abspath $(CURDIR))/out
ifeq ("$(origin O)", "command line")
    BUILD_OUTPUT = $(abspath $(O))
endif
ifneq ($(BUILD_OUTPUT),$(BUILD_PWD))
# MAKEFLAGS += --include-dir=$(BUILD_PWD)
endif

OUT_ROOT	  ?= $(BUILD_OUTPUT)
OUT_INCLUDE   ?= $(OUT_ROOT)/include
OUT_BIN       ?= $(OUT_ROOT)/bin
OUT_LIB       ?= $(OUT_ROOT)/lib
OUT_OBJECT    ?= $(OUT_ROOT)/obj
OUT_CONFIG    ?= $(OUT_ROOT)/etc

# Tools
SHELL       := /bin/sh
OS_TYPE     := $(shell uname)
CP          := cp -rf
RM          := rm -rf
MKDIR       := mkdir -p

# Compiler
# ******************************
CC		    := $(CROSS_COMPILE)cc
CXX         := $(CROSS_COMPILE)c++
CPP		    := $(CC) -E

ISCLANG := $(findstring clang,$(shell $(CC) --version))

ifneq ($(ISCLANG),)
AS          := $(CROSS_COMPILE)llvm-as
LD		    := $(CROSS_COMPILE)llvm-l
AR		    := $(CROSS_COMPILE)llvm-ar
NM		    := $(CROSS_COMPILE)llvm-nm
STRIP	    := $(CROSS_COMPILE)llvm-strip
OBJCOPY	    := $(CROSS_COMPILE)llvm-objcopy
OBJDUMP	    := $(CROSS_COMPILE)llvm-objdump
OBJSIZE		:= $(CROSS_COMPILE)llvm-size
else
AS		    := $(CROSS_COMPILE)as
LD		    := $(CROSS_COMPILE)ld
AR		    := $(CROSS_COMPILE)ar
NM		    := $(CROSS_COMPILE)nm
STRIP	    := $(CROSS_COMPILE)strip
OBJCOPY	    := $(CROSS_COMPILE)objcopy
OBJDUMP	    := $(CROSS_COMPILE)objdump
OBJSIZE		:= $(CROSS_COMPILE)size
endif

CPPFLAGS    ?= -I$(OUT_INCLUDE)
CFLAGS      ?= -Wall -fstack-protector -Wmissing-prototypes -Wstrict-prototypes
CXXFLAGS    ?= -Wall -fstack-protector
ASFLAGS     ?= -D__ASSEMBLY__ -fno-PIE
LDFLAGS     ?=
LOADLIBES   ?=
LDLIBS      ?=
ARFLAGS     := rcs

ifeq ($(ISCLANG),)
LDFLAGS += -Wl,--build-id
endif

ifeq ($(BUILD_ENV), release)
	CFLAGS += -O2 -DNDEBUG
	CXXFLAGS += -O2 -DNDEBUG
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

export
endif


default: all
.PHONY: show-common help-common
show-common:
	@echo "=============== $(CURDIR) ==============="
	@echo "BUILD_ENV          = " $(BUILD_ENV)
	@echo "BUILD_VERBOSE      = " $(BUILD_VERBOSE)
	@echo "BUILD_PWD          = " $(BUILD_PWD)
	@echo "BUILD_OUTPUT       = " $(BUILD_OUTPUT)
	@echo "D                  = " $(D)
	@echo "O                  = " $(O)
	@echo "Q                  = " $(Q)
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

	@echo "OUT_ROOT           = " $(OUT_ROOT)
	@echo "OUT_INCLUDE        = " $(OUT_INCLUDE)
	@echo "OUT_BIN            = " $(OUT_BIN)
	@echo "OUT_LIB            = " $(OUT_LIB)
	@echo "OUT_OBJECT         = " $(OUT_OBJECT)
	@echo "OUT_CONFIG         = " $(OUT_CONFIG)
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
	@echo "make <BUILD_ENV=[release|debug|debuginfo|map]> <CROSS_COMPILE=arm-linux-gnueabi-> <O=/opt/out> <V=[0|1|2|3]> <D=[0|1|2|3]> <show> <help>"
	@echo ""
	@echo "    BUILD_ENV           [release|debug|debuginfo|map] default is release"
	@echo "    CROSS_COMPILE       cross compile toolchain"
	@echo "    O                   output"
	@echo "    V                   [0|1|2|3] verbose"
	@echo "    D                   0 release | 1 debug | 2 gen debuginfo | 3 gen map"
	@echo "    show                show current configuration"
	@echo "    help                show this help"
	@echo ""
	@echo ""


.DELETE_ON_ERROR:

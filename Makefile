PROJECT_ROOT ?= $(abspath .)
include $(PROJECT_ROOT)/build/def.mk

SUBDIRS = calc x a

include $(PROJECT_ROOT)/build/debug.mk
include $(PROJECT_ROOT)/build/subdir.mk

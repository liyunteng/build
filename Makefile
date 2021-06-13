PROJECT_ROOT := $(abspath .)

SUBDIRS = calc x a

include $(PROJECT_ROOT)/build/subdir.mk

PROJECT_ROOT := $(abspath .)

# CROSS_COMPILE = arm-hisiv200-linux-gnueabi-
SUBDIRS = calc cross_compile x

include $(PROJECT_ROOT)/scripts/subdir.mk

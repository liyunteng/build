PROJECT_ROOT := $(abspath ..)

CONFIG_FILES += abc.conf def.conf
ADDED_FILES += ddd afile
ifeq ($(MAKELEVEL),0)
CALC:=$(PROJECT_ROOT)/calc
INCLUDE_DIRS += $(CALC)/include
LOADLIBES += -L$(CALC)/out/lib -Wl,-rpath $(CALC)/out/lib -lcalc
else
LOADLIBES += -L$(OUT_LIB) -Wl,-rpath $(OUT_LIB) -lcalc
endif

include $(PROJECT_ROOT)/build/bin.mk

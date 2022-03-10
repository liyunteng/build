PROJECT_ROOT := $(abspath ..)

EXPORT_CONFIG_FILES += abc.conf def.conf
EXPORT_FILE_FILES += ddd afile

ifeq ($(MAKELEVEL),0)
CALC:=$(PROJECT_ROOT)/calc
INCLUDES += $(CALC)/include
LOADLIBES += -L$(CALC)/out/lib -Wl,-rpath $(CALC)/out/lib -lcalc
else
LOADLIBES += -L$(OUT_LIB) -Wl,-rpath $(OUT_LIB) -lcalc
endif

include $(PROJECT_ROOT)/scripts/bin.mk

include ../build/def.mk

ifeq ($(MAKELEVEL),0)
CALC=$(realpath ../calc/)
INCLUDE_DIR += $(CALC)/include
LOADLIBES += -L$(CALC)/out/lib -Wl,-rpath=$(CALC)/out/lib -lcalc
else
INCLUDE_DIR += $(OUT_INCLUDE)
LOADLIBES += -L$(OUT_LIB) -Wl,-rpath=$(OUT_LIB) -lcalc
endif

include ../build/debug.mk
include ../build/bin.mk

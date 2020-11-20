include ../build/def.mk

ifeq ($(MAKELEVEL),0)
ABC=$(realpath ../abc/)
INCLUDE_DIR += $(ABC)/include
LOADLIBES += -L$(ABC)/out/lib -labc -Wl,-rpath=$(ABC)/out/lib
else
INCLUDE_DIR += $(OUT_INCLUDE)
LOADLIBES += -L$(OUT_LIB) -labc -Wl,-rpath=$(OUT_LIB)
endif

include ../build/debug.mk
include ../build/bin.mk

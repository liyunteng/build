MODE := module
MODULE_ROOT ?= $(shell pwd)
MODULE_NAME ?= $(shell basename $(MODULE_ROOT))

include $(PROJECT_ROOT)/scripts/def.mk
include $(PROJECT_ROOT)/scripts/cmd.mk
OBJOUT := $(OUT_OBJECT)$(dir $(subst $(PROJECT_ROOT),,$(shell pwd)))

ifeq ($(LOCAL_SO), y)
LIBSO := $(OUT_LIB)/lib$(MODULE_NAME).so
else
LIBSO :=
endif
LIBA  := $(OUT_LIB)/lib$(MODULE_NAME).a
LIB   := $(LIBA) $(LIBSO)

LOCAL_SRCS := $(shell find $(abspath .) -type f -name "*.c" -o -name "*.cc" -o -name "*.cpp" -o -name "*.s" -o -name "*.S")
LOCAL_CSRCS    := $(filter %.c,   $(LOCAL_SRCS))
LOCAL_CPPSRCS  := $(filter %.cpp, $(LOCAL_SRCS))
LOCAL_ASMSRCS  := $(filter %.S,   $(LOCAL_SRCS))
LOCAL_ASMSRCS2 := $(filter %.s,   $(LOCAL_SRCS))
LOCAL_CCSRCS   := $(filter %.cc,  $(LOCAL_SRCS))

LOCAL_COBJS    := $(patsubst $(MODULE_ROOT)/%.c,   $(OBJOUT)/%.o, $(LOCAL_CSRCS))
LOCAL_CPPOBJS  := $(patsubst $(MODULE_ROOT)/%.cpp, $(OBJOUT)/%.o, $(LOCAL_CPPSRCS))
LOCAL_ASMOBJS  := $(patsubst $(MODULE_ROOT)/%.S,   $(OBJOUT)/%.o, $(LOCAL_ASMSRCS))
LOCAL_ASMOBJS2 := $(patsubst $(MODULE_ROOT)/%.s,   $(OBJOUT)/%.o, $(LOCAL_ASMSRCS2))
LOCAL_CCOBJS   := $(patsubst $(MODULE_ROOT)/%.cc,  $(OBJOUT)/%.o, $(LOCAL_CCSRCS))

LOCAL_OBJS := $(LOCAL_COBJS) $(LOCAL_CPPOBJS) $(LOCAL_ASMOBJS) $(LOCAL_ASMOBJS2) $(LOCAL_CCOBJS)

LOCAL_CGCH   := $(patsubst %.h,%.h.gch,$(LOCAL_CHS))
LOCAL_CPPGCH := $(patsubst %.h,%.h.gch,$(LOCAL_CPPHS))
# $(info OBJOUT = $(OBJOUT))
# $(info LOCAL_SRCS = $(LOCAL_SRCS))
# $(info LOCAL_CSRCS = $(LOCAL_CSRCS))
# $(info LOCAL_CPPSRCS = $(LOCAL_CPPSRCS))
# $(info LOCAL_ASMSRCS = $(LOCAL_ASMSRCS))
# $(info LOCAL_ASMSRCS2 = $(LOCAL_ASMSRCS2))
# $(info LOCAL_CCSRCS = $(LOCAL_CCSRCS))

# $(info LOCAL_OBJS = $(LOCAL_OBJS))
# $(info LOCAL_COBJS = $(LOCAL_COBJS))
# $(info LOCAL_CPPOBJS = $(LOCAL_CPPOBJS))
# $(info LOCAL_ASMOBJS = $(LOCAL_ASMOBJS))
# $(info LOCAL_ASMOBJS2 = $(LOCAL_ASMOBJS2))
# $(info LOCAL_CCOBJS = $(LOCAL_CCOBJS))

LOCAL_INC ?= include
CPPFLAGS += $(foreach dir, $(MODULE_ROOT)/$(LOCAL_INC), -I$(dir))
LOCAL_EXPORT_DIR ?= $(LOCAL_INC)
LOCAL_EXPORT_FILES := $(foreach dir, $(MODULE_ROOT)/$(LOCAL_EXPORT_DIR), $(shell find $(dir) -type f))
LOCAL_EXPORTED_FILES := $(LOCAL_EXPORT_FILES:$(MODULE_ROOT)/$(LOCAL_EXPORT_DIR)/%=$(OUT_INCLUDE)/%)
# $(info LOCAL_EXPORT_FILES = $(LOCAL_EXPORT_FILES))
# $(info LOCAL_EXPORTED_FILES = $(LOCAL_EXPORTED_FILES))

OBJ_MKDIR = if [ ! -d $(dir $@) ]; then mkdir -p $(dir $@); fi


all: header SUB_MODULE_BUILD $(LIB)

header: $(LOCAL_EXPORTED_FILES)
$(LOCAL_EXPORTED_FILES): $(OUT_INCLUDE)/% : $(LOCAL_EXPORT_DIR)/%
	$(Q3)$(OBJ_MKDIR)
	$(call cmd_cp,$(MODULE_NAME),$<,$@)

SUB_MODULE_BUILD: $(MODULE_y)
	$(Q3)for dir in $(MODULE_y); \
		do $(MAKE) -C $$dir all || exit 1; \
	done


$(OBJOUT)/%.o: %.c
	$(Q3)$(OBJ_MKDIR)
	$(call cmd_c,$(MODULE_NAME),$<,$@)

$(OBJOUT)/%.o: %.S
	$(Q3)$(OBJ_MKDIR)
	$(call cmd_c,$(MODULE_NAME),$<,$@)

$(OBJOUT)/%.o: %.s
	$(Q3)$(OBJ_MKDIR)
	$(call cmd_as,$(MODULE_NAME),$<,$@)

$(OBJOUT)/%.o: %.cpp
	$(Q3)$(OBJ_MKDIR)
	$(call cmd_cxx,$(MODULE_NAME),$<,$@)

$(OBJOUT)/%.o: %.cc
	$(Q3)$(OBJ_MKDIR)
	$(call cmd_cxx,$(MODULE_NAME),$<,$@)

$(LOCAL_CGCH): %.h.gch : %.h
	$(Q3)$(OBJ_MKDIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) $> $^

$(LOCAL_CPPGCH): %.h.gch : %.h
	$(Q3)$(OBJ_MKDIR)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -x c++-header $> $^

$(LOCAL_OBJS): $(LOCAL_GCH)

$(LIBA): $(LOCAL_OBJS)
	$(Q3)$(OBJ_MKDIR)
	$(call cmd_lib,$(MODULE_NAME),$(LOCAL_OBJS),$@)

$(LIBSO): $(LOCAL_OBJS)
	$(Q3)$(OBJ_MKDIR)
	$(call cmd_solib,$(MODULE_NAME),$(LOCAL_OBJS),$@)


clean:
	$(call cmd_rm,$(MODULE_NAME),$(OUT_ROOT))
LOCAL_CSRCS    :=
LOCAL_CPPSRCS  :=
LOCAL_ASMSRCS  :=
LOCAL_COBJS    :=
LOCAL_CPPOBJS  :=
LOCAL_ASMOBJS  :=
LOCAL_ASMOBJS2 :=

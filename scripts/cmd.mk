COLOR_RED    := \033[1;31m
COLOR_GREEN  := \033[1;32m
COLOR_YELLOW := \033[1;33m
COLOR_BLUE   := \033[1;34m
COLOR_PURPLE := \033[1;35m
COLOR_CYAN   := \033[1;36m
COLOR_NORMAL := \033[0;00m

CCMSG     := "CC"
CXXMSG    := "CXX"
LDMSG     := "LD"
CXXLDMSG  := "CXXLD"
ARMSG     := "AR"
CXXARMSG  := "CXXAR"
STRIPMSG  := "STRIP"
CPMSG     := "COPY"
RMMSG     := "RM"
DBGMSG    := "DBG"
MKDIRMSG  := "MKDIR"
ASMSG     := "AS"
# PRINT4    := printf "$(COLOR_GREEN)%-6.6s$(COLOR_NORMAL) [%s]  %0.0s%s\n"
# PRINT3    := printf "$(COLOR_GREEN)%-6.6s$(COLOR_NORMAL) [%s]  %s\n"

SUCC4    := printf "$(COLOR_GREEN)%-6.6s$(COLOR_NORMAL) [%s]  %0.0s%s\n"
SUCC3    := printf "$(COLOR_GREEN)%-6.6s$(COLOR_NORMAL) [%s]  %s\n"
FAIL4    := printf "$(COLOR_RED)%-6.6s$(COLOR_NORMAL) [%s]  %0.0s%s\n"
FAIL3    := printf "$(COLOR_RED)%-6.6s$(COLOR_NORMAL) [%s]  %s\n"

ifeq ($(BUILD_ENV),map)
ifeq ($(ISCLANG),)
	LDFLAGS += -Wl,-Map,$@.map
else
	LDFLAGS += -Wl,-map,$@.map
endif
endif


cmd_cp = \
	$(Q3)$(CP) $(2) $(3) && \
	$(SUCC4) $(CPMSG) $(1) $(2) $(3) || \
	$(FAIL4) $(CPMSG) $(1) $(2) $(3)

cmd_mkdir = \
	$(Q3)$(MKDIR) $(2) && \
	$(SUCC3) $(MKDIRMSG) $(1) $(2) || \
	$(FAIL3) $(MKDIRMSG) $(1) $(2)

cmd_rm = \
	$(Q3)[ -d $(2) ] && $(RM) $(2) || exit 0; \
	$(SUCC3) $(RMMSG) $(1) $(2)

cmd_c = \
	$(Q1)$(CC) -c -o $(3) $(2) $(CPPFLAGS) $(CFLAGS) -MD -MQ $(3) -MF $(3).d && \
	$(SUCC4) $(CCMSG) $(1) $(2) $(3) || \
	$(FAIL4) $(CCMSG) $(1) $(2) $(3)

cmd_cxx = \
	$(Q1)$(CXX) -c -o $(3) $(2) $(CPPFLAGS) $(CXXFLAGS) -MD -MQ $(3) -MF $(3).d && \
	$(SUCC4) $(CXXMSG) $(1) $(2) $(3) || \
	$(FAIL4) $(CXXMSG) $(1) $(2) $(3)

cmd_as = \
	$(Q1) $(AS) -c -o $(3) $(2) $(ASFLAGS) && \
	$(SUCC4) $(ASMSG) $(1) $(2) $(3) || \
	$(FAIL4) $(ASMSG) $(1) $(2) $(3)

ifeq ($(BUILD_ENV),debuginfo)
cmd_debuginfo = \
	$(Q2)
	$(OBJCOPY) --only-keep-debug $(3) $(3).debuginfo; \
	$(OBJCOPY) --strip-debug $(3); \
	$(OBJCOPY) --add-gnu-debuglink=$(3).debuginfo $(3) && \
	$(SUCC4) $(DBGMSG) $(1) $(3) $(3).debuginfo || \
	$(FAIL4) $(DBGMSG) $(1) $(3) $(3).debuginfo || \
else
cmd_debuginfo =
endif

ifneq ($(BUILD_ENV),debug)
cmd_strip = \
	$(Q2)$(STRIP) $(3) && \
	$(SUCC4) $(STRIPMSG) $(1) $(3) $(3) || \
	$(FAIL4) $(STRIPMSG) $(1) $(3) $(3)
else
cmd_strip =
endif

cmd_bin = \
	$(Q1)$(CC) -o $(3) $(2) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) && \
	$(SUCC3) $(LDMSG) $(1) $(3) || \
	$(FAIL3) $(LDMSG) $(1) $(3)

cmd_cxxbin = \
	$(Q1)$(CXX) -o $(3) $(2) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) && \
	$(SUCC3) $(CXXLDMSG) $(1) $(3) || \
	$(FAIL3) $(CXXLDMSG) $(1) $(3)

cmd_lib = \
	$(Q1)$(AR) $(ARFLAGS) $(3) $(2) && \
	$(SUCC3) $(ARMSG) $(1) $(3) || \
	$(FAIL3) $(ARMSG) $(1) $(3)

cmd_cxxlib = \
	$(Q1)$(AR) $(ARFLAGS) $(3) $(2) && \
	$(SUCC3) $(CXXARMSG) $(1) $(3) || \
	$(FAIL3) $(CXXARMSG) $(1) $(3)

cmd_solib = \
	$(Q1)$(CC) -o $(3) $(2) -shared $(LDFLAGS) $(LOADLIBES) $(LDLIBS) && \
	$(SUCC3) $(LDMSG) $(1) $(3) || \
	$(FAIL3) $(LDMSG) $(1) $(3)

cmd_cxxsolib = \
	$(Q)$(CXX) -o $(3) $(2) -shared $(LDFLAGS) $(LOADLIBES) $(LDLIBS) && \
	$(SUCC3) $(CXXLDMSG) $(1) $(3) || \
	$(FAIL3) $(CXXLDMSG) $(1) $(3)

cmd_bins = \
	$(Q1)$(CC) -o $(3) $(2) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) && \
	$(SUCC3) $(LDMSG) $(1) $(3) || \
	$(FAIL3) $(LDMSG) $(1) $(3)

cmd_cxxbins = \
	$(Q1)$(CXX) -o $(3) $(2) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) && \
	$(SUCC3) $(CXXLDMSG) $(1) $(3) || \
	$(FAIL3) $(CXXLDMSG) $(1) $(3)

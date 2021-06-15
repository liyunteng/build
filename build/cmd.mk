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
# PRINT4    := printf "$(COLOR_GREEN)%-6.6s$(COLOR_NORMAL) [%s]  %s  =>  %s\n"
PRINT4    := printf "$(COLOR_GREEN)%-6.6s$(COLOR_NORMAL) [%s]  %0.0s%s\n"
# PRINT4    := printf "$(COLOR_GREEN)%-6.6s$(COLOR_NORMAL) [%s]  %s%0.0s\n"
PRINT3    := printf "$(COLOR_GREEN)%-6.6s$(COLOR_NORMAL) [%s]  %s\n"

cmd_cp = \
	$(Q3)$(PRINT4) $(CPMSG) $(1) $(2) $(3); \
	$(CP) $(2) $(3)

cmd_mkdir = \
	$(Q3)$(PRINT3) $(MKDIRMSG) $(1) $(2); \
	$(MKDIR) $(2)

cmd_rm = \
	$(Q3)[ -d $(2) ] && $(RM) $(2) || exit 0; \
	$(PRINT3) $(RMMSG) $(1) $(2)

cmd_c = \
	$(Q1)$(PRINT4) $(CCMSG) $(1) $(2) $(3); \
	$(CC) $(CPPFLAGS) $(CFLAGS) -MD -MQ $(3) -MF $(3).d -c $(2) -o $(3)

cmd_cxx = \
	$(Q1)$(PRINT4) $(CXXMSG) $(1) $(2) $(3); \
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -MD -MQ $(3) -MF $(3).d -c $(2) -o $(3)

cmd_as = \
	$(Q1)$(PRINT4) $(ASMSG) $(1) $(2) $(3); \
	$(AS) $(ASFLAGS) -c $(2) -o $(3)

ifeq ($(BUILD_ENV),debuginfo)
cmd_debuginfo = \
	$(Q2)$(PRINT4) $(DBGMSG) $(1) $(3) $(3).debuginfo; \
	$(OBJCOPY) --only-keep-debug $(3) $(3).debuginfo; \
	$(OBJCOPY) --strip-debug $(3); \
	$(OBJCOPY) --add-gnu-debuglink=$(3).debuginfo $(3)
else
cmd_debuginfo =
endif

ifneq ($(BUILD_ENV),debug)
cmd_strip = \
	$(Q2)$(PRINT4) $(STRIPMSG) $(1) $(3) $(3); \
	$(STRIP) $(3)
else
cmd_strip =
endif

cmd_bin = \
	$(Q1)$(PRINT3) $(LDMSG) $(1) $(3); \
	$(CC) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) $(2) -o $(3)

cmd_cxxbin = \
	$(Q1)$(PRINT3) $(CXXLDMSG) $(1) $(3); \
	$(CXX) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) $(2) -o $(3)

cmd_lib = \
	$(Q1)$(PRINT3) $(ARMSG) $(1) $(3); \
	$(AR) $(ARFLAGS) $(3) $(2)

cmd_cxxlib = \
	$(Q1)$(PRINT3) $(CXXARMSG) $(1) $(3); \
	$(AR) $(ARFLAGS) $(3) $(2)

cmd_solib = \
	$(Q1)$(PRINT3) $(LDMSG) $(1) $(3); \
	$(CC) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) -shared $(2) -o $(3)

cmd_cxxsolib = \
	$(Q)$(PRINT3) $(CXXLDMSG) $(1) $(3); \
	$(CXX) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) -shared $(2) -o $(3)

cmd_bins = \
	$(Q1)$(PRINT3) $(LDMSG) $(1) $(3);  \
	$(CC) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) $(2) -o $(3)

cmd_cxxbins = \
	$(Q1)$(PRINT3) $(CXXLDMSG) $(1) $(3); \
	$(CXX) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) $(2) -o $(3)

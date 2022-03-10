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
RANLIBMSG := "RANLIB"
CDEPMSG   := "CDEP"
CXXDEPMSG := "CXXDEP"

ifeq ($(BUILD_ENV),map)
ifeq ($(ISCLANG),)
	LDFLAGS += -Wl,-Map,$@.map
else
	LDFLAGS += -Wl,-map,$@.map
endif
endif

ifneq ($(V),-1)
cmd_show = ;\
	if [ $$? -eq 0 ]; then \
		printf "$(COLOR_GREEN)%-6.6s$(COLOR_NORMAL) [%s]  %s\n" $(1) $(2) $(3); \
	else \
		printf "$(COLOR_RED)%-6.6s$(COLOR_NORMAL) [%s] %s\n" $(1) $(2) $(3) && exit 1; \
	fi
else
cmd_show =
endif

cmd_cp = \
	$(Q3)$(CP) $(2) $(3) \
	$(call cmd_show,$(CPMSG),$(1),$(3))

cmd_mkdir = \
	$(Q3)[ ! -d $(dir $(2)) ] && $(MKDIR) $(dir $(2)) || exit 0 \
	$(call cmd_show,$(MKDIRMSG),$(1),$(dir $(2)))

cmd_rm = \
	$(Q3)[ -d $(2) ] && $(RM) $(2) || exit 0 \
	$(call cmd_show,$(RMMSG),$(1),$(2))

cmd_as = \
	$(Q1)$(AS) -c -o $(3) $(2) $(ASFLAGS) \
	$(call cmd_show,$(ASMSG),$(1),$(3))

cmd_ranlib = \
	$(Q1)$(RANLIB) $(3) \
	$(call cmd_show,$(RANLIBMSG),$(1),$(3))

cmd_cdep = \
	$(Q3)rm -f $(3); \
	$(CC) -MM $(CFLAGS) $(CPPFLAGS) $(2) > $(3).$$$$; \
	sed 's,\($(notdir $(4))\)\.o[ :]*,$(OUTPUT_OBJ)/$(4)\.o $(3): ,g' < $(3).$$$$ > $(3); \
	rm -rf $(3).$$$$ \
	$(call cmd_show,$(CDEPMSG),$(1),$(3))

cmd_cxxdep = \
	$(Q3)rm -f $(3); \
	$(CXX) -MM $(CXXFLAGS) $(CPPFLAGS) $(2) > $(3).$$$$; \
	sed 's,\($(notdir $(4))\)\.o[ :]*,$(OUTPUT_OBJ)/$(4)\.o $(3): ,g' < $(3).$$$$ > $(3); \
	rm -rf $(3).$$$$ \
	$(call cmd_show,$(CXXDEPMSG),$(1),$(3))

cmd_c = \
	$(Q1)$(CC) -c -o $(3) $(2) $(CPPFLAGS) $(CFLAGS) \
	$(call cmd_show,$(CCMSG),$(1),$(3))

cmd_cxx = \
	$(Q1)$(CXX) -c -o $(3) $(2) $(CPPFLAGS) $(CXXFLAGS) \
	$(call cmd_show,$(CXXMSG),$(1),$(3))

cmd_cxxlib = \
	$(Q1)$(AR) $(ARFLAGS) $(3) $(2) \
	$(call cmd_show,$(CXXARMSG),$(1),$(3))

cmd_solib = \
	$(Q1)$(CC) -o $(3) $(2) -shared $(LDFLAGS) $(LOADLIBES) $(LDLIBS)\
	$(call cmd_show,$(LDMSG),$(1),$(3))

cmd_cxxsolib = \
	$(Q1)$(CXX) -o $(3) $(2) -shared $(LDFLAGS) $(LOADLIBES) $(LDLIBS) \
	$(call cmd_show,$(CXXLDMSG),$(1),$(3))

cmd_bin = \
	$(Q1)$(CC) -o $(3) $(2) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) \
	$(call cmd_show,$(LDMSG),$(1),$(3))

cmd_cxxbin = \
	$(Q1)$(CXX) -o $(3) $(2) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) \
	$(call cmd_show,$(CXXLDMSG),$(1),$(3))

cmd_lib = \
	$(Q1)$(AR) $(ARFLAGS) $(3) $(2) \
	$(call cmd_show,$(ARMSG),$(1),$(3))

cmd_bins = \
	$(Q1)$(CC) -o $(3) $(2) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) \
	$(call cmd_show,$(LDMSG),$(1),$(3))

cmd_cxxbins = \
	$(Q1)$(CXX) -o $(3) $(2) $(LDFLAGS) $(LOADLIBES) $(LDLIBS) \
	$(call cmd_show,$(CXXLDMSG),$(1),$(3))

ifeq ($(BUILD_ENV),debuginfo)
cmd_debuginfo = \
	$(Q2)$(OBJCOPY) --only-keep-debug $(3) $(3).debuginfo; \
	$(OBJCOPY) --strip-debug $(3); \
	$(OBJCOPY) --add-gnu-debuglink=$(3).debuginfo $(3) \
	$(call cmd_show,$(DBGMSG),$(1),$(3).debuginfo)
else
cmd_debuginfo =
endif

ifneq ($(BUILD_ENV),debug)
cmd_strip = \
	$(Q2)$(STRIP) --strip-all $(3) \
	$(call cmd_show,$(STRIPMSG),$(1),$(3))

ifeq ($(OS_TYPE),Darwin)
# Darwin not support --strip-unneeded
cmd_strip_static = \
	$(Q2)$(STRIP) --strip-debug $(3) \
	$(call cmd_show,$(STRIPMSG),$(1),$(3))
else
cmd_strip_static = \
	$(Q2)$(STRIP) --strip-debug --strip-unneeded $(3) \
	$(call cmd_show,$(STRIPMSG),$(1),$(3))
endif

else
cmd_strip =
cmd_strip_static =
endif

all: compile link
override CFLAGS += $(patsubst %,-I%,$(subst :, ,$(VPATH)))
ABSTARGET=$(patsubst %, $(abs_objtree)/%, $(TARGET))
compile: $(DEPEND_C) $(OBJECT_C) $(DEPEND_CXX) $(OBJECT_CXX)

link: $(ABSTARGET)
$(DEPEND_C): %.d : %.c
	@set -e; rm -f $@; \
	$(CC) -MM  $< > $@.$$$$; \
	sed 's,/($*/)/.o[ :]*,/1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$
# sinclude $(DEPEND_C)
sinclude $(SOURCE_C:.c=.d)

$(DEPEND_CXX): %.d : %.cpp
	@set -e; rm -f $@; \
	$(CXX) -MM  $< > $@.$$$$; \
	sed 's,/($*/)/.o[ :]*,/1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$
# sinclude $(DEPEND_CXX)
sinclude $(SOURCE_CXX:.cpp=.d)

$(OBJECT_C): %.o : %.c
	@echo "[CC]    $@"
	$(Q)$(CC) -c $(BUILD_CFLAGS) $< -o $@

$(OBJECT_CXX): %.o : %.cpp
	@echo "[CXX]   $@"
	$(@)$(CC) -c $(BUILD_CXXFLAGS) $< -o $@

$(ABSTARGET): $(OBJECT_C) $(OBJECT_CXX)
	@echo "[LINK]  $@"
	$(Q)$(CC) $(BUILD_LDFLAGS) $^ -o $@

debug:
	@$(MAKE) BUILD_ENV=debug all

.PHONY: clean all compile link debug

clean:
	$(Q)rm -rf $(ABSTARGET) $(OBJECT_C) $(OBJECT_CXX) $(DEPEND_C) $(DPEND_CXX)
	@[[ $(BUILD_OUTPUT) == $(BUILD_PWD) ]] || $(Q)rm -rf $(BUILD_OUTPUT)

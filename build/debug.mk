all: show

.PHONY: show

show:
	@echo "MAJOR_VERSION      = " $(MAJOR_VERSION)
	@echo "MINOR_VERSION      = " $(MINOR_VERSION)
	@echo "PATCH_VERSION      = " $(PATCH_VERSION)
	@echo ""

	@echo "BUILD_ENV          = " $(BUILD_ENV)
	@echo "BUILD_VERBOSE      = " $(BUILD_VERBOSE)
	@echo "BUILD_PWD          = " $(BUILD_PWD)
	@echo "BUILD_OUTPUT       = " $(BUILD_OUTPUT)
	@echo ""

	@echo "CC                 = " $(CC)
	@echo "CXX                = " $(CXX)
	@echo "CPP                = " $(CPP)
	@echo "AS                 = " $(AS)
	@echo "LD                 = " $(LD)
	@echo "AR                 = " $(AR)
	@echo "NM                 = " $(NM)
	@echo "STRIP              = " $(STRIP)
	@echo "OBJCOPY            = " $(OBJCOPY)
	@echo "OBJDUMP            = " $(OBJDUMP)
	@echo "OBJSIZE            = " $(OBJSIZE)
	@echo ""

	@echo "BUILD_AFLAGS       = " $(BUILD_AFLAGS)
	@echo "BUILD_CPPFLAGS     = " $(BUILD_CPPFLAGS)
	@echo "BUILD_CFLAGS       = " $(BUILD_CFLAGS)
	@echo "BUILD_CXXFLAGS     = " $(BUILD_CXXFLAGS)
	@echo "BUILD_LDFLAGS      = " $(BUILD_LDFLAGS)
	@echo ""

	@echo "CURDIR             = " $(CURDIR)
	@echo "MAKEFLAGS          = " $(MAKEFLAGS)
	@echo "MAKEFILE_LIST      = " $(MAKEFILE_LIST)
	@echo "MAKECMDGOALS       = " $(MAKECMDGOALS)
	@echo "MAKEOVERRIDES      = " $(MAKEOVERRIDES)
	@echo ""

	@echo "INCLUDEDIR         = " $(INCLUDE_DIR)
	@echo "SOURCE_C           = " $(SOURCE_C)
	@echo "OBJECT_C           = " $(OBJECT_C)
	@echo "DEPEND_C           = " $(DEPEND_C)
	@echo "SOURCE_CXX         = " $(SOURCE_CXX)
	@echo "OBJECT_CXX         = " $(OBJECT_CXX)
	@echo "DEPEND_CXX         = " $(DEPEND_CXX)
	@echo ""


# List of variables we want to print in the build banner.
print_build_config_vars := \
  PLATFORM_VERSION_CODENAME \
  PLATFORM_VERSION \
  CM_VERSION \
  TARGET_PRODUCT \
  TARGET_BUILD_VARIANT \
  TARGET_BUILD_TYPE \
  TARGET_BUILD_APPS \
  TARGET_ARCH \
  TARGET_ARCH_VARIANT \
  TARGET_CPU_VARIANT \
  TARGET_2ND_ARCH \
  TARGET_2ND_ARCH_VARIANT \
  TARGET_2ND_CPU_VARIANT \
  HOST_ARCH \
  HOST_2ND_ARCH \
  HOST_OS \
  HOST_OS_EXTRA \
  HOST_CROSS_OS \
  HOST_CROSS_ARCH \
  HOST_CROSS_2ND_ARCH \
  HOST_BUILD_TYPE \
  BUILD_ID \
  OUT_DIR

ifneq (,$(filter true, $(CYNGN_TARGET) $(EXTERNAL_CLEAN_TARGET)))
ifeq ($(CYNGN_TARGET),true)
print_build_config_vars += \
  CYNGN_TARGET \
  CYNGN_FEATURES
endif
endif

ifeq ($(TARGET_BUILD_PDK),true)
print_build_config_vars += \
  TARGET_BUILD_PDK \
  PDK_FUSION_PLATFORM_ZIP
endif

# ---------------------------------------------------------------
# the setpath shell function in envsetup.sh uses this to figure out
# what to add to the path given the config we have chosen.
ifeq ($(CALLED_FROM_SETUP),true)

ifneq ($(filter /%,$(HOST_OUT_EXECUTABLES)),)
ABP:=$(HOST_OUT_EXECUTABLES)
else
ABP:=$(PWD)/$(HOST_OUT_EXECUTABLES)
endif

ANDROID_BUILD_PATHS := $(ABP)
ANDROID_PREBUILTS := prebuilt/$(HOST_PREBUILT_TAG)
ANDROID_GCC_PREBUILTS := prebuilts/gcc/$(HOST_PREBUILT_TAG)

# The "dumpvar" stuff lets you say something like
#
#     CALLED_FROM_SETUP=true \
#       make -f config/envsetup.make dumpvar-TARGET_OUT
# or
#     CALLED_FROM_SETUP=true \
#       make -f config/envsetup.make dumpvar-abs-HOST_OUT_EXECUTABLES
#
# The plain (non-abs) version just dumps the value of the named variable.
# The "abs" version will treat the variable as a path, and dumps an
# absolute path to it.
#
dumpvar_goals := \
	$(strip $(patsubst dumpvar-%,%,$(filter dumpvar-%,$(MAKECMDGOALS))))
ifdef dumpvar_goals

  ifneq ($(words $(dumpvar_goals)),1)
    $(error Only one "dumpvar-" goal allowed. Saw "$(MAKECMDGOALS)")
  endif

  # If the goal is of the form "dumpvar-abs-VARNAME", then
  # treat VARNAME as a path and return the absolute path to it.
  absolute_dumpvar := $(strip $(filter abs-%,$(dumpvar_goals)))
  ifdef absolute_dumpvar
    dumpvar_goals := $(patsubst abs-%,%,$(dumpvar_goals))
    DUMPVAR_VALUE := $(abspath $($(dumpvar_goals)))
    dumpvar_target := dumpvar-abs-$(dumpvar_goals)
  else
    DUMPVAR_VALUE := $($(dumpvar_goals))
    dumpvar_target := dumpvar-$(dumpvar_goals)
  endif

.PHONY: $(dumpvar_target)
$(dumpvar_target):
	@echo $(DUMPVAR_VALUE)

endif # dumpvar_goals

ifneq ($(dumpvar_goals),report_config)
PRINT_BUILD_CONFIG:=
endif

ifneq ($(filter report_config,$(DUMP_MANY_VARS)),)
# Construct the shell commands that print the config banner.
report_config_sh := echo '============================================';
report_config_sh += $(foreach v,$(print_build_config_vars),echo '$v=$($(v))';)
report_config_sh += echo '============================================';
endif

# Dump mulitple variables to "<var>=<value>" pairs, one per line.
# The output may be executed as bash script.
# Input variables:
#   DUMP_MANY_VARS: the list of variable names.
#   DUMP_VAR_PREFIX: an optional prefix of the variable name added to the output.
#   DUMP_MANY_ABS_VARS: the list of abs variable names.
#   DUMP_ABS_VAR_PREFIX: an optional prefix of the abs variable name added to the output.
.PHONY: dump-many-vars
dump-many-vars :
	@$(foreach v, $(filter-out report_config, $(DUMP_MANY_VARS)),\
	  echo "$(DUMP_VAR_PREFIX)$(v)='$($(v))'";)
ifneq ($(filter report_config, $(DUMP_MANY_VARS)),)
	@# Construct a special variable for report_config.
	@# Escape \` to defer the execution of report_config_sh to preserve the line breaks.
	@echo "$(DUMP_VAR_PREFIX)report_config=\`$(report_config_sh)\`"
endif
	@$(foreach v, $(sort $(DUMP_MANY_ABS_VARS)),\
	  echo "$(DUMP_ABS_VAR_PREFIX)$(v)='$(abspath $($(v)))'";)

endif # CALLED_FROM_SETUP

-include $(TOPDIR)vendor/emotion/tools/colors.mk

ifneq ($(PRINT_BUILD_CONFIG),)
HOST_OS_EXTRA:=$(shell python -c "import platform; print(platform.platform())")

$(info  $(BLDMAG)$(LINE)$(RST))
$(info   PLATFORM_VERSION_CODENAME = $(BLDBLU)$(PLATFORM_VERSION_CODENAME)$(RST))
$(info   PLATFORM_VERSION = $(BLDBLU)$(PLATFORM_VERSION)$(RST))
$(info   EMOTION_VERSION = $(BLDBLU)$(EMOTION_VERSION)$(RST))
$(info   TARGET_PRODUCT = $(BLDBLU)$(TARGET_PRODUCT)$(RST))
$(info   TARGET_BUILD_VARIANT = $(BLDBLU)$(TARGET_BUILD_VARIANT)$(RST))
$(info   TARGET_BUILD_TYPE = $(BLDBLU)$(TARGET_BUILD_TYPE)$(RST))
$(info   TARGET_BUILD_APPS = $(BLDBLU)$(TARGET_BUILD_APPS)$(RST))
$(info   TARGET_ARCH = $(BLDBLU)$(TARGET_ARCH)$(RST))
$(info   TARGET_ARCH_VARIANT = $(BLDBLU)$(TARGET_ARCH_VARIANT)$(RST))
$(info   TARGET_CPU_VARIANT = $(BLDBLU)$(TARGET_CPU_VARIANT)$(RST))
$(info   TARGET_2ND_ARCH = $(BLDBLU)$(TARGET_2ND_ARCH)$(RST))
$(info   TARGET_2ND_ARCH_VARIANT = $(BLDBLU)$(TARGET_2ND_ARCH_VARIANT)$(RST))
$(info   TARGET_2ND_CPU_VARIANT = $(BLDBLU)$(TARGET_2ND_CPU_VARIANT)$(RST))
$(info   HOST_ARCH = $(BLDBLU)$(HOST_ARCH)$(RST))
$(info   HOST_OS = $(BLDBLU)$(HOST_OS)$(RST))
$(info   HOST_OS_EXTRA = $(BLDBLU)$(HOST_OS_EXTRA)$(RST))
$(info   HOST_BUILD_TYPE = $(BLDBLU)$(HOST_BUILD_TYPE)$(RST))
$(info   BUILD_ID = $(BLDBLU)$(BUILD_ID)$(RST))
$(info   OUT_DIR = $(BLDBLU)$(OUT_DIR)$(RST))
ifeq ($(CYNGN_TARGET),true)
$(info   CYNGN_TARGET = $(BLDBLU)$(CYNGN_TARGET)$(RST))
$(info   CYNGN_FEATURES = $(BLDBLU)$(CYNGN_FEATURES)$(RST))
endif
ifneq ($(USE_CCACHE),)
$(info   CCACHE_DIR = $(BLDBLU)$(CCACHE_DIR)$(RST))
$(info   CCACHE_BASEDIR = $(BLDBLU)$(CCACHE_BASEDIR)$(RST))
endif
$(info  $(BLDMAG)$(LINE)$(RST))
endif
$(info =====================================================================)
ifdef TARGET_DEVICE
$(info   TARGET_DEVICE=$(TARGET_DEVICE))
endif
ifdef TARGET_DRAGONTC_VERSION
$(info   DRAGONTC_VERSION=$(TARGET_DRAGONTC_VERSION))
else
$(info   CLANG_VERSION=$(LLVM_PREBUILTS_VERSION))
endif
ifdef SM_AND_NAME
$(info   TARGET_SABERMOD_ANDROID_GCC_VERSION=$(SM_AND_NAME))
endif
ifdef SM_KERNEL_NAME
$(info   TARGET_SABERMOD_KERNEL_GCC_VERSION=$(SM_KERNEL_NAME))
endif
ifdef TARGET_NDK_VERSION
$(info   TARGET_NDK_VERSION=$(TARGET_NDK_VERSION))
else
$(info   TARGET_NDK_VERSION=$(SM_AND_VERSION))
endif
ifdef GCC_OPTIMIZATION_LEVELS
$(info   OPTIMIZATIONS=$(GCC_OPTIMIZATION_LEVELS))
endif
$(info =====================================================================)

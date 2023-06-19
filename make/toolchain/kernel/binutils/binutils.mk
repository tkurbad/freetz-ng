BINUTILS_KERNEL_VERSION:=$(KERNEL_TOOLCHAIN_BINUTILS_VERSION)
BINUTILS_KERNEL_SOURCE:=binutils-$(BINUTILS_KERNEL_VERSION).tar.bz2
BINUTILS_KERNEL_SITE:=@GNU/binutils
BINUTILS_KERNEL_HASH_2.18   := 4515254f55ec3d8c4d91e7633f3850ff28f60652b2d90dc88eef47c74c194bc9
BINUTILS_KERNEL_HASH_2.22   := 6c7af8ed1c8cf9b4b9d6e6fe09a3e1d3d479fe63984ba8b9b26bf356b6313ca9
BINUTILS_KERNEL_HASH_2.23.2 := fe914e56fed7a9ec2eb45274b1f2e14b0d8b4f41906a5194eac6883cfe5c1097
BINUTILS_KERNEL_HASH_2.24   := e5e8c5be9664e7f7f96e0d09919110ab5ad597794f5b1809871177a0f0f14137
BINUTILS_KERNEL_HASH_2.25.1 := b5b14added7d78a8d1ca70b5cb75fef57ce2197264f4f5835326b0df22ac9f22
BINUTILS_KERNEL_HASH_2.26.1 := 39c346c87aa4fb14b2f786560aec1d29411b6ec34dce3fe7309fe3dd56949fd8
BINUTILS_KERNEL_HASH_2.31.1 := ffcc382695bf947da6135e7436b8ed52d991cf270db897190f19d6f9838564d0
BINUTILS_KERNEL_HASH_2.36.1 := 5b4bd2e79e30ce8db0abd76dd2c2eae14a94ce212cfc59d3c37d23e24bc6d7a3
BINUTILS_KERNEL_HASH:=$(BINUTILS_KERNEL_HASH_$(BINUTILS_KERNEL_VERSION))

BINUTILS_KERNEL_DIR:=$(KERNEL_TOOLCHAIN_DIR)/binutils-$(BINUTILS_KERNEL_VERSION)
BINUTILS_KERNEL_MAKE_DIR:=$(MAKE_DIR)/toolchain/kernel/binutils
BINUTILS_KERNEL_DIR1:=$(BINUTILS_KERNEL_DIR)-build

BINUTILS_KERNEL_CFLAGS := $(TOOLCHAIN_HOST_KERNEL_CFLAGS)
ifeq ($(strip $(FREETZ_AVM_GCC_3_4_MAX)),y)
BINUTILS_KERNEL_CFLAGS += -fcommon
endif

BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS := MAKEINFO=true

BINUTILS_KERNEL_ECHO_TYPE:=KTC
BINUTILS_KERNEL_ECHO_MAKE:=binutils


binutils-kernel-source: $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)
$(DL_DIR)/$(BINUTILS_KERNEL_SOURCE): | $(DL_DIR)
	@$(call _ECHO,downloading,$(BINUTILS_KERNEL_ECHO_TYPE),$(BINUTILS_KERNEL_ECHO_MAKE))
	$(DL_TOOL) $(DL_DIR) $(BINUTILS_KERNEL_SOURCE) $(BINUTILS_KERNEL_SITE) $(BINUTILS_KERNEL_HASH) $(SILENT)

binutils-kernel-unpacked: $(BINUTILS_KERNEL_DIR)/.unpacked
$(BINUTILS_KERNEL_DIR)/.unpacked: $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE) | $(KERNEL_TOOLCHAIN_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	@$(call _ECHO,preparing,$(BINUTILS_KERNEL_ECHO_TYPE),$(BINUTILS_KERNEL_ECHO_MAKE))
	$(RM) -r $(BINUTILS_KERNEL_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(BINUTILS_KERNEL_SOURCE),$(KERNEL_TOOLCHAIN_DIR))
	$(call APPLY_PATCHES,$(BINUTILS_KERNEL_MAKE_DIR)/$(call GET_MAJOR_VERSION,$(BINUTILS_KERNEL_VERSION)),$(BINUTILS_KERNEL_DIR))
	# fool zlib test in all configure scripts so it doesn't find zlib and thus no zlib gets linked in
	sed -i -r -e 's,(zlibVersion)([ \t]*[(][)]),\1WeDontWantZlib\2,g' $$(find $(BINUTILS_KERNEL_DIR) -name "configure" -type f)
	touch $@

$(BINUTILS_KERNEL_DIR1)/.configured: $(BINUTILS_KERNEL_DIR)/.unpacked
	@$(call _ECHO,configuring,$(BINUTILS_KERNEL_ECHO_TYPE),$(BINUTILS_KERNEL_ECHO_MAKE))
	mkdir -p $(BINUTILS_KERNEL_DIR1)
	(cd $(BINUTILS_KERNEL_DIR1); \
		CC="$(TOOLCHAIN_HOSTCC)" \
		CFLAGS="$(BINUTILS_KERNEL_CFLAGS)" \
		$(BINUTILS_KERNEL_DIR)/configure \
		--prefix=$(KERNEL_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_KERNEL_NAME) \
		--disable-multilib \
		$(DISABLE_NLS) \
		--disable-werror \
		--without-headers \
		$(SILENT) \
	);
	touch $@

$(BINUTILS_KERNEL_DIR1)/.compiled: $(BINUTILS_KERNEL_DIR1)/.configured
	@$(call _ECHO,building,$(BINUTILS_KERNEL_ECHO_TYPE),$(BINUTILS_KERNEL_ECHO_MAKE))
	$(MAKE) $(BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_KERNEL_DIR1) configure-host $(SILENT)
	$(MAKE) $(BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_KERNEL_DIR1) all $(SILENT)
	touch $@

$(KERNEL_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_KERNEL_NAME)/bin/ld: $(BINUTILS_KERNEL_DIR1)/.compiled
	@$(call _ECHO,installing,$(BINUTILS_KERNEL_ECHO_TYPE),$(BINUTILS_KERNEL_ECHO_MAKE))
	$(MAKE1) $(BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_KERNEL_DIR1) install $(SILENT)
	$(RM) $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_KERNEL_NAME)/bin/ld.bfd $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-ld.bfd
	$(call STRIP_TOOLCHAIN_BINARIES,$(KERNEL_TOOLCHAIN_STAGING_DIR),$(BINUTILS_BINARIES_BIN),$(REAL_GNU_KERNEL_NAME),$(HOST_STRIP))
	$(call REMOVE_DOC_NLS_DIRS,$(KERNEL_TOOLCHAIN_STAGING_DIR))

binutils-kernel: $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_KERNEL_NAME)/bin/ld


binutils-kernel-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(KERNEL_TOOLCHAIN_STAGING_DIR),$(BINUTILS_BINARIES_BIN),$(REAL_GNU_KERNEL_NAME))
	$(RM) -r $(KERNEL_TOOLCHAIN_STAGING_DIR)/lib{,64}/{libiberty*,ldscripts}

binutils-kernel-clean: binutils-kernel-uninstall
	$(RM) -r $(BINUTILS_KERNEL_DIR1)

binutils-kernel-dirclean: binutils-kernel-clean
	$(RM) -r $(BINUTILS_KERNEL_DIR)

binutils-kernel-distclean: binutils-kernel-dirclean


.PHONY: binutils-kernel-source binutils-kernel-unpacked
.PHONY: binutils-kernel binutils-kernel-uninstall binutils-kernel-clean binutils-kernel-dirclean binutils-kernel-distclean


$(call TOOLS_INIT, v6.5)
## patches/100-main_makefile.patch contains also the version
$(PKG)_SOURCE:=kconfig-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=768d9b87cc688cb6f93e29b8b39d13c76e843f99803fe045e2449278e12de5f8
$(PKG)_SITE:=git_archive@git://repo.or.cz/linux.git,scripts/basic,scripts/kconfig,scripts/Kbuild.include,scripts/Makefile.compiler,scripts/Makefile.build,scripts/Makefile.host,scripts/Makefile.lib,Documentation/kbuild/kconfig-language.rst,Documentation/kbuild/kconfig-macro-language.rst,Documentation/kbuild/kconfig.rst

$(PKG)_DEPENDS_ON:=

$(PKG)_BUILD_PREREQ += bison flex
$(PKG)_BUILD_PREREQ_HINT := You have to install the bison and flex packages

$(PKG)_TARGET_DIR:=$(TOOLS_DIR)/kconfig
$(PKG)_TARGET_DEF := conf   mconf
$(PKG)_TARGET_PRG := conf   mconf      nconf   gconf   gconf.glade qconf
$(PKG)_TARGET_ARG := config menuconfig nconfig gconfig gconfig     xconfig
$(PKG)_TARGET_ALL := $(join $(KCONFIG_HOST_TARGET_ARG),$(patsubst %,--%,$(KCONFIG_HOST_TARGET_PRG)))


$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_TOOLS_KCONFIG_BUTTONS),buttons)
$(PKG)_REBUILD_SUBOPTS += FREETZ_TOOLS_KCONFIG_BUTTONS


define $(PKG)_CUSTOM_UNPACK
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xf $(DL_DIR)/$($(PKG)_SOURCE)
endef

$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_TARGET_PRG:%=$($(PKG)_DIR)/scripts/kconfig/%): $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) -C $(KCONFIG_HOST_DIR) \
		HOSTPKG_CONFIG="pkgconf" \
		$(subst --$(notdir $@),,$(filter %--$(notdir $@),$(KCONFIG_HOST_TARGET_ALL)))

$(patsubst %,$($(PKG)_TARGET_DIR)/%,$($(PKG)_TARGET_PRG)): $($(PKG)_TARGET_DIR)/% : $($(PKG)_DIR)/scripts/kconfig/%
	$(INSTALL_FILE)
	@$(call _ECHO_DONE)

# hack for _BUILD_PREREQ of sub-bins
$(patsubst %,$(pkg)-%,$($(PKG)_TARGET_PRG)): $(pkg)-precompiled--int

$(patsubst %,$(pkg)-%,$($(PKG)_TARGET_PRG)): $(pkg)-% : $($(PKG)_TARGET_DIR)/%
$(pkg)-gconf: $(pkg)-gconf.glade

$(pkg)-precompiled: $(patsubst %,$($(PKG)_TARGET_DIR)/%,$($(PKG)_TARGET_DEF))


$(pkg)-clean:
	$(RM) \
		$(KCONFIG_HOST_DIR)/scripts/basic/.*.cmd \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/.*.cmd \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/lxdialog/.*.cmd \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/*.o \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/lxdialog/*.o \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/zconf.*.c \
		$(KCONFIG_HOST_DIR)/scripts/basic/fixdep \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/conf \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/gconf.glade \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/qconf \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/gconf \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/nconf \
		$(KCONFIG_HOST_DIR)/scripts/kconfig/mconf

$(pkg)-dirclean:
	$(RM) -r $(KCONFIG_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(KCONFIG_HOST_TARGET_DIR)/


.PHONY: $(pkg)-source $(pkg)-unpacked
.PHONY: $(pkg) $(pkg)-conf $(pkg)-mconf $(pkg)-nconf $(pkg)-gconf $(pkg)-qconf $(pkg)-gconf.glade
.PHONY: $(pkg)-clean $(pkg)-dirclean $(pkg)-distclean

$(TOOLS_FINISH)

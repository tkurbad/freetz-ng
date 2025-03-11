$(call TOOLS_INIT, 1.7.2)
$(PKG)_SOURCE:=dtc-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=92d8ca769805ae1f176204230438fe52808f4e1c7944053c9eec0e649b237539
$(PKG)_SITE:=@KERNEL/software/utils/dtc
### WEBSITE:=https://git.kernel.org/pub/scm/utils/dtc/dtc.git
### CHANGES:=https://git.kernel.org/pub/scm/utils/dtc/dtc.git/log/
### CVSREPO:=https://git.kernel.org/pub/scm/utils/dtc/dtc.git/refs/
### SUPPORT:=fda77

$(PKG)_INSTALL_DIR := $(TOOLS_DIR)/fit

$(PKG)_BINARIES            := dtc fdtdump fdtget fdtput fitdump
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_INSTALL_DIR)/%)


# dtc-host and dtc using the same source, libdtc-host an older version
$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(DTC_HOST_DIR) $(DTC_HOST_BINARIES)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_INSTALL_DIR)/%: $($(PKG)_DIR)/%
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(MAKE) -C $(DTC_HOST_DIR) clean
	-$(RM) $(DTC_HOST_DIR)/.{configured,compiled}

$(pkg)-dirclean:
	$(RM) -r $(DTC_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) \
		$(DTC_HOST_INSTALL_DIR)/dtc \
		$(DTC_HOST_INSTALL_DIR)/fdtget \
		$(DTC_HOST_INSTALL_DIR)/fdtdump \
		$(DTC_HOST_INSTALL_DIR)/fdtput \
		$(DTC_HOST_INSTALL_DIR)/mkimage \
		$(DTC_HOST_INSTALL_DIR)/fitdump

$(TOOLS_FINISH)

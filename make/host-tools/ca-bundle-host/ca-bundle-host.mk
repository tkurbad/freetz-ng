$(call TOOLS_INIT, 2024-07-02)
$(PKG)_SOURCE:=cacert-$($(PKG)_VERSION).pem
$(PKG)_HASH:=1bf458412568e134a4514f5e170a328d11091e071c7110955c9884ed87972ac9
$(PKG)_SITE:=https://www.curl.se/ca,https://curl.haxx.se/ca
### WEBSITE:=https://www.curl.se/ca
### SUPPORT:=fda77

$(PKG)_BINARY:=$(DL_DIR)/$($(PKG)_SOURCE)
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/cacert.pem


ifneq ($($(PKG)_SOURCE),$(WGET_HOST_SOURCE))
$(TOOLS_SOURCE_DOWNLOAD)
endif
$(TOOLS_UNPACKED)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:

$(pkg)-dirclean:

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(CA_BUNDLE_HOST_TARGET_BINARY)

$(TOOLS_FINISH)

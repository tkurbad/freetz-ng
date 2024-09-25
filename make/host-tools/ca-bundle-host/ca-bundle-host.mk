$(call TOOLS_INIT, 2024-09-24)
$(PKG)_SOURCE:=cacert-$($(PKG)_VERSION).pem
$(PKG)_HASH:=189d3cf6d103185fba06d76c1af915263c6d42225481a1759e853b33ac857540
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

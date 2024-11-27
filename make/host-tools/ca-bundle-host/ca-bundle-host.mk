$(call TOOLS_INIT, 2024-11-26)
$(PKG)_SOURCE:=cacert-$($(PKG)_VERSION).pem
$(PKG)_HASH:=bb1782d281fe60d4a2dcf41bc229abe3e46c280212597d4abcc25bddf667739b
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

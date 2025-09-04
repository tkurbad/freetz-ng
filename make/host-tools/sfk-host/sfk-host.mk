$(call TOOLS_INIT, 2.0.0.3)
$(PKG)_SOURCE_DOWNLOAD_NAME:=$(pkg_short)-$(call GET_MAJOR_VERSION,$($(PKG)_VERSION),3).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=b7e2e3848e3126dcee916056bff5f8340acae9158f3610049de2cde999ccca63
$(PKG)_SITE:=@SF/swissfileknife
### WEBSITE:=https://www.stahlworks.com/sfk
### MANPAGE:=https://www.stahlworks.com/dev/swiss-file-knife.html
### CHANGES:=https://sourceforge.net/p/swissfileknife/news/
### CVSREPO:=https://sourceforge.net/projects/swissfileknife/files/1-swissfileknife/
### SUPPORT:=fda77

$(PKG)_CONFIGURE_OPTIONS += --prefix=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)

$(PKG)_CXXFLAGS := $(TOOLS_CFLAGS)
$(PKG)_CXXFLAGS += -w


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/sfk: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(SFK_HOST_DIR) \
		CXXFLAGS="$(SFK_HOST_CXXFLAGS)" \
		all

$(TOOLS_DIR)/sfk: $($(PKG)_DIR)/sfk
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/sfk


$(pkg)-clean:
	-$(MAKE) -C $(SFK_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(SFK_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/sfk

$(TOOLS_FINISH)

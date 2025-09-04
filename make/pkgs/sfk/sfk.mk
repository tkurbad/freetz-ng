$(call PKG_INIT_BIN, 2.0.0.3)
$(PKG)_SOURCE_DOWNLOAD_NAME:=$(pkg)-$(call GET_MAJOR_VERSION,$($(PKG)_VERSION),3).tar.gz
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=b7e2e3848e3126dcee916056bff5f8340acae9158f3610049de2cde999ccca63
$(PKG)_SITE:=@SF/swissfileknife
### WEBSITE:=https://www.stahlworks.com/sfk
### MANPAGE:=https://www.stahlworks.com/dev/swiss-file-knife.html
### CHANGES:=https://sourceforge.net/p/swissfileknife/news/
### CVSREPO:=https://sourceforge.net/projects/swissfileknife/files/1-swissfileknife/
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/sfk
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sfk

$(PKG)_DEPENDS_ON += $(STDCXXLIB)
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_EXTRA_CXXFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_CXXFLAGS  += -w
$(PKG)_EXTRA_LDFLAGS   += -Wl,--gc-sections

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SFK_STATIC
$(PKG)_EXTRA_LDFLAGS   += $(if $(FREETZ_PACKAGE_SFK_STATIC),-static)


ifneq ($(strip $(DL_DIR)/$($(PKG)_SOURCE)), $(strip $(DL_DIR)/$($(PKG)_HOST_SOURCE)))
$(PKG_SOURCE_DOWNLOAD)
endif
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SFK_DIR) \
		EXTRA_CXXFLAGS="$(SFK_EXTRA_CXXFLAGS)" \
		EXTRA_LDFLAGS="$(SFK_EXTRA_LDFLAGS)"

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(SFK_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SFK_TARGET_BINARY)

$(PKG_FINISH)

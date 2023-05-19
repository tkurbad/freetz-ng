$(call PKG_INIT_BIN, 1.9.8)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=051e6b81d9da348f19de906b6696882978d8b2c360b01d5447c5d4664aefe40c
$(PKG)_SITE:=@SF/swissfileknife
### VERSION:=1.9.8.2
### WEBSITE:=http://stahlworks.com/dev/swiss-file-knife.html
### CHANGES:=http://stahlworks.com/dev/?tool=sfkver

$(PKG)_BINARY:=$($(PKG)_DIR)/sfk
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sfk

$(PKG)_DEPENDS_ON += $(STDCXXLIB)
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_EXTRA_CXXFLAGS  += -ffunction-sections -fdata-sections
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

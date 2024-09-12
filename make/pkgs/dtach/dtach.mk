$(call PKG_INIT_BIN, 0.9)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=32e9fd6923c553c443fab4ec9c1f95d83fa47b771e6e1dafb018c567291492f3
$(PKG)_SITE:=@SF/dtach
### WEBSITE:=https://dtach.sourceforge.net/
### CHANGES:=https://github.com/crigler/dtach/tags
### CVSREPO:=https://github.com/crigler/dtach

$(PKG)_BINARY:=$($(PKG)_DIR)/dtach
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/dtach


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DTACH_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(DTACH_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DTACH_TARGET_BINARY)

$(PKG_FINISH)

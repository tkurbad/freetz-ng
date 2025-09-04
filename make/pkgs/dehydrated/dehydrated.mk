$(call PKG_INIT_BIN, 0.7.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=7ea5a75bfcdf04bbb6ef88d03f89dec8101a2d3ea1dd467d8c42cbb0339ed5cb
$(PKG)_SITE:=https://github.com/dehydrated-io/dehydrated/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://dehydrated.io/
### MANPAGE:=https://github.com/dehydrated-io/dehydrated/wiki
### CHANGES:=https://github.com/dehydrated-io/dehydrated/releases
### CVSREPO:=https://github.com/dehydrated-io/dehydrated/commits/master
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/dehydrated
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/dehydrated


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(DEHYDRATED_TARGET_BINARY)

$(PKG_FINISH)

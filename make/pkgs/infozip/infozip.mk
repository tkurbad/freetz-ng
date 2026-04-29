$(call PKG_INIT_BIN, 3.0)
$(PKG)_SOURCE_DOWNLOAD_NAME:=zip30.tar.gz
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=f0e8bb1f9b7eb0b01285495a2699df3a4b766784c1765a8f1aeedf63c0806369
$(PKG)_SITE:=@SF/infozip
### WEBSITE:=https://infozip.sourceforge.net/Zip.html
### MANPAGE:=https://infozip.sourceforge.net/FAQ.html
### CHANGES:=https://infozip.sourceforge.net/Zip.html#Release
### CVSREPO:=https://sourceforge.net/projects/infozip/
### STEWARD:=Ircama

$(PKG)_BINARY_BUILD := $($(PKG)_DIR)/zip
$(PKG)_BINARY_TARGET := $($(PKG)_DEST_DIR)/usr/bin/zip


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY_BUILD): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(INFOZIP_DIR) -f unix/Makefile \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		generic

$($(PKG)_BINARY_TARGET): $($(PKG)_BINARY_BUILD)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET)


$(pkg)-clean:
	-$(SUBMAKE) -C $(INFOZIP_DIR) -f unix/Makefile clean

$(pkg)-uninstall:
	$(RM) $(INFOZIP_BINARY_TARGET)

$(PKG_FINISH)

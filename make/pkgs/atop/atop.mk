$(call PKG_INIT_BIN, 2.11.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=9b94c666602efff7bf402ecce706c347f38c39cb63498f9d39626861e5646e20
$(PKG)_SITE:=https://www.atoptool.nl/download
### WEBSITE:=https://www.atoptool.nl/
### MANPAGE:=https://linux.die.net/man/1/atop
### CHANGES:=https://www.atoptool.nl/downloadatop.php
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/atop
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/atop

$(PKG)_DEPENDS_ON += zlib ncursesw glib2

$(PKG)_EXTRA_CFLAGS := -I.
$(PKG)_EXTRA_CFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/glib-2.0
$(PKG)_EXTRA_CFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/glib-2.0/include


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ATOP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(ATOP_EXTRA_CFLAGS) -Wall" \
		atop

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(ATOP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(ATOP_TARGET_BINARY)

$(PKG_FINISH)

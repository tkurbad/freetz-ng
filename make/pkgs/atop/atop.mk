$(call PKG_INIT_BIN, 2.12.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=4fdbe67c5dfaf89405639e18599f4eae77978073ffa54f3c78c368ab54bd12f6
$(PKG)_SITE:=https://www.atoptool.nl/download
### WEBSITE:=https://www.atoptool.nl/
### MANPAGE:=https://linux.die.net/man/1/atop
### CHANGES:=https://www.atoptool.nl/downloadatop.php
### CVSREPO:=https://github.com/Atoptool/atop
### STEWARD:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/atop
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/atop

$(PKG)_DEPENDS_ON += zlib ncursesw glib2

$(PKG)_PATCH_POST_CMDS += $(SED) -i -r -e 's,^($(_hash)define _POSIX_C_SOURCE)[ \t]*,\1 1,g' ./*.c;

$(PKG)_CFLAGS := $(TARGET_CFLAGS)
$(PKG)_CFLAGS += -I.
$(PKG)_CFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/glib-2.0
$(PKG)_CFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/glib-2.0/include
$(PKG)_CFLAGS += -Wall

$(PKG)_LDFLAGS := $(TARGET_LDFLAGS)
$(PKG)_LDFLAGS += -lglib-2.0
$(PKG)_LDFLAGS += -L$(TARGET_TOOLCHAIN_STAGING_DIR)/lib


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ATOP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(ATOP_CFLAGS)" \
		LDFLAGS="$(ATOP_LDFLAGS)" \
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

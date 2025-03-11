$(call PKG_INIT_BIN, 2.10)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=90e7ce2856b3eaaa3f452354d17981c49d32c426a255b6f0d3063a227c101538
$(PKG)_SITE:=https://salsa.debian.org/minicom-team/minicom/-/archive/$($(PKG)_VERSION)
### WEBSITE:=https://salsa.debian.org/minicom-team/minicom
### MANPAGE:=https://linux.die.net/man/1/minicom
### CHANGES:=https://salsa.debian.org/minicom-team/minicom/-/releases
### CVSREPO:=https://salsa.debian.org/minicom-team/minicom/-/commits/master/
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/src/minicom
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/minicom

$(PKG)_DEPENDS_ON += ncurses
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MINICOM_PORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MINICOM_BAUD

$(PKG)_CONFIGURE_OPTIONS += --enable-cfg-dir=/var/tmp/flash/minicom/
$(PKG)_CONFIGURE_OPTIONS += --enable-dfl-port=$(FREETZ_PACKAGE_MINICOM_PORT)
$(PKG)_CONFIGURE_OPTIONS += --enable-dfl-baud=$(FREETZ_PACKAGE_MINICOM_BAUD)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MINICOM_DIR) \
		ICONVLIB="$(if $(FREETZ_TARGET_UCLIBC_0_9_28),-liconv)" \
		AM_CFLAGS=""

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(MINICOM_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MINICOM_TARGET_BINARY)

$(PKG_FINISH)


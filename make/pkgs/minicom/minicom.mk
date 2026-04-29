$(call PKG_INIT_BIN, 2.11.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=87cf0da91af0531357cd61b8e1906b907edd2c9ef82f9ae74c277e1893d0f98c
$(PKG)_SITE:=https://salsa.debian.org/minicom-team/minicom/-/archive/$($(PKG)_VERSION)
### WEBSITE:=https://salsa.debian.org/minicom-team/minicom
### MANPAGE:=https://linux.die.net/man/1/minicom
### CHANGES:=https://salsa.debian.org/minicom-team/minicom/-/releases
### CVSREPO:=https://salsa.debian.org/minicom-team/minicom/-/commits/master/
### STEWARD:=fda77

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


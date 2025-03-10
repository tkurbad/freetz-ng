$(call PKG_INIT_BIN, 1.4.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=1973c7732f1f9f0a4c0ccf2c1ce462c7c25060b25643ea90f9b98f53a813faec
$(PKG)_SITE:=https://www.inet.no/dante/files
### WEBSITE:=https://www.inet.no/dante/
### MANPAGE:=https://www.inet.no/dante/doc/1.4.x/index.html
### CHANGES:=https://www.inet.no/dante/index.html#Recent
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/sockd/sockd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/danted

$(PKG)_CONFIGURE_PRE_CMDS += autoreconf -i;

$(PKG)_CONFIGURE_OPTIONS += --with-libc=libc.so
$(PKG)_CONFIGURE_OPTIONS += --without-bsdauth
$(PKG)_CONFIGURE_OPTIONS += --without-gssapi
$(PKG)_CONFIGURE_OPTIONS += --without-glibc-secure
$(PKG)_CONFIGURE_OPTIONS += --without-sasl
$(PKG)_CONFIGURE_OPTIONS += --without-ldap
$(PKG)_CONFIGURE_OPTIONS += --without-upnp
$(PKG)_CONFIGURE_OPTIONS += --without-libwrap
$(PKG)_CONFIGURE_OPTIONS += --without-pam


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DANTE_DIR) all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(DANTE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DANTE_TARGET_BINARY)

$(PKG_FINISH)

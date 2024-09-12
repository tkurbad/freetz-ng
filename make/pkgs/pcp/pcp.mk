$(call PKG_INIT_BIN, 1c783fb)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=2c9efc85dee088394ab5fdc2303a0676a47288dbad0e25766a091771101bd7d6
$(PKG)_SITE:=git@https://github.com/libpcp/pcp.git
### MANPAGE:=https://github.com/libpcp/pcp/tree/master/pcp_app#readme
### CHANGES:=https://github.com/libpcp/pcp/commits/master/
### CVSREPO:=https://github.com/libpcp/pcp/
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/pcp_app/pcp
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/pcp

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_PRE_CMDS += ./autogen.sh;

$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-prof
$(PKG)_CONFIGURE_OPTIONS += --disable-gcov
$(PKG)_CONFIGURE_OPTIONS += --enable-app
$(PKG)_CONFIGURE_OPTIONS += --disable-server
$(PKG)_CONFIGURE_OPTIONS += --enable-natpmp
#$(PKG)_CONFIGURE_OPTIONS += --enable-flow-priority
#$(PKG)_CONFIGURE_OPTIONS += --enable-learn-dscp
#$(PKG)_CONFIGURE_OPTIONS += --enable-experimental
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)



$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PCP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(PCP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PCP_DEST_DIR)/usr/bin/pcp

$(PKG_FINISH)

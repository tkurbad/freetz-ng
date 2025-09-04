$(call PKG_INIT_LIB, 2.7.1)
$(PKG)_LIB_VERSION:=1.10.2
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=354552544b8f99012e5062f7d570ec77f14b412a3ff5c7d8d0dae62c0d217c30
$(PKG)_SITE:=@SF/expat,https://github.com/libexpat/libexpat/releases/download/R_$(subst .,_,$($(PKG)_VERSION))
### WEBSITE:=https://libexpat.github.io/
### MANPAGE:=https://libexpat.github.io/doc/
### CHANGES:=https://github.com/libexpat/libexpat/blob/master/expat/Changes
### CVSREPO:=https://github.com/libexpat/libexpat

$(PKG)_BINARY:=$($(PKG)_DIR)/lib/.libs/libexpat.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libexpat.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libexpat.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --without-xmlwf
$(PKG)_CONFIGURE_OPTIONS += --without-examples
$(PKG)_CONFIGURE_OPTIONS += --without-tests


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(EXPAT_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(EXPAT_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libexpat.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/expat.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(EXPAT_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libexpat.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/expat.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/expat*.h

$(pkg)-uninstall:
	$(RM) $(EXPAT_TARGET_DIR)/libexpat*.so*

$(PKG_FINISH)

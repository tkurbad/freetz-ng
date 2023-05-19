$(call PKG_INIT_LIB, 9d)
$(PKG)_LIB_VERSION:=9.4.0
$(PKG)_SOURCE:=jpegsrc.v$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=ad7e40dedc268f97c44e7ee3cd54548a
$(PKG)_SITE:=http://ijg.org/files

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libjpeg.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libjpeg.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(JPEG_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(JPEG_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-libLTLIBRARIES install-includeHEADERS install-data-local
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(JPEG_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg*

$(pkg)-uninstall:
	$(RM) $(JPEG_TARGET_DIR)/libjpeg*.so*

$(PKG_FINISH)

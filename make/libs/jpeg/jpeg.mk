$(call PKG_INIT_LIB, 9f)
$(PKG)_LIB_VERSION:=9.6.0
$(PKG)_SOURCE:=jpegsrc.v$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=04705c110cb2469caa79fb71fba3d7bf834914706e9641a4589485c1f832565b
$(PKG)_SITE:=https://www.ijg.org/files
### WEBSITE:=https://www.ijg.org/
### MANPAGE:=http://www.faqs.org/faqs/jpeg-faq/

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

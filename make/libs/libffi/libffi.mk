$(call PKG_INIT_LIB, 3.7.1)
$(PKG)_LIB_VERSION:=8.4.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=d5e9a6638ddbd2513ddb54518eb67e4bbe6fa707bcc01c10f6212f0a088d819d
$(PKG)_SITE:=https://github.com/libffi/libffi/releases/download/v$($(PKG)_VERSION),ftp://sourceware.org/pub/libffi
### WEBSITE:=http://sourceware.org/libffi
### CHANGES:=https://github.com/libffi/libffi/releases
### CVSREPO:=https://github.com/libffi/libffi

$(PKG)_BINARY:=$($(PKG)_DIR)/$(FREETZ_TARGET_ARCH_ENDIANNESS_DEPENDENT)-$(FREETZ_TARGET_TRIPLET_VENDOR)-linux-gnu/.libs/libffi.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libffi.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += wget-host

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-docs
$(PKG)_CONFIGURE_OPTIONS += --disable-debug


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

#$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBFFI_DIR) all-recursive
	touch $@

#$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
$($(PKG)_STAGING_BINARY): $($(PKG)_DIR)/.compiled
	$(SUBMAKE) -C $(LIBFFI_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libffi.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBFFI_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/{ffi.h,ffitarget.h} \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libffi.pc

$(pkg)-uninstall:
	$(RM) $(LIBFFI_TARGET_DIR)/libffi*.so*

$(PKG_FINISH)

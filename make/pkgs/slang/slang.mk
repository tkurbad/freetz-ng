$(call PKG_INIT_BIN, 2.3.3)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=f9145054ae131973c61208ea82486d5dd10e3c5cdad23b7c4a0617743c8f5a18
$(PKG)_SITE:=http://www.jedsoft.org/releases/slang
### WEBSITE:=https://www.jedsoft.org/slang/
### MANPAGE:=https://www.jedsoft.org/slang/docs.html
### CHANGES:=https://www.jedsoft.org/releases/slang/
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/src/elfobjs/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/lib$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_MODULES_DIR:=$(FREETZ_LIBRARY_DIR)/$(pkg)
$(PKG)_MODULES:=csv fcntl fork iconv pcre rand select slsmg socket sysconf termios varray zlib
$(PKG)_MODULES_LONG:=$($(PKG)_MODULES:%=%-module.so)
$(PKG)_MODULES_STAGING_DIR:=$($(PKG)_MODULES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)$($(PKG)_MODULES_DIR)/%)
$(PKG)_MODULES_TARGET_DIR:=$($(PKG)_MODULES_LONG:%=$($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/%)

$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_SLANG_MODULES),,$($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR))

$(PKG)_DEPENDS_ON += pcre zlib
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
endif

$(PKG)_CONFIGURE_OPTIONS += --without-onig
$(PKG)_CONFIGURE_OPTIONS += --with-pcre="$(TARGET_TOOLCHAIN_STAGING_DIR)"
$(PKG)_CONFIGURE_OPTIONS += --with-z="$(TARGET_TOOLCHAIN_STAGING_DIR)"
$(PKG)_CONFIGURE_OPTIONS += --without-png
$(PKG)_CONFIGURE_OPTIONS += --with-readline=slang

$(PKG)_MAKE_PARAMS += MODULE_INSTALL_DIR="$(SLANG_MODULES_DIR)" STRIPPROG="$(TARGET_STRIP)"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(SLANG_DIR) $(SLANG_MAKE_PARAMS)

$($(PKG)_STAGING_BINARY) $($(PKG)_MODULES_STAGING_DIR): $($(PKG)_BINARY)
	$(SUBMAKE1) -C $(SLANG_DIR) $(SLANG_MAKE_PARAMS) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(call PKG_FIX_LIBTOOL_LA,prefix libdir includedir) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/slang.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

ifeq ($(strip $(FREETZ_PACKAGE_SLANG_MODULES)),y)
$($(PKG)_MODULES_TARGET_DIR): $($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)$($(PKG)_MODULES_DIR)/%
	$(INSTALL_BINARY_STRIP)
endif

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $(if $(FREETZ_PACKAGE_SLANG_MODULES),$($(PKG)_MODULES_TARGET_DIR))


$(pkg)-clean:
	-$(SUBMAKE) -C $(SLANG_DIR) $(SLANG_MAKE_PARAMS) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libslang* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)$(SLANG_MODULES_DIR) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/{slang,slcurses}.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/slang.pc

$(pkg)-uninstall:
	$(RM) -r $(SLANG_TARGET_LIBDIR)/libslang*.so* $(SLANG_DEST_DIR)$(SLANG_MODULES_DIR)

$(call PKG_ADD_LIB,libslang)
$(PKG_FINISH)

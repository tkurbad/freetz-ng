$(call PKG_INIT_BIN, 1.0.8)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ab5a03176ee106d3f0fa90e381da478ddae405918153cca248e682cd0c4a2269
$(PKG)_SITE:=https://sourceware.org/pub/bzip2
### WEBSITE:=https://sourceware.org/bzip2/
### MANPAGE:=https://sourceware.org/bzip2/docs.html
### CHANGES:=https://sourceware.org/bzip2/CHANGES
### CVSREPO:=https://sourceware.org/git/bzip2.git

$(PKG)_BINARY:=$($(PKG)_DIR)/$(if $(FREETZ_PACKAGE_BZIP2_STATIC),bzip2,bzip2-shared)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/bzip2

$(PKG)_ARCHIVE:=$($(PKG)_DIR)/libbz2.a
$(PKG)_STAGING_ARCHIVE:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbz2.a

$(PKG)_LIBRARY:=$($(PKG)_DIR)/libbz2.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_LIBRARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbz2.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_LIBRARY:=$($(PKG)_TARGET_LIBDIR)/libbz2.so.$($(PKG)_LIB_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_BZIP2_STATIC

$(PKG)_MAKE_VARS += CC="$(TARGET_CC)"
$(PKG)_MAKE_VARS += AR="$(TARGET_AR)"
$(PKG)_MAKE_VARS += RANLIB="$(TARGET_RANLIB)"
$(PKG)_MAKE_VARS += CFLAGS="$(TARGET_CFLAGS) -fPIC -D_FILE_OFFSET_BITS=64"
$(PKG)_MAKE_VARS += LDFLAGS="$(TARGET_LDFLAGS)"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_ARCHIVE): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BZIP2_DIR) \
		$(BZIP2_MAKE_VARS) \
		libbz2.a bzip2

$($(PKG)_BINARY) $($(PKG)_LIBRARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BZIP2_DIR) \
		$(BZIP2_MAKE_VARS) \
		-f Makefile-libbz2_so

$($(PKG)_DIR)/.compiled: $($(PKG)_ARCHIVE) $($(PKG)_BINARY) $($(PKG)_LIBRARY)
	@touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.compiled
	@mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
	@mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include
	cp -a $(BZIP2_DIR)/{libbz2.a,libbz2.so*} $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	cp -a $(BZIP2_DIR)/{bzlib_private.h,bzlib.h} $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/
	@touch $@

$($(PKG)_STAGING_LIBRARY): $($(PKG)_DIR)/.installed

$($(PKG)_TARGET_LIBRARY): $($(PKG)_STAGING_LIBRARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg): $($(PKG)_STAGING_LIBRARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_LIBRARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(BZIP2_DIR) clean
	$(RM) $(BZIP2_DIR)/{.configured,.compiled,.installed}
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbz2.so* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbz2.a \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/bzlib.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/bzlib_private.h

$(pkg)-uninstall:
	$(RM) $(BZIP2_TARGET_BINARY) $(BZIP2_TARGET_LIBDIR)/libbz2.so*

$(call PKG_ADD_LIB,libbz2)
$(PKG_FINISH)

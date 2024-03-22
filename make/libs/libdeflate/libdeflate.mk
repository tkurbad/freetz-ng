$(call PKG_INIT_LIB, 1.19)
$(PKG)_SHLIB_VERSION:=0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=d9bb9bdd8cc5a8c1f7f6226fa0053dd72861e15f366e7ff7d0d191eac16d66f3
$(PKG)_SITE:=https://github.com/ebiggers/libdeflate/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://github.com/ebiggers/libdeflate#readme
### MANPAGE:=https://github.com/ebiggers/libdeflate/blob/master/NEWS.md
### CHANGES:=https://github.com/ebiggers/libdeflate/releases
### CVSREPO:=https://github.com/ebiggers/libdeflate

$(PKG)_LIBNAME=$(pkg).so.$($(PKG)_SHLIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_DEPENDS_ON += cmake-host

$(PKG)_CONFIGURE_OPTIONS += -DCMAKE_INSTALL_PREFIX="/"
$(PKG)_CONFIGURE_OPTIONS += -DCMAKE_SKIP_INSTALL_RPATH=NO
$(PKG)_CONFIGURE_OPTIONS += -DCMAKE_SKIP_RPATH=NO

$(PKG)_CONFIGURE_OPTIONS += -DLIBDEFLATE_BUILD_SHARED_LIB=ON
$(PKG)_CONFIGURE_OPTIONS += -DLIBDEFLATE_BUILD_STATIC_LIB=ON
$(PKG)_CONFIGURE_OPTIONS += -DCMAKE_BUILD_TYPE=Release

$(PKG)_CONFIGURE_OPTIONS += -DLIBDEFLATE_BUILD_TESTS=OFF
$(PKG)_CONFIGURE_OPTIONS += -DLIBDEFLATE_BUILD_GZIP=ON
$(PKG)_CONFIGURE_OPTIONS += -DLIBDEFLATE_COMPRESSION_SUPPORT=ON
$(PKG)_CONFIGURE_OPTIONS += -DLIBDEFLATE_DECOMPRESSION_SUPPORT=ON
$(PKG)_CONFIGURE_OPTIONS += -DLIBDEFLATE_GZIP_SUPPORT=ON
$(PKG)_CONFIGURE_OPTIONS += -DLIBDEFLATE_ZLIB_SUPPORT=ON
$(PKG)_CONFIGURE_OPTIONS += -DLIBDEFLATE_FREESTANDING=OFF
$(PKG)_CONFIGURE_OPTIONS += -DLIBDEFLATE_USE_SHARED_LIB=OFF


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CMAKE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBDEFLATE_DIR)
#cmake	cd $(GETDNS_DIR) && cmake -LA .

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBDEFLATE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libdeflate.pc
#		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdeflate.la
	@touch $@

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBDEFLATE_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdeflate.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libdeflate.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libdeflate.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/cmake/libdeflate/

$(pkg)-uninstall:
	$(RM) $(LIBDEFLATE_TARGET_DIR)/libdeflate.so*

$(PKG_FINISH)

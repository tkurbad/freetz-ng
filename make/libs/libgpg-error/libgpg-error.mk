$(call PKG_INIT_LIB, 1.47)
$(PKG)_LIB_VERSION:=0.34.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=9e3c670966b96ecc746c28c2c419541e3bcb787d1a73930f5e5f5e1bcbbb9bdb
$(PKG)_SITE:=https://gnupg.org/ftp/gcrypt/libgpg-error,ftp://ftp.gnupg.org/gcrypt/libgpg-error
### WEBSITE:=https://gnupg.org/software/libgpg-error/
### CHANGES:=https://git.gnupg.org/cgi-bin/gitweb.cgi?p=libgpg-error.git;a=blob;f=NEWS
### CVSREPO:=https://git.gnupg.org/cgi-bin/gitweb.cgi?p=libgpg-error.git

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_PATCH_POST_CMDS += $(if $(TARGET_TRIPLET_GNU_ABI),(cd src/syscfg; ln -s lock-obj-pub.$(TARGET_GNU_TRIPLET).h lock-obj-pub.$(subst gnu$(TARGET_TRIPLET_GNU_ABI),gnu,$(TARGET_GNU_TRIPLET)).h);)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-install-gpg-error-config


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBGPG_ERROR_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBGPG_ERROR_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/gpg-error-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBGPG_ERROR_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/gpg-error* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/gpg-error* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/gpg-error* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/common-lisp/source/gpg-error*

$(pkg)-uninstall:
	$(RM) $(LIBGPG_ERROR_TARGET_DIR)/libgpg-error*.so*

$(PKG_FINISH)


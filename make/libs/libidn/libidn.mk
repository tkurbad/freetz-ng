$(call PKG_INIT_LIB, 1.42)
$(PKG)_LIB_VERSION:=12.6.5
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=d6c199dcd806e4fe279360cb4b08349a0d39560ed548ffd1ccadda8cdecb4723
$(PKG)_SITE:=@GNU/$(pkg)
### WEBSITE:=https://www.gnu.org/software/libidn/
### MANPAGE:=https://www.gnu.org/software/libidn/manual/libidn.html
### CHANGES:=https://git.savannah.gnu.org/gitweb/?p=libidn.git;a=blob_plain;f=NEWS;hb=HEAD
### CVSREPO:=https://git.savannah.gnu.org/gitweb/?p=libidn.git

$(PKG)_LIBNAME_SHORT := $(pkg)
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBIDN_DIR) all
	@touch $@

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBIDN_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(LIBIDN_LIBNAME_SHORT).la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBIDN_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/$(LIBIDN_LIBNAME_SHORT)*

$(pkg)-uninstall:
	$(RM) $(LIBIDN_TARGET_DIR)/$(LIBIDN_LIBNAME_SHORT).so*

$(PKG_FINISH)

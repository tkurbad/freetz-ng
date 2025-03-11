$(call TOOLS_INIT, 1.25.0)
$(PKG)_SOURCE:=wget-$($(PKG)_VERSION).tar.lz
$(PKG)_HASH:=19225cc756b0a088fc81148dc6a40a0c8f329af7fd8483f1c7b2fe50f4e08a1f
$(PKG)_SITE:=@GNU/wget
### WEBSITE:=https://www.gnu.org/software/wget/
### MANPAGE:=https://www.gnu.org/software/wget/manual/
### CHANGES:=https://git.savannah.gnu.org/cgit/wget.git/tree/NEWS
### CVSREPO:=https://git.savannah.gnu.org/cgit/wget.git/
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/src/wget
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/wget

$(PKG)_DEPENDS_ON+=patchelf-host
$(PKG)_DEPENDS_ON+=openssl-host
$(PKG)_DEPENDS_ON+=ca-bundle-host

$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-iri
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre2
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-libuuid
$(PKG)_CONFIGURE_OPTIONS += --without-libpsl
$(PKG)_CONFIGURE_OPTIONS += --without-zlib
$(PKG)_CONFIGURE_OPTIONS += --with-included-libunistring
$(PKG)_CONFIGURE_OPTIONS += --without-libgnutls-prefix
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=openssl

$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(OPENSSL_HOST_INSTALLDIR)/lib/pkgconfig/"


ifneq ($($(PKG)_SOURCE),$(WGET_HOST_SOURCE))
$(TOOLS_SOURCE_DOWNLOAD)
endif
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(WGET_HOST_DIR) all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$($(PKG)_DIR)/.installed: $($(PKG)_TARGET_BINARY)
	$(call WGET_HOST_FIXHARDCODED)
	@touch $@

define $(PKG)_FIXHARDCODED
	@for libfile in libcrypto libssl; do \
	$(PATCHELF) --replace-needed $(1)$${libfile}.so.3 $(OPENSSL_HOST_DESTDIR)/$${libfile}.so.3 $(WGET_HOST_TARGET_BINARY) ;\
	done ;
endef

$(pkg)-fixhardcoded:
	$(call WGET_HOST_FIXHARDCODED,$(TOOLS_HARDCODED_DIR)/freetz/)

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:
	-$(MAKE) -C $(WGET_HOST_DIR) clean
	$(RM) $(WGET_HOST_DIR)/.{configured,compiled,installed,fixhardcoded}

$(pkg)-dirclean:
	$(RM) -r $(WGET_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(WGET_HOST_TARGET_BINARY)

$(TOOLS_FINISH)

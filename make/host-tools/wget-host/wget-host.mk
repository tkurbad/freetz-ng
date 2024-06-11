$(call TOOLS_INIT, 1.24.5)
$(PKG)_SOURCE:=wget-$($(PKG)_VERSION).tar.lz
$(PKG)_HASH:=57a107151e4ef94fdf94affecfac598963f372f13293ed9c74032105390b36ee
$(PKG)_SITE:=@GNU/wget
### WEBSITE:=https://www.gnu.org/software/wget/
### MANPAGE:=https://www.gnu.org/software/wget/manual/
### CHANGES:=https://git.savannah.gnu.org/cgit/wget.git/tree/NEWS
### CVSREPO:=https://git.savannah.gnu.org/cgit/wget.git/

$(PKG)_BINARY:=$($(PKG)_DIR)/src/wget
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/wget

$(PKG)_DEPENDS_ON+=$(if $(FREETZ_TOOLS_WGET_STATIC),openssl-host)
$(PKG)_DEPENDS_ON+=ca-bundle-host

$(PKG)_REBUILD_SUBOPTS += FREETZ_TOOLS_WGET_STATIC

$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-iri
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre2
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-libuuid
$(PKG)_CONFIGURE_OPTIONS += --without-libpsl
$(PKG)_CONFIGURE_OPTIONS += --without-zlib

ifeq ($(strip $(FREETZ_TOOLS_WGET_STATIC)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-included-libunistring
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=openssl
$(PKG)_CONFIGURE_OPTIONS += --without-libgnutls-prefix
$(PKG)_CONFIGURE_ENV += OPENSSL_CFLAGS="-I$(OPENSSL_HOST_DIR)/include"
$(PKG)_CONFIGURE_ENV += OPENSSL_LIBS="-L$(OPENSSL_HOST_DIR)  -Wl,-Bstatic -l:libssl.a -l:libcrypto.a  -Wl,-Bdynamic -ldl -pthread"
#$(PKG)_CONFIGURE_ENV += LDFLAGS="-static  -lssl -lcrypto"
endif


ifneq ($($(PKG)_SOURCE),$(WGET_HOST_SOURCE))
$(TOOLS_SOURCE_DOWNLOAD)
endif
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(WGET_HOST_DIR) \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(WGET_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(WGET_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(WGET_HOST_TARGET_BINARY)

$(TOOLS_FINISH)

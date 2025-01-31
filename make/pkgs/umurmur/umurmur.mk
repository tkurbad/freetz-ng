$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_UMURMUR_VERSION_ABANDON),0.2.20,0.3.0))
$(PKG)_SOURCE_DOWNLOAD_NAME:=$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=b7b2978c3197aef0a6531f1cf0ee1aebb32a55ad8bda43064ce3a944edbcac83
$(PKG)_HASH_CURRENT:=6c055e8893a87b9291e87de5e1e8e5c1d16c172a4aba6faec5a1b59dadca05d8
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_UMURMUR_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://github.com/umurmur/umurmur/archive/refs/tags
### WEBSITE:=https://umurmur.net/
### MANPAGE:=https://github.com/umurmur/umurmur/wiki
### CHANGES:=https://github.com/umurmur/umurmur/releases
### CVSREPO:=https://github.com/umurmur/umurmur
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)d
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)d

$(PKG)_CONFIGURE_PRE_CMDS += ./autogen.sh;

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_UMURMUR_VERSION_ABANDON),abandon,current)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_UMURMUR_VERSION_ABANDON
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_UMURMUR_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_UMURMUR_MBEDTLS

$(PKG)_DEPENDS_ON += libconfig protobuf-c
ifeq ($(strip $(FREETZ_PACKAGE_UMURMUR_OPENSSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=openssl
endif
ifeq ($(strip $(FREETZ_PACKAGE_UMURMUR_MBEDTLS)),y)
$(PKG)_DEPENDS_ON += mbedtls
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=mbedtls
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UMURMUR_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(UMURMUR_DIR) clean
	$(RM) $(UMURMUR_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(UMURMUR_TARGET_BINARY)

$(PKG_FINISH)

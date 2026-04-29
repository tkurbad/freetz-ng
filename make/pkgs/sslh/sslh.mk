$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_SSLH_VERSION_ABANDON),2.2.4,2.3.1))
$(PKG)_SOURCE:=$(pkg)-v$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=696edac467111d0c1353a4ff32ed8dfa33bc914036644c69a7b9506b7ee49115
$(PKG)_HASH_CURRENT:=51a5516ec5cb01823633b4d8cacdeee4efa0c56ef620d1c996d4f52ca51a601b
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_SSLH_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://www.rutschle.net/tech/sslh
### WEBSITE:=https://www.rutschle.net/tech/sslh/README.html
### MANPAGE:=https://www.rutschle.net/tech/sslh/doc/config
### CHANGES:=https://github.com/yrutschle/sslh/tags
### CVSREPO:=https://github.com/yrutschle/sslh
### STEWARD:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/sslh-fork
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/sslh

$(PKG)_DEPENDS_ON += libconfig pcre2

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_SSLH_VERSION_ABANDON),abandon,current)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SSLH_VERSION_ABANDON


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SSLH_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		sslh-fork

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(SSLH_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SSLH_TARGET_BINARY)

$(PKG_FINISH)


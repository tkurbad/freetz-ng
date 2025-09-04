$(call PKG_INIT_BIN, 2.7a1)
$(PKG)_SOURCE:=pycrypto-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ee4013e297e6a5da5c9f49a3e38dc8a5c62ae816377aa766c9e87474197be3b9
$(PKG)_SITE:=https://www.pycrypto.org/pub/dlitz/crypto/pycrypto/,https://ftp.dlitz.net/pub/dlitz/crypto/pycrypto
### WEBSITE:=https://www.pycrypto.org/
### MANPAGE:=https://www.pycrypto.org/doc/
### CHANGES:=https://github.com/pycrypto/pycrypto/tags
### CVSREPO:=https://github.com/pycrypto/pycrypto
### SUPPORT:=X

$(PKG)_DEPENDS_ON += python gmp
$(PKG)_DEPENDS_ON += python2-host

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_PYCRYPTO, , TARGET_ARCH_BE="$(TARGET_ARCH_BE)")
	@touch $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_DIR)/.compiled


$(pkg)-clean:
	$(RM) $(PYTHON_PYCRYPTO_DIR)/{.configured,.compiled}
	$(RM) -r $(PYTHON_PYCRYPTO_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYCRYPTO_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Crypto \
		$(PYTHON_PYCRYPTO_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pycrypto-*.egg-info

$(PKG_FINISH)

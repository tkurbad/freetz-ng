$(call PKG_INIT_BIN, 3.23.0)
$(PKG)_SOURCE:=pycryptodome-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=https://files.pythonhosted.org/packages/source/p/pycryptodome
$(PKG)_HASH:=447700a657182d60338bab09fdb27518f8856aecd80ae4c6bdddb67ff5da44ef
### WEBSITE:=https://www.pycryptodome.org/
### MANPAGE:=https://www.pycryptodome.org/src/api
### CHANGES:=https://www.pycryptodome.org/src/changelog
### CVSREPO:=https://github.com/Legrandin/pycryptodome/

$(PKG)_DEPENDS_ON += python
$(PKG)_DEPENDS_ON += python2-setuptools-host


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_PYCRYPTODOME, , )
	@touch $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_DIR)/.compiled


$(pkg)-clean:
	$(RM) $(PYTHON_PYCRYPTODOME_DIR)/{.configured,.compiled}
	$(RM) -r $(PYTHON_PYCRYPTODOME_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYCRYPTODOME_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Crypto \
		$(PYTHON_PYCRYPTODOME_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pycryptodome-*.egg-info

$(PKG_FINISH)

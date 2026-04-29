$(call TOOLS_INIT, 4.25.1)
$(PKG)_SOURCE_DOWNLOAD_NAME:=jsonschema-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=e4a9655ce0da0c0b67a085847e00a3a51449e1157f4f75e9fb5aa545e122eb85
$(PKG)_SITE:=https://github.com/python-jsonschema/jsonschema/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://pypi.org/project/jsonschema
### MANPAGE:=https://python-jsonschema.readthedocs.io
### CHANGES:=https://github.com/python-jsonschema/jsonschema/releases
### CVSREPO:=https://github.com/python-jsonschema/jsonschema
### STEWARD:=fda77

$(PKG)_DEPENDS_ON+=python3-host

$(PKG)_DIRECTORY:=$($(PKG)_DIR)/jsonschema


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	cp -fa $(PYTHON3_JSONSCHEMA_HOST_DIRECTORY) $(PYTHON3_HOST_SITE_PACKAGES)/
	@touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(PYTHON3_JSONSCHEMA_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(PYTHON3_HOST_SITE_PACKAGES)/jsonschema/

$(TOOLS_FINISH)

$(call TOOLS_INIT, 25.4.0)
$(PKG)_SOURCE_DOWNLOAD_NAME:=$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=2bff06c2afd09911e10e8ab8126ae0eeb3d13b7fed5db66bf7e021682cc2d9f0
$(PKG)_SITE:=https://github.com/python-attrs/attrs/archive/refs/tags
### WEBSITE:=https://pypi.org/project/attrs/
### MANPAGE:=https://www.attrs.org/
### CHANGES:=https://github.com/python-attrs/attrs/releases
### CVSREPO:=https://github.com/python-attrs/attrs
### STEWARD:=fda77

$(PKG)_DEPENDS_ON+=python3-host

$(PKG)_DIRECTORY:=$($(PKG)_DIR)/src/*


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	cp -fa $(PYTHON3_ATTRS_HOST_DIRECTORY) $(PYTHON3_HOST_SITE_PACKAGES)/
	@touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(PYTHON3_ATTRS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(PYTHON3_HOST_SITE_PACKAGES)/attr/ $(PYTHON3_HOST_SITE_PACKAGES)/attrs/

$(TOOLS_FINISH)

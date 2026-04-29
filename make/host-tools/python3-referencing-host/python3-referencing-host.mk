$(call TOOLS_INIT, 0.37.0)
$(PKG)_SOURCE_DOWNLOAD_NAME:=referencing-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=44aefc3142c5b842538163acb373e24cce6632bd54bdb01b21ad5863489f50d8
$(PKG)_SITE:=https://github.com/python-jsonschema/referencing/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://pypi.org/project/referencing/
### MANPAGE:=https://referencing.readthedocs.io
### CHANGES:=https://github.com/python-jsonschema/referencing/releases
### CVSREPO:=https://github.com/python-jsonschema/referencing
### STEWARD:=fda77

$(PKG)_DEPENDS_ON+=python3-host

$(PKG)_DIRECTORY:=$($(PKG)_DIR)/referencing


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	cp -fa $(PYTHON3_REFERENCING_HOST_DIRECTORY) $(PYTHON3_HOST_SITE_PACKAGES)/
	@touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(PYTHON3_REFERENCING_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(PYTHON3_HOST_SITE_PACKAGES)/referencing/

$(TOOLS_FINISH)

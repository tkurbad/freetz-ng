$(call PKG_INIT_BIN, 0.2.5)
$(PKG)_SOURCE:=mechanize-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=2e67b20d107b30c00ad814891a095048c35d9d8cb9541801cebe85684cc84766
$(PKG)_SITE:=https://pypi.python.org/packages/source/m/mechanize

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/mechanize/__init__.py

$(PKG)_DEPENDS_ON += python

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_MECHANIZE)
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) -r $(PYTHON_MECHANIZE_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_MECHANIZE_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/mechanize \
		$(PYTHON_MECHANIZE_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/mechanize-*.egg-info

$(PKG_FINISH)

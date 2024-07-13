$(call TOOLS_INIT, 24.1)
$(PKG)_SOURCE_DOWNLOAD_NAME:=$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=7b31090ae4ddd6c48a5ed10073a880e6e2612ce8ac2f81e34f42aaabefd1b81b
$(PKG)_SITE:=https://github.com/pypa/packaging/archive/refs/tags
### WEBSITE:=https://pypi.org/project/packaging/
### MANPAGE:=https://packaging.pypa.io/
### CHANGES:=https://github.com/pypa/packaging/releases
### CVSREPO:=https://github.com/pypa/packaging

$(PKG)_DEPENDS_ON+=python3-host

$(PKG)_DIRECTORY:=$($(PKG)_DIR)/src/packaging
$(PKG)_TARGET_DIRECTORY:=$(HOST_TOOLS_DIR)/usr/lib/python$(call GET_MAJOR_VERSION,$(PYTHON3_HOST_VERSION))/site-packages/packaging


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_TARGET_DIRECTORY)/.installed: $($(PKG)_DIR)/.unpacked
	cp -fa $(PYTHON3_PACKAGING_HOST_DIRECTORY) $(dir $(PYTHON3_PACKAGING_HOST_TARGET_DIRECTORY))
	@touch $@

$(pkg)-precompiled: $($(PKG)_TARGET_DIRECTORY)/.installed


$(pkg)-clean:

$(pkg)-dirclean:

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(PYTHON3_PACKAGING_HOST_TARGET_DIRECTORY)

$(TOOLS_FINISH)

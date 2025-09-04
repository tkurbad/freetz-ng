$(call TOOLS_INIT, 1.8.4)
$(PKG)_SOURCE:=meson-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=5fabf143f58e6636c8ff41ae489bbd5d5d86f881f0a1ef1726cfaf703116e071
$(PKG)_SITE:=https://github.com/mesonbuild/meson/releases/download/$($(PKG)_VERSION)
### WEBSITE:=https://mesonbuild.com/
### MANPAGE:=https://mesonbuild.com/
### CHANGES:=https://github.com/mesonbuild/meson/releases
### CVSREPO:=https://github.com/mesonbuild/meson
### SUPPORT:=fda77

$(PKG)_DEPENDS_ON+=python3-host
$(PKG)_DEPENDS_ON+=ninja-host

$(PKG)_BINARY:=$($(PKG)_DIR)/meson.pyz
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/meson


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBPYTHON3) \
		$(MESON_HOST_DIR)/packaging/create_zipapp.py \
		--outfile $(MESON_HOST_BINARY) \
		--interpreter '/usr/bin/env python3' \
		$(MESON_HOST_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	$(RM) $(MESON_HOST_DIR)/.configured

$(pkg)-dirclean:
	$(RM) -r $(MESON_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r $(MESON_HOST_TARGET_BINARY)

$(TOOLS_FINISH)

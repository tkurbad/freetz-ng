$(call TOOLS_INIT, $(if $(FREETZ_TOOLS_PATCHELF_VERSION_ABANDON),0.14.5,0.15.0))
$(PKG)_SOURCE:=patchelf-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH_ABANDON:=b9a46f2989322eb89fa4f6237e20836c57b455aa43a32545ea093b431d982f5c
$(PKG)_HASH_CURRENT:=f4036d3ee4d8e228dec1befff0f6e46d8a40e9e570e0068e39d77e62e2c8bdc2
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_TOOLS_PATCHELF_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://github.com/NixOS/patchelf/releases/download/$($(PKG)_VERSION),https://releases.nixos.org/patchelf/patchelf-$($(PKG)_VERSION)
### WEBSITE:=https://opencollective.com/nixos
### MANPAGE:=https://sources.debian.org/patches/patchelf/
### CHANGES:=https://github.com/NixOS/patchelf/releases
### CVSREPO:=https://github.com/NixOS/patchelf

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_TOOLS_PATCHELF_VERSION_ABANDON),abandon,current)
$(PKG)_REBUILD_SUBOPTS += FREETZ_TOOLS_PATCHELF_VERSION_ABANDON


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/src/patchelf: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(PATCHELF_HOST_DIR) all
	touch -c $@

$(TOOLS_DIR)/patchelf: $($(PKG)_DIR)/src/patchelf
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/patchelf


$(pkg)-clean:
	-$(MAKE) -C $(PATCHELF_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(PATCHELF_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/patchelf

$(TOOLS_FINISH)

$(call TOOLS_INIT, $(if $(FREETZ_TOOLS_PATCHELF_VERSION_ABANDON),0.14.5,0.15.0))
$(PKG)_SOURCE:=patchelf-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH_ABANDON:=b9a46f2989322eb89fa4f6237e20836c57b455aa43a32545ea093b431d982f5c
$(PKG)_HASH_CURRENT:=f4036d3ee4d8e228dec1befff0f6e46d8a40e9e570e0068e39d77e62e2c8bdc2
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_TOOLS_PATCHELF_VERSION_ABANDON),ABANDON,CURRENT))
#
#
$(PKG)_SITE:=https://github.com/NixOS/patchelf/releases/download/$($(PKG)_VERSION)
### WEBSITE:=https://opencollective.com/nixos
### MANPAGE:=https://sources.debian.org/patches/patchelf/
### CHANGES:=https://github.com/NixOS/patchelf/releases
### CVSREPO:=https://github.com/NixOS/patchelf
### VERSION:=0.14.5/0.15.0

$(PKG)_SRC_BINARY := $($(PKG)_DIR)/src/patchelf
$(PKG)_DST_BINARY := $(TOOLS_DIR)/patchelf-target

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_TOOLS_PATCHELF_VERSION_ABANDON),abandon,current)
$(PKG)_REBUILD_SUBOPTS += FREETZ_TOOLS_PATCHELF_VERSION_ABANDON

$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)


ifneq ($($(PKG)_SOURCE),$(PATCHELF_HOST_SOURCE))
$(TOOLS_SOURCE_DOWNLOAD)
endif
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_SRC_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(PATCHELF_TARGET_HOST_DIR) all

$($(PKG)_DST_BINARY): $($(PKG)_SRC_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_DST_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(PATCHELF_TARGET_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(PATCHELF_TARGET_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(PATCHELF_TARGET_HOST_DST_BINARY)

$(TOOLS_FINISH)

$(call TOOLS_INIT, 2.8)
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=f87cee69eec2b4fcbf60a396b030ad6aa3415f192aa5f7ee84cad5e11f7f5ae3
$(PKG)_SITE:=@GNU/patch
### WEBSITE:=https://savannah.gnu.org/projects/patch/
### MANPAGE:=https://linux.die.net/man/1/patch
### CHANGES:=https://savannah.gnu.org/news/?group=patch
### CVSREPO:=https://cgit.git.savannah.gnu.org/cgit/patch.git
### STEWARD:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/src/patch
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/patch

$(PKG)_CONFIGURE_OPTIONS += --disable-xattr


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(PATCH_HOST_DIR) all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(PATCH_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(PATCH_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(PATCH_HOST_TARGET_BINARY)

$(TOOLS_FINISH)

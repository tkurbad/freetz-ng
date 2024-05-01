$(call TOOLS_INIT, 2.15)
$(PKG)_SOURCE:=cpio-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=937610b97c329a1ec9268553fb780037bcfff0dcffe9725ebc4fd9c1aa9075db
$(PKG)_SITE:=@GNU/cpio
### WEBSITE:=https://www.gnu.org/software/cpio/
### MANPAGE:=https://www.gnu.org/software/cpio/manual/
### CHANGES:=https://savannah.gnu.org/projects/cpio
### CVSREPO:=https://git.savannah.gnu.org/cgit/cpio.git

$(PKG)_BINARY:=$($(PKG)_DIR)/src/cpio
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/cpio

$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(CPIO_HOST_DIR) all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(CPIO_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(CPIO_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(CPIO_HOST_TARGET_BINARY)

$(TOOLS_FINISH)

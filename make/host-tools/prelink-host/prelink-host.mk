$(call TOOLS_INIT, 20131005)
$(PKG)_SOURCE:=prelink_0.0.$($(PKG)_VERSION).orig.tar.bz2
$(PKG)_HASH:=1a5bf03381e83fbfbbe98ecca7b58ce2e726f662b560c3ff05aebcdaae397130
$(PKG)_SITE:=https://people.redhat.com/jakub/prelink,https://ftp.debian.org/debian/pool/main/p/prelink
### WEBSITE:=https://people.redhat.com/jakub/prelink/
### MANPAGE:=https://people.redhat.com/jakub/prelink/prelink.pdf
### CHANGES:=https://packages.debian.org/buster/execstack
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/src/execstack
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/execstack

$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)

# fakeroot & pseudo cant handle selinux
$(PKG)_CONFIGURE_ENV += ac_cv_lib_selinux_is_selinux_enabled=no


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(PRELINK_HOST_DIR) \
		prelink_LDFLAGS="" \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(PRELINK_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(PRELINK_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(PRELINK_HOST_TARGET_BINARY)

$(TOOLS_FINISH)

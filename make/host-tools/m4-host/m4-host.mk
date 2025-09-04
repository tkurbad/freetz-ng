$(call TOOLS_INIT, 1.4.20)
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=e236ea3a1ccf5f6c270b1c4bb60726f371fa49459a8eaaebc90b216b328daf2b
$(PKG)_SITE:=@GNU/$(pkg_short)
### WEBSITE:=https://www.gnu.org/software/m4/
### MANPAGE:=https://www.gnu.org/software/m4/manual/index.html
### CHANGES:=http://ftp.gnu.org/gnu/m4/
### CVSREPO:=http://git.savannah.gnu.org/gitweb/?p=m4.git
### SUPPORT:=fda77

$(PKG)_DEPENDS_ON+=pkgconf-host

$(PKG)_BINARY:=$($(PKG)_DIR)/src/m4
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/build/bin/m4

$(PKG)_CFLAGS := $(TOOLS_CFLAGS)
$(PKG)_CFLAGS += -std=gnu17


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(M4_HOST_DIR) \
		CFLAGS="$(M4_HOST_CFLAGS)" \
		all
	touch -c $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(M4_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(M4_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(M4_HOST_TARGET_BINARY)

$(TOOLS_FINISH)

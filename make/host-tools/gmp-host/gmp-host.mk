$(call TOOLS_INIT, 6.3.0)
$(PKG)_SOURCE:=gmp-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898
$(PKG)_SITE:=@GNU/gmp

$(PKG)_BINARY:=$(HOST_TOOLS_DIR)/lib/libgmp.a

$(PKG)_CONFIGURE_ENV += CC="$(TOOLCHAIN_HOSTCC)"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)"

$(PKG)_CONFIGURE_OPTIONS += --prefix=$(HOST_TOOLS_DIR)
$(PKG)_CONFIGURE_OPTIONS += --build=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --host=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured | $(HOST_TOOLS_DIR)
	$(TOOLS_SUBMAKE) -C $(GMP_HOST_DIR) install

$(pkg)-precompiled: $($(PKG)_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(GMP_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(GMP_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(HOST_TOOLS_DIR)/lib/libgmp* $(HOST_TOOLS_DIR)/include/gmp*.h

$(TOOLS_FINISH)

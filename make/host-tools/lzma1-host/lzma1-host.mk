$(call TOOLS_INIT, 465)
$(PKG)_SOURCE:=lzma$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=c935fd04dd8e0e8c688a3078f3675d699679a90be81c12686837e0880aa0fa1e
$(PKG)_SITE:=@SF/sevenzip

$(PKG)_ALONE_DIR:=$($(PKG)_DIR)/CPP/7zip/Compress/LZMA_Alone
$(PKG)_LIBC_DIR:=$($(PKG)_DIR)/C/LzmaLib
$(PKG)_LIBCXX_DIR:=$($(PKG)_DIR)/CPP/7zip/Compress/LZMA_Lib

$(PKG)_TARBALL_STRIP_COMPONENTS:=0


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_ALONE_DIR)/lzma: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" LDFLAGS="$(TOOLS_LDFLAGS)" -f makefile.gcc -C $(LZMA1_HOST_ALONE_DIR)
	touch -c $@

$($(PKG)_LIBC_DIR)/liblzma.a: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) -f makefile.gcc -C $(LZMA1_HOST_LIBC_DIR)
	touch -c $@

$($(PKG)_LIBCXX_DIR)/liblzma++.a: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) -f makefile.gcc -C $(LZMA1_HOST_LIBCXX_DIR)
	touch -c $@

$($(PKG)_DIR)/liblzma1.a: $($(PKG)_LIBC_DIR)/liblzma.a
	$(INSTALL_FILE)

$($(PKG)_DIR)/liblzma1++.a: $($(PKG)_LIBCXX_DIR)/liblzma++.a
	$(INSTALL_FILE)

$(TOOLS_DIR)/lzma: $($(PKG)_ALONE_DIR)/lzma
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_DIR)/liblzma1.a $($(PKG)_DIR)/liblzma1++.a $(TOOLS_DIR)/lzma


$(pkg)-clean:
	-$(MAKE) -C $(LZMA1_HOST_ALONE_DIR) clean
	-$(MAKE) -C $(LZMA1_HOST_LIBCXX_DIR) clean
	$(RM) $(LZMA1_HOST_DIR)/liblzma1*.a

$(pkg)-dirclean:
	$(RM) -r $(LZMA1_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/lzma

$(TOOLS_FINISH)

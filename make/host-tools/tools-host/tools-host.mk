$(call TOOLS_INIT, 2023-08-18)
$(PKG)_SOURCE:=tools-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=70e08bbf10ff74252091f750b41cfb9b3441ca4bca376b26ad14faebc581f998
$(PKG)_SITE:=@MIRROR/

$(PKG)_DEPENDS_ON:=kconfig-host

$(PKG)_TARBALL_STRIP_COMPONENTS:=0


define $(PKG)_CUSTOM_UNPACK
	tar -C $($(PKG)_DIR) $(VERBOSE) -xf $(DL_DIR)/$($(PKG)_SOURCE)
endef

#$(pkg)-source: $(DL_DIR)/$($(PKG)_SOURCE)
#$(DL_DIR)/$($(PKG)_SOURCE): | $(DL_DIR)
#	$(info ERROR: File '$(DL_DIR)/$(TOOLS_HOST_SOURCE)' not found.)
#	$(info There is and will no download source be available.)
#	$(info Either disable 'FREETZ_HOSTTOOLS_DOWNLOAD' in menuconfig or)
#	$(info create the file by yourself with 'tools/dl-hosttools own'.)
#	$(error )
$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.unpacked
	cp -fa $(TOOLS_HOST_DIR)/tools $(FREETZ_BASE_DIR)/
	touch $@

$($(PKG)_DIR)/.fixhardcoded: $($(PKG)_DIR)/.installed | $(patsubst %,%-fixhardcoded,$(TOOLS))
	touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.fixhardcoded


$(pkg)-clean:

$(pkg)-dirclean:
	$(RM) -r $(TOOLS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean $(patsubst %,%-distclean,$(filter-out $(TOOLS_BUILD_LOCAL),$(TOOLS)))

$(TOOLS_FINISH)

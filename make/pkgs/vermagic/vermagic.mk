$(call PKG_INIT_BIN, 617f27ff06)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=3bf8aa5eefb77eeec85059dc237b1f34316e9de5990126602651bcff0ff535d5
$(PKG)_SITE:=git@https://github.com/fanfuqiang/vc.git
#$(PKG)_SITE:=git@https://github.com/D1W0U/vermagic

$(PKG)_CATEGORY:=Debug helpers

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TARGET_CONFIGURE_ENV) $(FREETZ_LD_RUN_PATH) \
		$(TARGET_CC) \
		$(TARGET_CFLAGS) \
		$(TARGET_LDFLAGS) \
		-DUCLIBC_RUNTIME_PREFIX=\"/\" \
		$(VERMAGIC_DIR)/vc.c -o $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	$(RM) $(VERMAGIC_DIR)$(VERMAGIC_BINARY)

$(pkg)-uninstall:
	$(RM) $(VERMAGIC_TARGET_BINARY)

$(PKG_FINISH)

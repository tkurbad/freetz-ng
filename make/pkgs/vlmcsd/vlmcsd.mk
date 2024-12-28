$(call PKG_INIT_BIN, svn1113)
$(PKG)_SOURCE_DOWNLOAD_NAME:=$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=f73b801d56ec7f5e06a306bfb0a6e22b531617ca
$(PKG)_SITE:=https://github.com/Wind4/vlmcsd/archive/refs/tags/
### CHANGES:=https://github.com/Wind4/vlmcsd/releases
### CVSREPO:=https://github.com/Wind4/vlmcsd
### SUPPORT:=manfred-mueller

$(PKG)_BINARIES_ALL := vlmcs vlmcsd
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/bin/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(VLMCSD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/bin/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(VLMCSD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(VLMCSD_BINARIES_ALL:%=$(VLMCSD_DEST_DIR)/usr/bin/%)

$(PKG_FINISH)

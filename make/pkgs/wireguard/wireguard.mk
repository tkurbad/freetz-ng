$(call PKG_INIT_BIN, 1.0.20260223)
$(PKG)_SOURCE:=wireguard-tools-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=af459827b80bfd31b83b08077f4b5843acb7d18ad9a33a2ef532d3090f291fbf
$(PKG)_SITE:=https://git.zx2c4.com/wireguard-tools/snapshot
### WEBSITE:=https://www.wireguard.com/
### MANPAGE:=https://www.wireguard.com/quickstart/
### CHANGES:=https://git.zx2c4.com/wireguard-tools/log/
### CVSREPO:=https://git.zx2c4.com/wireguard-tools/
### STEWARD:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/src/wg
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/wg

$(PKG)_STARTLEVEL=81

$(PKG)_EXTRA_CFLAGS += --function-section -fdata-sections -fstack-protector-strong
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

$(PKG)_DEPENDS_ON += kernel

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(WIREGUARD_DIR)/src \
		CC="$(TARGET_CC)" \
		EXTRA_CFLAGS="$(WIREGUARD_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(WIREGUARD_EXTRA_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(WIREGUARD_DIR)/src clean

$(pkg)-uninstall:
	$(RM) $(WIREGUARD_TARGET_BINARY)

$(PKG_FINISH)

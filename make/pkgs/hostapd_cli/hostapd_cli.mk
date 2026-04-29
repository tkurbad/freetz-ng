$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_HOSTAPD_CLI_VERSION_2_7),2.7,$(if $(FREETZ_PACKAGE_HOSTAPD_CLI_VERSION_2_10),2.10,2.11)))
$(PKG)_SOURCE:=hostapd-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_2.7  := 21b0dda3cc3abe75849437f6b9746da461f88f0ea49dd621216936f87440a141
$(PKG)_HASH_2.10 := 206e7c799b678572c2e3d12030238784bc4a9f82323b0156b4c9466f1498915d
$(PKG)_HASH_2.11 := 2b3facb632fd4f65e32f4bf82a76b4b72c501f995a4f62e330219fe7aed1747a
$(PKG)_HASH:=$($(PKG)_HASH_$($(PKG)_VERSION))
$(PKG)_SITE:=https://w1.fi/releases
### WEBSITE:=https://w1.fi/hostapd/
### MANPAGE:=https://manpages.ubuntu.com/manpages/jammy/man1/hostapd_cli.1.html
### CHANGES:=https://git.w1.fi/cgit/hostap/log/hostapd
### CVSREPO:=https://git.w1.fi/cgit/hostap/tree/hostapd
### STEWARD:=jpsollie

$(PKG)_BINARY         := $($(PKG)_DIR)/hostapd/hostapd_cli
$(PKG)_TARGET_BINARY  := $($(PKG)_DEST_DIR)/usr/sbin/hostapd_cli

$(PKG)_CFLAGS := $(TARGET_CFLAGS)
$(PKG)_CFLAGS += -ffunction-sections -fdata-sections
# Correct include paths for submodules
$(PKG)_CFLAGS += -I../src
$(PKG)_CFLAGS += -I../src/utils
$(PKG)_CFLAGS += -I../src/common
$(PKG)_CFLAGS += -I../src/drivers
$(PKG)_CFLAGS += -I../src/l2_packet
$(PKG)_CFLAGS += -I../src/crypto
$(PKG)_CFLAGS += -I../src/ap
# force ignored .config options
$(PKG)_CFLAGS += -DCONFIG_DEBUG_FILE
$(PKG)_CFLAGS += -DCONFIG_CTRL_IFACE
$(PKG)_CFLAGS += -DCONFIG_CTRL_IFACE_UNIX
$(PKG)_CFLAGS += -DCONFIG_CTRL_IFACE_SOCKET
$(PKG)_CFLAGS += -DCONFIG_WPA_CTRL_IFACE
$(PKG)_CFLAGS += -DCONFIG_WPA_CLI
$(PKG)_CFLAGS += -DCONFIG_WPA
$(PKG)_CFLAGS += -DCONFIG_WPA2
$(PKG)_CFLAGS += -DHOSTAPD_CLI_BUILD

$(PKG)_LDFLAGS := $(TARGET_LDFLAGS)
$(PKG)_LDFLAGS += -Wl,--gc-sections

$(PKG)_CONDITIONAL_PATCHES+=$($(PKG)_VERSION)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

# The .config is not included if compiled by freetz, but has to exist.
$(pkg)-configured: $($(PKG)_DIR)/.configured
$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	cat $(HOSTAPD_CLI_MAKE_DIR)/hostapd_cli.config > $(HOSTAPD_CLI_DIR)/hostapd/.config
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(HOSTAPD_CLI_DIR)/hostapd \
		CC="$(TARGET_CC)" \
		CFLAGS="$(HOSTAPD_CLI_CFLAGS)" \
		LDFLAGS="$(HOSTAPD_CLI_LDFLAGS)" \
		hostapd_cli

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(HOSTAPD_CLI_DIR)/hostapd clean

$(pkg)-uninstall:
	$(RM) $(HOSTAPD_CLI_TARGET_BINARY)

$(PKG_FINISH)

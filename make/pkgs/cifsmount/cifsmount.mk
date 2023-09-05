$(call PKG_INIT_BIN, 7.0)
$(PKG)_SOURCE:=cifs-utils-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=0defaab85bd3ea46ffc45ab41fb0d0ad54d05ae2cfaa7e503de86d4f12bc8161
$(PKG)_SITE:=@SAMBA/linux-cifs/cifs-utils
### WEBSITE:=https://wiki.samba.org/index.php/LinuxCIFS_utils
### CHANGES:=https://wiki.samba.org/index.php/LinuxCIFS_utils#News
### CVSREPO:=https://git.samba.org/?p=cifs-utils.git;a=summary

$(PKG)_STARTLEVEL=50

$(PKG)_BINARY:=$($(PKG)_DIR)/mount.cifs
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/mount.cifs

$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_CIFSMOUNT_REMOVE_WEBIF),usr/sbin/cifsmount usr/lib/cgi-bin/cifsmount.cgi etc/default.cifsmount etc/init.d/rc.cifsmount)

$(PKG)_CONFIGURE_OPTIONS += --disable-pie
$(PKG)_CONFIGURE_OPTIONS += --disable-relro
$(PKG)_CONFIGURE_OPTIONS += --disable-cifsupcall
$(PKG)_CONFIGURE_OPTIONS += --disable-cifscreds
$(PKG)_CONFIGURE_OPTIONS += --disable-cifsidmap
$(PKG)_CONFIGURE_OPTIONS += --disable-cifsacl
$(PKG)_CONFIGURE_OPTIONS += --disable-smbinfo
$(PKG)_CONFIGURE_OPTIONS += --disable-pythontools
$(PKG)_CONFIGURE_OPTIONS += --disable-pam
$(PKG)_CONFIGURE_OPTIONS += --disable-systemd
$(PKG)_CONFIGURE_OPTIONS += --disable-man
$(PKG)_CONFIGURE_OPTIONS += --without-libcap

$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CIFSMOUNT_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(CIFSMOUNT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(CIFSMOUNT_TARGET_BINARY)

$(PKG_FINISH)

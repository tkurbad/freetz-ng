$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_SCREEN_VERSION_ABANDON),4.9.1,5.0.1))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=26cef3e3c42571c0d484ad6faf110c5c15091fbf872b06fa7aa4766c7405ac69
$(PKG)_HASH_CURRENT:=2dae36f4db379ffcd14b691596ba6ec18ac3a9e22bc47ac239789ab58409869d
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_SCREEN_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=@GNU/$(pkg)
### WEBSITE:=https://www.gnu.org/software/screen/
### MANPAGE:=https://www.gnu.org/software/screen/manual/
### CHANGES:=https://git.savannah.gnu.org/cgit/screen.git/refs/
### CVSREPO:=https://git.savannah.gnu.org/cgit/screen.git
### SUPPORT:=fda77

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_SCREEN_VERSION_ABANDON),abandon,current)

$(PKG)_BINARY:=$($(PKG)_DIR)/screen
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/screen.bin

$(PKG)_DEPENDS_ON += ncurses

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SCREEN_VERSION_ABANDON

ifeq ($(strip $(FREETZ_PACKAGE_SCREEN_VERSION_ABANDON)),y)
$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)
else
$(PKG)_CONFIGURE_OPTIONS += --disable-pam
endif
$(PKG)_CONFIGURE_OPTIONS += --disable-socket-dir
$(PKG)_CONFIGURE_OPTIONS += --with-sys-screenrc=/etc/screenrc
$(PKG)_CONFIGURE_OPTIONS += --enable-colors256


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SCREEN_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(SCREEN_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SCREEN_TARGET_BINARY)

$(PKG_FINISH)

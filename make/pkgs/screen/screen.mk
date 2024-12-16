$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_SCREEN_VERSION_ABANDON),4.9.1,5.0.0))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=26cef3e3c42571c0d484ad6faf110c5c15091fbf872b06fa7aa4766c7405ac69
$(PKG)_HASH_CURRENT:=f04a39d00a0e5c7c86a55338808903082ad5df4d73df1a2fd3425976aed94971
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

ifeq ($(FREETZ_PACKAGE_SCREEN_VERSION_ABANDON),y)
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

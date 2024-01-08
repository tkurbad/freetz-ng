$(call PKG_INIT_BIN, v3.7.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=c7a58543f2d3c1ac4f116eb09f23f70734609a0f0981a26bc5c5e44e3e8af279
$(PKG)_SITE:=git@https://github.com/bcl/digitemp.git
### WEBSITE:=https://github.com/bcl/digitemp
### MANPAGE:=https://github.com/bcl/digitemp#readme
### CHANGES:=https://github.com/bcl/digitemp/releases
### CVSREPO:=https://github.com/bcl/digitemp/commits/master

$(PKG)_BINARY:=$($(PKG)_DIR)/digitemp
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/digitemp

$(PKG)_MAKE_TARGET:=ds9097

ifeq ($(strip $(FREETZ_PACKAGE_DIGITEMP_DS2490)),y)
$(PKG)_MAKE_TARGET:=ds2490
$(PKG)_DEPENDS_ON += libusb
$(PKG)_REBUILD_SUBOPTS += $(LIBUSB_REBUILD_SUBOPTS)
endif

ifeq ($(strip $(FREETZ_PACKAGE_DIGITEMP_DS9097U)),y)
$(PKG)_MAKE_TARGET:=ds9097u
endif

$(PKG)_MAKE_BINARY:=$($(PKG)_DIR)/digitemp_$(shell echo $($(PKG)_MAKE_TARGET) | tr '[:lower:]' '[:upper:]')

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DIGITEMP_DS9097
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DIGITEMP_DS2490
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DIGITEMP_DS9097U


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DIGITEMP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		$(DIGITEMP_MAKE_TARGET)
	cp $(DIGITEMP_MAKE_BINARY) $(DIGITEMP_BINARY)


$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(DIGITEMP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DIGITEMP_TARGET_BINARY)

$(PKG_FINISH)

$(call PKG_INIT_LIB, 1.50.14)
$(PKG)_LIB_VERSION:=0.5000.14
$(PKG)_MAJOR_VERSION:=1.0
$(PKG)_SOURCE:=pango-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=1d67f205bfc318c27a29cfdfb6828568df566795df0cb51d2189cde7f2d581e8
$(PKG)_SITE:=https://download.gnome.org/sources/pango/$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
### WEBSITE:=https://www.pango.org/
### MANPAGE:=https://docs.gtk.org/Pango/
### CHANGES:=https://gitlab.gnome.org/GNOME/pango/blob/main/NEWS
### CVSREPO:=https://gitlab.gnome.org/GNOME/pango

$(PKG)_LIBNAMES_SHORT   := pango pangoft2 pangocairo
$(PKG)_LIBNAMES_LONG    := $($(PKG)_LIBNAMES_SHORT:%=lib%-$($(PKG)_MAJOR_VERSION).so.$($(PKG)_LIB_VERSION))
$(PKG)_LIBS_BUILD_DIR   := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DIR)/builddir/pango/%)
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR  := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_TARGET_DIR)/%)

$(PKG)_DEPENDS_ON += meson-host glib2 harfbuzz fribidi fontconfig freetype cairo

$(PKG)_CONFIGURE_OPTIONS += -D gtk_doc=false
$(PKG)_CONFIGURE_OPTIONS += -D introspection=disabled
$(PKG)_CONFIGURE_OPTIONS += -D install-tests=false
$(PKG)_CONFIGURE_OPTIONS += -D sysprof=disabled
$(PKG)_CONFIGURE_OPTIONS += -D libthai=disabled
$(PKG)_CONFIGURE_OPTIONS += -D xft=disabled
$(PKG)_CONFIGURE_OPTIONS += -D fontconfig=enabled
$(PKG)_CONFIGURE_OPTIONS += -D freetype=enabled
$(PKG)_CONFIGURE_OPTIONS += -D cairo=enabled

$(PKG)_EXTRA_CFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/glib-2.0
$(PKG)_EXTRA_CFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/glib-2.0/include


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_MESON)

$($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMESON) compile \
		-C $(PANGO_DIR)/builddir/
#meson	$(MESON) configure $(PANGO_DIR)/builddir/

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMESON) install \
		--destdir "$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(PANGO_DIR)/builddir/
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/pango*.pc
#meson		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpango*.la

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIBS_STAGING_DIR)

$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(PANGO_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpango* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/pango/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/pango*.pc

$(pkg)-uninstall:
	$(RM) $(PANGO_TARGET_DIR)/libpango.so*

$(PKG_FINISH)

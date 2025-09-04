$(call TOOLS_INIT, 2.5.4)
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=f81f5860666b0bc7d84baddefa60d1cb9fa6fceb2398cc3baca6afaa60266675
$(PKG)_SITE:=@GNU/$(pkg_short)
### WEBSITE:=https://www.gnu.org/software/libtool/
### MANPAGE:=https://www.gnu.org/software/libtool/manual/
### CHANGES:=https://ftpmirror.gnu.org/libtool/
### CVSREPO:=https://git.savannah.gnu.org/cgit/libtool.git
### SUPPORT:=fda77

$(PKG)_DEPENDS_ON+=autoconf-host

$(PKG)_DESTDIR             := $(FREETZ_BASE_DIR)/$(TOOLS_BUILD_DIR)

$(PKG)_BINARIES            := libtool libtoolize
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DESTDIR)/bin/%)

$(PKG)_CONFIGURE_OPTIONS += --prefix=$(LIBTOOL_HOST_DESTDIR)


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(LIBTOOL_HOST_DIR) \
		LDFLAGS="$(TOOLS_LDFLAGS) -static" \
		all
	@touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.compiled
	$(TOOLS_SUBMAKE) -C $(LIBTOOL_HOST_DIR) install
	@touch $@

$(pkg)-fixhardcoded:
	-@$(SED) -i "s!$(TOOLS_HARDCODED_DIR)!$(LIBTOOL_HOST_DESTDIR)!g" \
		$(LIBTOOL_HOST_BINARIES_TARGET_DIR) \
		$(LIBTOOL_HOST_DESTDIR)/lib/libltdl.la

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:
	-$(MAKE) -C $(LIBTOOL_HOST_DIR) clean
	-$(RM) $(LIBTOOL_HOST_DIR)/.{configured,compiled,installed,fixhardcoded}

$(pkg)-dirclean:
	$(RM) -r $(LIBTOOL_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r \
		$(LIBTOOL_HOST_BINARIES_TARGET_DIR) \
		$(LIBTOOL_HOST_DESTDIR)/include/ltdl.h \
		$(LIBTOOL_HOST_DESTDIR)/include/libltdl/ \
		$(LIBTOOL_HOST_DESTDIR)/share/libtool/ \
		$(LIBTOOL_HOST_DESTDIR)/share/aclocal/ltversion.m4 \
		$(LIBTOOL_HOST_DESTDIR)/share/aclocal/ltoptions.m4 \
		$(LIBTOOL_HOST_DESTDIR)/share/aclocal/libtool.m4 \
		$(LIBTOOL_HOST_DESTDIR)/share/aclocal/ltsugar.m4 \
		$(LIBTOOL_HOST_DESTDIR)/share/aclocal/ltdl.m4 \
		$(LIBTOOL_HOST_DESTDIR)/share/aclocal/lt~obsolete.m4 \
		$(LIBTOOL_HOST_DESTDIR)/lib/libltdl.*

$(TOOLS_FINISH)

$(call PKG_INIT_BIN, 2.0.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=52f25811f00dfe714e0bcf122358ee0ad74e25db3ad230d5a4196e7a62633f27
$(PKG)_SITE:=https://www.vervest.org/htp/archive/c
### WEBSITE:=https://www.vervest.org/htp/
### MANPAGE:=https://www.vervest.org/htp/?FAQ
### CHANGES:=https://github.com/twekkel/htpdate/blob/master/Changelog
### CVSREPO:=https://github.com/twekkel/htpdate
### SUPPORT:=fda77

$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_HTPDATE_REMOVE_WEBIF),etc/default.htpdate etc/onlinechanged/10-htpdate etc/init.d/rc.htpdate usr/lib/cgi-bin/htpdate.cgi)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(HTPDATE_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE1) -C $(HTPDATE_DIR) clean
	$(RM) $(HTPDATE_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(HTPDATE_BINARIES_TARGET_DIR)

$(PKG_FINISH)

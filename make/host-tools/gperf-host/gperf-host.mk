$(call TOOLS_INIT, 3.2)
$(PKG)_SOURCE:=gperf-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=e0ddadebb396906a3e3e4cac2f697c8d6ab92dffa5d365a5bc23c7d41d30ef62
$(PKG)_SITE:=https://ftp.gnu.org/pub/gnu/gperf/
### WEBSITE:=https://www.gnu.org/software/gperf/
### MANPAGE:=https://linux.die.net/man/1/gperf
### CHANGES:=http://savannah.gnu.org/projects/gperf/
### CVSREPO:=https://git.savannah.gnu.org/gitweb/?p=gperf.git
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/src/gperf
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/gperf


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(GPERF_HOST_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(GPERF_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(GPERF_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(GPERF_HOST_TARGET_BINARY)

$(TOOLS_FINISH)

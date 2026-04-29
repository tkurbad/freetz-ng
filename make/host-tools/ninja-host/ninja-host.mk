$(call TOOLS_INIT, 1.13.2)
$(PKG)_SOURCE_DOWNLOAD_NAME:=v$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=974d6b2f4eeefa25625d34da3cb36bdcebe7fbce40f4c16ac0835fd1c0cbae17
$(PKG)_SITE:=https://github.com/ninja-build/ninja/archive/refs/tags
### WEBSITE:=https://ninja-build.org/
### MANPAGE:=https://github.com/ninja-build/ninja/wiki
### CHANGES:=https://github.com/ninja-build/ninja/releases
### CVSREPO:=https://github.com/ninja-build/ninja
### STEWARD:=fda77

$(PKG)_BUILD_DIR:=$($(PKG)_DIR)/builddir
$(PKG)_BINARY:=$($(PKG)_BUILD_DIR)/ninja
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/ninja

$(PKG)_DEPENDS_ON+=cmake-host


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBCMAKE) \
		-B $(NINJA_HOST_BUILD_DIR) \
		-S $(NINJA_HOST_DIR) \
		-DBUILD_TESTING=OFF
	@touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBCMAKE) \
		--build $(NINJA_HOST_BUILD_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(CMAKE) \
		--build $(NINJA_HOST_BUILD_DIR) \
		--target clean
	$(RM) $(NINJA_HOST_DIR)/.configured

$(pkg)-dirclean:
	$(RM) -r $(NINJA_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(NINJA_HOST_TARGET_BINARY)

$(TOOLS_FINISH)

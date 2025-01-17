$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_TREE_VERSION_ABANDON),1.8.0,2.2.1))
$(PKG)_SOURCE_DOWNLOAD_NAME:=$(if $(FREETZ_PACKAGE_TREE_VERSION_ABANDON),,unix-$($(PKG)_VERSION).tar.gz)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_HASH_ABANDON:=715d5d4b434321ce74706d0dd067505bb60c5ea83b5f0b3655dae40aa6f9b7c2
$(PKG)_HASH_CURRENT:=eb152b9b9b49c3ed9a08094f386ddc0aaddecce0ae45fbd58cb7680d0db4068a
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_TREE_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://gitlab.com/OldManProgrammer/unix-tree/-/archive/$($(PKG)_VERSION),https://mama.indstate.edu/users/ice/tree/src,ftp://mama.indstate.edu/linux/tree
### WEBSITE:=http://mama.indstate.edu/users/ice/tree/
### MANPAGE:=https://linux.die.net/man/1/tree
### CHANGES:=https://gitlab.com/OldManProgrammer/unix-tree/tags
### CVSREPO:=https://gitlab.com/OldManProgrammer/unix-tree
### SUPPORT:=fda77

$(PKG)_BINARY:=$($(PKG)_DIR)/tree
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/tree

$(PKG)_DEPENDS_ON += wget-host

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_TREE_VERSION_ABANDON),abandon,current)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TREE_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(TREE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TREE_TARGET_BINARY)

$(PKG_FINISH)

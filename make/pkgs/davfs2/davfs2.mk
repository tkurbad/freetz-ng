$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_DAVFS2_VERSION_ABANDON),1.5.2,1.6.1))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=be34a19ab57a6ea77ecb82083e9e4c1882e12b2de64257de567ad5ee7a17b358
$(PKG)_HASH_CURRENT:=ce3eb948ece582a51c934ccb0cc70e659839172717caff173f69a5e2af90c5c0
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_DAVFS2_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://download.savannah.gnu.org/releases/davfs2

$(PKG)_STARTLEVEL=50

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_DAVFS2_VERSION_ABANDON),abandon,current)

$(PKG)_MOUNT_BINARY:=$($(PKG)_DIR)/src/mount.davfs
$(PKG)_MOUNT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mount.davfs
$(PKG)_UMOUNT_BINARY:=$($(PKG)_DIR)/src/umount.davfs
$(PKG)_UMOUNT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/umount.davfs

$(PKG)_DEPENDS_ON += neon fuse
$(PKG)_LIBS := \$$(NEON_LIBS)

ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
$(PKG)_LIBS += -liconv
endif

$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_DAVFS2_REMOVE_WEBIF),etc/init.d/rc.davfs2 etc/default.davfs2 usr/lib/cgi-bin/davfs2.cgi)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DAVFS2_WITH_SSL
ifeq ($(strip $(FREETZ_PACKAGE_DAVFS2_WITH_SSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
endif
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DAVFS2_WITH_ZLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DAVFS2_VERSION_ABANDON

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_MOUNT_BINARY) $($(PKG)_UMOUNT_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DAVFS2_DIR) \
		LIBS="$(DAVFS2_LIBS)"

$($(PKG)_MOUNT_TARGET_BINARY): $($(PKG)_MOUNT_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_UMOUNT_TARGET_BINARY): $($(PKG)_UMOUNT_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_MOUNT_TARGET_BINARY) $($(PKG)_UMOUNT_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DAVFS2_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DAVFS2_MOUNT_TARGET_BINARY) $(DAVFS2_UMOUNT_TARGET_BINARY)

$(PKG_FINISH)

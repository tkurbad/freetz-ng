$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_LTRACE_VERSION_ABANDON),82c66409c7a93ca6ad2e4563ef030dfb7e6df4d4,0.8.1))
$(PKG)_SOURCE:=ltrace-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH_ABANDON:=49b881aa79388985b4fcd232fb00edb1a198a2f094ab00bcea8f543c4abf44e6
$(PKG)_HASH_CURRENT:=2e18c2a976db50da58788c742fccddfcb41029a00399c03f747733025442673f
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_LTRACE_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE_ABANDON:=git@https://github.com/dkogan/ltrace.git
$(PKG)_SITE_CURRENT:=https://gitlab.com/cespedes/ltrace/-/archive/$($(PKG)_VERSION)
$(PKG)_SITE:=$($(PKG)_SITE_$(if $(FREETZ_PACKAGE_LTRACE_VERSION_ABANDON),ABANDON,CURRENT))
### WEBSITE:=https://www.ltrace.org/
### MANPAGE:=https://linux.die.net/man/1/ltrace
### CHANGES:=https://gitlab.com/cespedes/ltrace/commits/main
### CVSREPO:=https://gitlab.com/cespedes/ltrace

$(PKG)_CATEGORY:=Debug helpers

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_LTRACE_VERSION_ABANDON),abandon,current)

$(PKG)_BINARY:=$($(PKG)_DIR)/ltrace
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ltrace

$(PKG)_CONFIGS            := libacl.so.conf libc.so.conf libc.so-types.conf libm.so.conf libpthread.so.conf libpthread.so-types.conf syscalls.conf
$(PKG)_CONFIGS_BUILD_DIR  := $($(PKG)_CONFIGS:%=$($(PKG)_DIR)/etc/%)
$(PKG)_CONFIGS_TARGET_DIR := $($(PKG)_CONFIGS:%=$($(PKG)_DEST_DIR)/usr/share/ltrace/%)

$(PKG)_DEPENDS_ON += libelf

$(PKG)_CONFIGURE_PRE_CMDS += ./autogen.sh;

# disable demangling support
$(PKG)_CONFIGURE_ENV += ac_cv_lib_iberty_cplus_demangle=no
$(PKG)_CONFIGURE_ENV += ac_cv_lib_stdcpp___cxa_demangle=no
$(PKG)_CONFIGURE_ENV += ac_cv_lib_supcpp___cxa_demangle=no

$(PKG)_CONFIGURE_OPTIONS += --with-libelf="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-libunwind=no

$(PKG)_CFLAGS := $(TARGET_CFLAGS)
ifeq ($(strip $(FREETZ_TARGET_GCC_13_MIN)),y)
$(PKG)_CFLAGS += -Wno-error=switch-unreachable
else
$(PKG)_CFLAGS += -Wno-error=maybe-uninitialized
endif

$(PKG)_LDFLAGS := $(TARGET_LDFLAGS)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LTRACE_DIR) \
		CFLAGS="$(LTRACE_CFLAGS)" \
		LDFLAGS="$(LTRACE_LDFLAGS)" \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_CONFIGS_BUILD_DIR): $($(PKG)_DIR)/etc/%: $($(PKG)_DIR)/.unpacked
	@touch $@

$($(PKG)_CONFIGS_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/share/ltrace/%: $($(PKG)_DIR)/etc/%
	$(INSTALL_FILE)

$(pkg):


$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_CONFIGS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LTRACE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(LTRACE_TARGET_BINARY) $(LTRACE_CONFIGS_TARGET_DIR)

$(PKG_FINISH)

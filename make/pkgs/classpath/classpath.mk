$(call PKG_INIT_BIN, 0.99)
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=f929297f8ae9b613a1a167e231566861893260651d913ad9b6c11933895fecc8
$(PKG)_SITE:=@GNU/$(pkg)
### WEBSITE:=https://www.gnu.org/software/classpath/
### MANPAGE:=https://developer.classpath.org/mediation/
### CHANGES:=https://www.gnu.org/software/classpath/downloads/downloads.html
### CVSREPO:=http://savannah.gnu.org/cvs/?group=classpath

$(PKG)_CLASSES_FILE_FULL:=glibj.zip
$(PKG)_CLASSES_FILE_MINI:=mini.jar
$(PKG)_CLASSES_FILE_NAME:=$(if $(FREETZ_PACKAGE_CLASSPATH_MINI),$($(PKG)_CLASSES_FILE_MINI),$($(PKG)_CLASSES_FILE_FULL))
$(PKG)_CLASSES_FILE:=$($(PKG)_DIR)/lib/$($(PKG)_CLASSES_FILE_NAME)
$(PKG)_TARGET_CLASSES_FILE:=$($(PKG)_DEST_DIR)/usr/share/classpath/$($(PKG)_CLASSES_FILE_NAME)

$(PKG)_LIBRARY_DIR:=/usr/lib/classpath
$(PKG)_LIBNAMES_SHORT:=io lang langmanagement langreflect net nio util
$(PKG)_LIBNAMES_LONG:=$(CLASSPATH_LIBNAMES_SHORT:%=libjava%.so.$($(PKG)_LIB_VERSION))
$(PKG)_LIBS_BUILD_DIR_SHORT:=io lang lang lang net nio util
$(PKG)_LIBS_BUILD_DIR:=$(join $(CLASSPATH_LIBS_BUILD_DIR_SHORT:%=$($(PKG)_DIR)/native/jni/java-%/.libs/),$(CLASSPATH_LIBNAMES_LONG))
$(PKG)_LIBS_STAGING_DIR:=$(CLASSPATH_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)$(CLASSPATH_LIBRARY_DIR)/%)
$(PKG)_LIBS_TARGET_DIR:=$(CLASSPATH_LIBNAMES_LONG:%=$($(PKG)_DEST_DIR)$(CLASSPATH_LIBRARY_DIR)/%)

$(PKG)_DEPENDS_ON += fastjar-host
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
endif
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CLASSPATH_MINI

$(PKG)_CONFIGURE_ENV += HAVE_INET6_I_KNOW_IT_BETTER=$(if $(FREETZ_TARGET_IPV6_SUPPORT),yes,no)
$(PKG)_CONFIGURE_ENV += JAVAC=ecj

$(PKG)_CONFIGURE_OPTIONS += --disable-alsa
$(PKG)_CONFIGURE_OPTIONS += --disable-gconf-peer
$(PKG)_CONFIGURE_OPTIONS += --disable-gjdoc
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk-peer
$(PKG)_CONFIGURE_OPTIONS += --disable-gmp
$(PKG)_CONFIGURE_OPTIONS += --disable-examples
$(PKG)_CONFIGURE_OPTIONS += --disable-plugin
$(PKG)_CONFIGURE_OPTIONS += --disable-qt-peer
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --disable-Werror


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_CLASSES_FILE) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CLASSPATH_DIR)
	cp $(CLASSPATH_MAKE_DIR)/mini.classlist $(CLASSPATH_DIR)/lib;
	( cd $(CLASSPATH_DIR)/lib; fastjar -Mcf $(CLASSPATH_CLASSES_FILE_MINI) -@ < mini.classlist );

$($(PKG)_TARGET_CLASSES_FILE): $($(PKG)_CLASSES_FILE)
	$(INSTALL_FILE)
ifeq ($(strip $(FREETZ_PACKAGE_CLASSPATH_MINI)),y)
	ln -sf $(CLASSPATH_CLASSES_FILE_MINI) $(dir $@)/$(CLASSPATH_CLASSES_FILE_FULL)
endif

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(CLASSPATH_DIR)/native/jni \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" install
	$(PKG_FIX_LIBTOOL_LA) \
		$(CLASSPATH_LIBNAMES_SHORT:%=$(TARGET_TOOLCHAIN_STAGING_DIR)$(CLASSPATH_LIBRARY_DIR)/libjava%.la)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_DIR)$(CLASSPATH_LIBRARY_DIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)$(CLASSPATH_LIBRARY_DIR)/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_CLASSES_FILE) $($(PKG)_LIBS_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(CLASSPATH_DIR) clean

$(pkg)-uninstall:
	$(RM) \
		$(CLASSPATH_DEST_DIR)/usr/share/classpath/$(CLASSPATH_CLASSES_FILE_FULL) \
		$(CLASSPATH_DEST_DIR)/usr/share/classpath/$(CLASSPATH_CLASSES_FILE_MINI) \
		$(CLASSPATH_DEST_DIR)$(CLASSPATH_LIBRARY_DIR)/libjava*.so*

$(PKG_FINISH)

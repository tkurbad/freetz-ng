[ "$FREETZ_SEPARATE_AVM_UCLIBC" == "y" ] && return 0
[ "$FREETZ_AVM_VERSION_07_0X_MIN" = "y" -a "$FREETZ_AVM_HAS_USB_HOST" = "y" ] || return
echo1 "dropping (unnecessary) libresolv/libnsl dependencies from AVM binaries/libraries"

[ -e ${FILESYSTEM_MOD_DIR}/lib/libsamba.so ] && ${PATCHELF_TARGET} --remove-needed libresolv.so.1 ${FILESYSTEM_MOD_DIR}/lib/libsamba.so
[ -e ${FILESYSTEM_MOD_DIR}/sbin/ftpd       ] && ${PATCHELF_TARGET} --remove-needed libresolv.so.1 ${FILESYSTEM_MOD_DIR}/sbin/ftpd
[ -e ${FILESYSTEM_MOD_DIR}/sbin/ftpd       ] && ${PATCHELF_TARGET} --remove-needed libnsl.so.1    ${FILESYSTEM_MOD_DIR}/sbin/ftpd


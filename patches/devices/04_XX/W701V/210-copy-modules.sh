[ "$FREETZ_COPY_MODULES" == "y" ] || return 0

echo1 "copying modules from tk-firmware"
"$TAR_BBA" -c -C "${DIR}/.tk/original/filesystem/lib/modules/2.6.13.1-ohio" --exclude=drivers/usb . | "$TAR_BBA" -x -C "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio"


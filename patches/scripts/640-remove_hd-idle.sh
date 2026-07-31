[ "$FREETZ_REMOVE_HD_IDLE" == "y" ] || return 0
echo1 "removing hd-idle binary"

rm_files "${FILESYSTEM_MOD_DIR}/sbin/hd-idle"

echo1 "patching rc.conf"
modsed "s/CONFIG_USB_STORAGE_SPINDOWN=.*$/CONFIG_USB_STORAGE_SPINDOWN=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"


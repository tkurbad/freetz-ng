[ "$FREETZ_REMOVE_UMTSD" == "y" ] || return 0
echo1 "remove umtsd files"

rm_files \
  "${MODULES_DIR}/kernel/drivers/usb/serial/option.ko" \
  "${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-gsm-tty" \
  "${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-gsm-usb" \
  "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libgsm.so" \
  "${FILESYSTEM_MOD_DIR}/usr/bin/umtsd" \
  "${FILESYSTEM_MOD_DIR}/usr/bin/csvd" \
  "${FILESYSTEM_MOD_DIR}/usr/www/all/assis/internet_umts.lua"

if [ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" ]; then
	rm_files \
	  "${FILESYSTEM_MOD_DIR}/etc/udev/rules.d/??-mobiled.rules" \
	  "${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libmobiled.so" \
	  "${FILESYSTEM_MOD_DIR}/usr/share/configd/C20_mobiled.so" \
	  "${FILESYSTEM_MOD_DIR}/usr/lua/mobile_*.lua"

	if [ "$FREETZ_AVM_VERSION_07_2X_MIN" == "y" ]; then
		# configd execs mobiled
		echo -e '#!/bin/sh\nexit 0' > "${FILESYSTEM_MOD_DIR}/bin/mobiled"
		supervisor_delete_service "mobiled"
	else
		rm_files \
		  "${FILESYSTEM_MOD_DIR}/bin/mobiled" \
		  "${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-mobiled"
		modsed \
		  '/\/etc\/hotplug\/udev-mobiled/d' \
		  "${FILESYSTEM_MOD_DIR}/etc/udev/rules.d/??-usb*.rules"
	fi

	modern_remove mobile
fi

echo1 "patching rc.conf"
modsed "s/CONFIG_USB_GSM=.*$/CONFIG_USB_GSM=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
modsed "s/CONFIG_USB_GSM_VOICE=.*$/CONFIG_USB_GSM_VOICE=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"


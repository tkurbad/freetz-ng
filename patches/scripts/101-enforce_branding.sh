[ "$FREETZ_ENFORCE_BRANDING_none" != "y" ] || return 0
[ "$FREETZ_AVM_VERSION_06_5X_MIN" == "y" ] || return 0
supported_brandings="$(supported_brandings)"
firmware_version="$(firmware_version $supported_brandings)"

echo1 "enforcing branding '${firmware_version}'"
[ -z "${firmware_version}" ] && error 1 "Selected branding is not supported by this firmware"

for oem in ${supported_brandings}; do
	[ "${firmware_version}" != "$oem" ] && continue
	echo2 "hardcoding branding in /etc/init.d/rc.conf"
	modsed "s|^\([ \t]*export OEM\)\$|\1=${firmware_version}|" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf" "export OEM=${firmware_version}\$"
	return 0
done

error 1 "Selected branding '${firmware_version}' is not supported by this firmware"


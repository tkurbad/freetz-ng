[ "$FREETZ_PACKAGE_INETD" == "y" -a "$FREETZ_AVM_HAS_INETD" == "y" ] || return 0
echo1 "removing AVM inetd"

rm_files "${FILESYSTEM_MOD_DIR}/bin/inetdctl" # AVM wrapper / starter script for ftpd, samba and webdav
rm_files "${FILESYSTEM_MOD_DIR}/etc/inetd.conf" # AVM Symlink to /var/tmp/inetd.conf

# don't start inetd
if [ -e "${FILESYSTEM_MOD_DIR}/lib/systemd/system/inetd.service" ]; then
	supervisor_delete_service "inetd"
elif [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/S75-inetd" ]; then
	rm_files "${FILESYSTEM_MOD_DIR}/etc/init.d/S75-inetd"
else
	count=$(grep -a "usr/sbin/inetd" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S" | wc -l)
	if [ $count -gt 1 ]; then
		modsed '/if \[ \-x \/usr\/sbin\/inetd \] \; then/!b;:x1;/fi/!{N;bx1;};d' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	else
		modsed '/^\/usr\/sbin\/inetd.*$/echo INTERCHANGED: &/' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	fi
fi


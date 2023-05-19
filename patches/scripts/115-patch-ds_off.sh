
echo1 "creating rc.mod hook"

if [ -n "$SYSTEMD_CORE_MOD_DIR" ]; then
	dsfile="$SYSTEMD_CORE_MOD_DIR/99-zzz-rcmod"
	rcfile=""
elif [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh" ]; then
	dsfile="${FILESYSTEM_MOD_DIR}/etc/init.d/E99-zzz-rcmod"
	rcfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.tail.sh"
else
	dsfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
	rcfile="${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
fi

# Emergency stop switch for execution of Freetz as a whole
[ ! -e "$dsfile" ] && echo '#!/bin/sh' > "$dsfile" && echo2 "adding ${dsfile#$FILESYSTEM_MOD_DIR}"
echo '[ "$ds_off" == "y" ] || nohup /etc/init.d/rc.mod 0</dev/null 1>/dev/null 2>&1 &' >> "$dsfile"
chmod +x "$dsfile"

# Emergency stop switch for execution of debug.cfg
[ -n "$rcfile" ] && modsed -r 's,(if[ \t]+)([!][ \t]*(/usr/bin/)?checkempty[ \t]+/var/flash/debug[.]cfg),\1[ "$dbg_off" != "y" ] \&\& \2,' $rcfile


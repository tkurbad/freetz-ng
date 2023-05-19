[ "$FREETZ_AVM_HAS_PLUGINS_UPDATE" == "y" ] || return 0
echo1 "some changes for plugins"

start_plugin="${FILESYSTEM_MOD_DIR}/sbin/start_plugin.sh"
if [ -e "${start_plugin}" ]; then

	# 'init-done' is rc.tail.sh spelling, 'init_done' is start_plugin.sh spelling
	echo2 "start_plugin.sh: support both 'init-done' & 'init_done' spellings"
	modsed -r 's,(init_done\)),init-done|\1,' "${start_plugin}"

	echo2 "start_plugin.sh: forcing loop module loading"
	modsed -r '/^[a-z]+_mount\)/ a\
modprobe loop' "${start_plugin}"

fi


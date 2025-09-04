[ "$FREETZ_AVM_VERSION_08_2X_MIN" == "y" ] || return 0
[ -L "${HTML_LANG_MOD_DIR}/home/home.lua" ] || return 0
echo1 "fixing home.lua symlink"

if [ "$(readlink "${HTML_LANG_MOD_DIR}/home/home.lua")" != "/usr/www//avm/index.lua" ]; then
	error 1 "Unknown symlink target: $(readlink "${HTML_LANG_MOD_DIR}/home/home.lua")"
fi

ln -s -f ../index.lua "${HTML_LANG_MOD_DIR}/home/home.lua"


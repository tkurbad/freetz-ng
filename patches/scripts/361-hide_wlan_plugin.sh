[ "$FREETZ_AVMPLUGINS_INTEGRATE" == "y" ] || return 0
[ "$FREETZ_AVM_HAS_PLUGIN_WLAN" != "y" ] && return 0
[ "$FREETZ_AVMPLUGINS_WLAN" == "y" ] && return 0
echo1 "hiding WLAN plugin"

if [ "$FREETZ_AVM_VERSION_06_5X_MAX" == "y" ]; then

	# patcht WLAN > Funknetz
	modsed \
	  's/^pageData\["wSet"\] =/& false and /g' \
	  "${MENU_DATA_LUA}"

	# patcht WLAN > Zeitschaltung
	modsed \
	  's/^pageData\["wTime"\] =/& false and /g' \
	  "${MENU_DATA_LUA}"

fi

if [ "$FREETZ_AVM_VERSION_06_8X_MIN" == "y" ]; then

	# patcht WLAN > Funknetz
	modsed \
	  's/ = pageData\["wSet"\] /&and false /g' \
	  "${MENU_DATA_LUA}"

	# patcht WLAN > Zeitschaltung
	modsed \
	  's/ = pageData\["wTime"\] /&and false /g' \
	  "${MENU_DATA_LUA}"

fi

# patcht Übersicht > Anschlüsse
modsed \
  's/^if (data.wlan/if (false \&\& data.wlan/g' \
  "${HTML_LANG_MOD_DIR}/home/home.js"


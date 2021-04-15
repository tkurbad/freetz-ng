[ "$FREETZ_REMOVE_HELP" == "y" ] || return 0
echo1 "removing help"

# from m*.* mod

HELP_DIR="${HTML_LANG_MOD_DIR}/help"

if [ -e "${HELP_DIR}" ]; then
	# remove new lua help
	rm_files "${HELP_DIR}/hilfe*" "${HELP_DIR}/recht*"
	sedfile="${HELP_DIR}/home.html"
	[ -e "$sedfile" ] && modsed 's/local g_txt/local g_txt_removed/' "$sedfile"
else
	echo1 "${HTML_SPEC_MOD_DIR}"
	rm_files "${HTML_SPEC_MOD_DIR}/help"
	find "${HTML_SPEC_MOD_DIR}/menus" -type f |
	  xargs sed -s -i -e '/var:menuHilfe/d'
	if [ -e "${HTML_SPEC_MOD_DIR}/global.inc" ]; then
		modsed '/setvariable var:txtHelp/d' "${HTML_SPEC_MOD_DIR}/global.inc"
	fi
	find "${HTML_SPEC_MOD_DIR}/.." -name "*.html" -type f |
	  xargs sed -s -i -e '/<input type="button" onclick="uiDoHelp/d'

	# Remove functions "uiDoHelp*"
	find "${HTML_SPEC_MOD_DIR}/.." -name '*.js' -type f |
	  xargs -I '{}' "$TOOLS_DIR/developer/remove_js_function.sh" "{}" "uiDoHelp[[:alpha:]]*"

	# Remove functions "jslPopHelp*"
	find "${HTML_SPEC_MOD_DIR}/js" -name '*.js' -type f |
	  xargs -I '{}' "$TOOLS_DIR/developer/remove_js_function.sh" "{}" "jslPopHelp[[:alpha:]]*"
fi


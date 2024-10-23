[ "$FREETZ_PATCH_COCKPIT_INTERNET" == "y" ] || return 0
echo1 "applying cockpit internet connection patch"

cockpit_pruner "cockpit__visualization-container"


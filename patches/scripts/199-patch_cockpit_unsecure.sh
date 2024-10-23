[ "$FREETZ_PATCH_COCKPIT_UNSECURE" == "y" ] || return 0
echo1 "applying cockpit unsecure settings patch"

cockpit_pruner "osInformations"


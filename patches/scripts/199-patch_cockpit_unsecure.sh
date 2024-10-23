[ "$FREETZ_PATCH_COCKPIT_UNSECURE" == "y" ] || return 0
echo1 "applying cock pit unsecure settings patch"

cockpit_pruner "osInformations"


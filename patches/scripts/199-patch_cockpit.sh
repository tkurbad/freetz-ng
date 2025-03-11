
if [ "$FREETZ_PATCH_COCKPIT_UNSECURE" == "y" ]; then
	echo1 "applying cockpit unsecure settings patch"
	cockpit_pruner "osInformations"
fi

if [ "$FREETZ_PATCH_COCKPIT_CONNECTION" == "y" ]; then
	echo1 "applying cockpit connection graphics patch"
	cockpit_pruner "cockpit__visualization-container"
fi

if [ "$FREETZ_PATCH_COCKPIT_INTERNET" == "y" ]; then
	echo1 "applying cockpit internet info patch"
	cockpit_pruner "cockpit__internet-header"
fi

if [ "$FREETZ_PATCH_COCKPIT_HOMENET" == "y" ]; then
	echo1 "applying cockpit homenet info patch"
	cockpit_pruner "cockpit__homenet-header"
fi

if [ "$FREETZ_PATCH_COCKPIT_UPDATE" == "y" ]; then
	echo1 "applying cockpit update check patch"
	cockpit_pruner "cockpit__homenet-info"
fi


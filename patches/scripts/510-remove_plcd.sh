[ "$FREETZ_REMOVE_PLCD" == "y" ] || return 0
echo1 "removing plcd files"

rm_files \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/E50-plcd" \
  "${FILESYSTEM_MOD_DIR}/sbin/plcd" \
  "${FILESYSTEM_MOD_DIR}/usr/sbin/plcd" \
# "${FILESYSTEM_MOD_DIR}/lib/libmesh_plcservice.so"

if [ "$FREETZ_AVM_VERSION_08_2X_MIN" == "y" ]; then
	supervisor_replace_service "plcd"
else
	supervisor_delete_service "plcd"
fi


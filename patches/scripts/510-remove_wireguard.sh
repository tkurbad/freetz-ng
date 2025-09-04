[ "$FREETZ_REMOVE_AVM_WIREGUARD" == "y" ] || return 0
echo1 "removing WireGuard files"

rm_files \
  "${MODULES_DIR}/extra/wireguard.ko" \
  "${MODULES_DIR}/kernel/drivers/net/wireguard/wireguard.ko" \
  "${FILESYSTEM_MOD_DIR}/bin/vpnd" \
  "${FILESYSTEM_MOD_DIR}/bin/wg" \
  "${FILESYSTEM_MOD_DIR}/bin/wg-addmaster" \
  "${FILESYSTEM_MOD_DIR}/bin/wg-addslave" \
  "${FILESYSTEM_MOD_DIR}/bin/wg-init" \
  "${FILESYSTEM_MOD_DIR}/bin/wg-removepeer" \
  "${FILESYSTEM_MOD_DIR}/bin/wg-utils" \
  "${FILESYSTEM_MOD_DIR}/lib/libwireguard.so"

supervisor_delete_service "vpnd"

#WebUI is patched by selected remove-vpn


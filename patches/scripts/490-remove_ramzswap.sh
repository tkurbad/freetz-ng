[ "$FREETZ_REMOVE_RAMZSWAP" == "y" ] || return 0
echo1 "removing ramzswap files"

rm_files \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/S40-swap" \
  "${MODULES_DIR}/kernel/lib/lzo/lzo_compress.ko" \
  "${MODULES_DIR}/kernel/lib/lzo/lzo_decompress.ko" \
  "${MODULES_DIR}/kernel/drivers/block/compcache/ramzswap.ko"

echo1 "patching rc.conf"
modsed "s/CONFIG_SWAP=.*$/CONFIG_SWAP=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"


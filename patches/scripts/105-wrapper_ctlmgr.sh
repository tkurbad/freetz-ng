[ "$FREETZ_AVM_HAS_AVMCTLMGR_PRELOAD" == "y" ] || return 0
echo1 "preparing ctlmgr wrapper"

# Since FOS 7.5x /lib/ in not into the search path of ctlmgr
create_LD_PRELOAD_wrapper /usr/bin/ctlmgr /lib/libctlmgr.so


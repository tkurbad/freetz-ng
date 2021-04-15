[ "$FREETZ_REMOVE_WLAN" == "y" ] || return 0
echo1 "removing WLAN files"

rm_files $(find ${FILESYSTEM_MOD_DIR}/lib/modules -name '*wireless*')
rm_files $(find ${FILESYSTEM_MOD_DIR} ! -name '*.cfg' -a -name '*wlan*' | grep -Ev "^${FILESYSTEM_MOD_DIR}/(dev|oldroot|proc|sys|var|usr\/lua)/")
rm_files \
  ${FILESYSTEM_MOD_DIR}/lib/modules/fw_dcrhp_1150_ap.bin \
  ${FILESYSTEM_MOD_DIR}/sbin/hostapd \
  ${FILESYSTEM_MOD_DIR}/sbin/wstart \
  ${FILESYSTEM_MOD_DIR}/sbin/wpa_supplicant \
  ${FILESYSTEM_MOD_DIR}/usr/bin/wpa_authenticator \
  ${FILESYSTEM_MOD_DIR}/sbin/avmstickandsurf \
  ${FILESYSTEM_MOD_DIR}/usr/bin/iwpriv \
  ${FILESYSTEM_MOD_DIR}/usr/bin/iwconfig \
  ${FILESYSTEM_MOD_DIR}/usr/share/ctlmgr/libwlan.so \
  ${FILESYSTEM_MOD_DIR}/etc/hotplug/udev-avmwlan-usb

echo1 "patching webif files"

menu2html_remove wlan
modern_remove wSet
modern_remove chan

# patcht Uebersicht > Anschluesse
sedfile="${HTML_LANG_MOD_DIR}/home/home.lua"
if [ -e $sedfile ]; then
	modsed "s/config.WLAN.is_double_wlan/false and &/" $sedfile
fi

# patcht System > Nachtschaltung > Klingelsperre aktivieren
sedfile="${HTML_SPEC_MOD_DIR}/system/nacht.html"
if [ -e $sedfile ]; then
	modsed '/id="uiViewUseNachtWlan"/{N;//d}' $sedfile
	modsed '/.*id="uiViewUseWlanForcedOff".*/d' $sedfile
fi

# patcht Heimnetz > Netzwerk > Netzwerkeinstellungen > IPv4-Adressen
sedfile="${HTML_LANG_MOD_DIR}/net/boxnet.lua"
[ -e $sedfile ] && modsed 's/config.WLAN/0/g' $sedfile

# patcht Internet > Zugangsdaten > Internetzugang
sedfile="${HTML_LANG_MOD_DIR}/internet/internet_settings.lua"
if [ "$FREETZ_AVM_VERSION_06_0X_MAX" == "y" -a -e $sedfile ]; then
	modsed '/^require"wlanscan"$/d' $sedfile
	modsed '/^wlanscanOnload.*$/d' $sedfile
fi

# patcht Assistenten > Internetzugang einrichten (ab 07.x)
sedfile="${HTML_LANG_MOD_DIR}/assis/internet_dsl.lua"
if [ "$FREETZ_AVM_VERSION_07_0X_MIN" == "y" -a -e $sedfile ]; then
	modsed '/^updateOmaWlanSecurity(<?lua box.out(js.quoted(g_var.staenc or "")) ?>);$/d' $sedfile
fi

# patcht Heimnetz > Netzwerk > Geraete und Benutzer
sedfile="${HTML_LANG_MOD_DIR}/net/network_user_devices.lua"
[ -e $sedfile ] && modsed 's/&& <?lua box.js(tostring(g_dev.wlan_count<2)) ?>//g' $sedfile

# fix AVM-VPN: Set WLAN to "disabled" value "0". Otherwise ctlmgr_ctl reports "no emu" or "" (nothing).
for sedfile in $(grep -R -l  "wlan:settings/ap_enabled" ${HTML_LANG_MOD_DIR}/* 2>/dev/null); do
	modsed 's#box.query("wlan:settings/ap_enabled[^"]*")#"0"#g ; s#<? query wlan:settings/ap_enabled[^ ]* ?>#0#g ; s#{ sz_query = "wlan:settings/ap_enabled"}#{ sz_value = "0" }#g' $sedfile
done

echo1 "patching rc.conf"
modsed "s/CONFIG_WLAN=.*$/CONFIG_WLAN=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"


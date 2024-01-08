. /usr/lib/cgi-bin/mod/modlibcgi

show_log() {
	local log="$1"
	local desc="$2"
	if [ -e "$log" ] && [ -n "$(head -n1 $log)" ]; then
		logg=true
		echo "<h1><a href='$SCRIPT_NAME$log'>${desc:-$log}</a></h1>"
		echo "<pre class='log ${class:-small}'>"
		html < "$log" | highlight
		echo '</pre>'
	fi
}

unset class
do_log() {
	show_log "$1" "$2"
}

if [ -n "$PATH_INFO" ]; then
	class="full"
	do_log() {
		[ "$PATH_INFO" = "$1" ] && show_log "$1" "$2"
	}
fi

case "$3" in
	logs_avm*)
		logg=false

		aicmd ctlmgr sessions show 2>/dev/null | sed -rn 's/^ +//p' > /tmp/.logs.sessions.txt
		[ -s /tmp/.logs.sessions.txt ] || msgsend ctlmgr sessions
		[ "0$(wc -l /tmp/.logs.sessions.txt 2>/dev/null | sed 's/ .*//')" -gt 2 ] || rm -f /tmp/.logs.sessions.txt
		do_log /tmp/.logs.sessions.txt "WEB-Sessions"
		rm -f /tmp/.logs.sessions.txt

		[ -x "$(which svctl)" ] && svctl status 2>&1 | sed 's/\.service//g;s/, status/ /g;s/$/./g' > /tmp/.logs.svctl.txt
		do_log /tmp/.logs.svctl.txt "AVM-Supervisor"
		rm -f /tmp/.logs.svctl.txt

		do_log /proc/avm/wdt "AVM-Watchdog"
		do_log /proc/kdsld/dsliface/internet/ipmasq/pcp44 "PCP-Sessions"

		[ -x "$(which showdsldstat)" ] && showdsldstat > /tmp/.logs.dsldstat.txt 2>&1
		do_log /tmp/.logs.dsldstat.txt "AVM-DsldStat"
		rm -f /tmp/.logs.dsldstat.txt

		[ -x "$(which cableinfo)" ] && ctlmgr_ctl u showdocsisstate > /tmp/.logs.docsisstate.txt 2>&1
		do_log /tmp/.logs.docsisstate.txt "AVM-DocsisState"
		rm -f /tmp/.logs.docsisstate.txt

		for x in /sys/fs/pstore/*; do do_log $x; done

		do_log /proc/avm/log_sd/crash
		do_log /proc/avm/log_sd/crash2
		do_log /proc/avm/log_sd/panic
		do_log /proc/avm/log_sd/panic2

		do_log /var/log/crash2
		do_log /var/log/debug2
		do_log /var/log/panic2

		do_log /var/flash/crash.log
		do_log /var/flash/panic
		do_log /var/log/messages

		do_log /var/log/dslmonitor.txt

		do_log /var/tmp/pbook.err

		do_log /var/tmp/mserv4.log
		do_log /var/tmp/webdav.log

		do_log /var/tmp/cloudcds.log
		do_log /var/tmp/lgpm.log
		do_log /var/tmp/tcloud.log

		$logg || echo "<br><h1>$(lang de:"Keine Logdateien gefunden" en:"No log files found")!</h1>"
		;;
	*)
		do_log /var/log/mod_lang.log
		do_log /var/log/mod_load.log
		do_log /var/log/mod_net.log
		do_log /var/log/mod_voip.log
		do_log /var/log/mod.log
		do_log /var/log/mod_swap.log
		do_log /var/log/rc_custom.log
		do_log /var/log/debug_cfg.log
		do_log /var/log/onlinechanged.log
		do_log /var/log/external.log
		do_log /var/log/mod_mount.log
		;;
esac


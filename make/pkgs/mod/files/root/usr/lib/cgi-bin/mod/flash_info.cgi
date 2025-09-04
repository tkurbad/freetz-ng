#!/bin/sh



# include environment variables
. /bin/env.mod.rcconf


sec_begin "$(lang de:"MTDs" en:"MTDs")"
echo "<dl class='info'>"
echo "<pre class='log.unlimited'>"
(
mlen() { local x=$3; while [ ${#x} -lt $1 ]; do x="$2$x"; done; echo "$x"; }
echo "Device   Bytes       Kilobytes     Megabytes   Name"
mlen 69 '='
grep ^mtd /proc/mtd | while read a b c d; do
x="$(mlen 9 ' ' $((0x$b/1024)) )";
y="$((0x$b*1000/1024/1024))";
r="$(mlen 3 '0' ${y:0-3} )";
l="${y::-3}";
l="$(mlen 5 ' ' ${l:-0} )";
echo "$a   $b  $x KB  ${l:-x},${r:-0} MB   ${d//\"/}";
done
) | html
echo '</pre>'
echo "</dl>"
sec_end


sec_begin "$(lang de:"Dateisysteme" en:"Filesystems")"
echo "<dl class='info'>"
echo "<pre class='log.unlimited'>"
df -h | html
echo '</pre>'
echo "</dl>"
sec_end


if which ubinfo >/dev/null; then
sec_begin "$(lang de:"UBI-Info" en:"UBI info")"
echo "<dl class='info'>"
echo "<pre class='log.unlimited'>"
ubinfo -a | html
echo '</pre>'
echo "</dl>"
sec_end
fi



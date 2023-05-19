#! /usr/bin/env bash
# fitimg unpacker & scanner
# uses: [fdtdump] [dtc] fdtget [dumpimage] fitdump [diff]
MYPWD="$(dirname $(realpath $0))"
FTDIR="$MYPWD/fit"

# $1: .itb-file to scan
# $2: create kernel & filesystem links and args & date files in this dir
analyze() {
	local PART COUNT=0 FILE="$1" LINK="$2"
	KPART= FPART= KTYPE= FTYPE= KNAME= FNAME= XARGS=
	for PART in $($FTDIR/fdtget $FILE /images -l); do
		let COUNT++
		[ "${PART/TZ_HW/}" != "$PART" ] && continue # TrustZone
		[ "${PART/_HW0/}"  != "$PART" ] && continue # other CPU
		[ "${PART/HW273/}" != "$PART" ] && continue # also 5590
		TYPE="$($FTDIR/fdtget $FILE /images/$PART 'type')"
		[ "$TYPE" == "flat_dt"  ] && continue
		if   [ "$TYPE" == "filesystem" -o "$TYPE" == "ramdisk" ]; then
			FPART="$COUNT"; FTYPE="$TYPE"; FNAME="$PART"; XARGS="$($FTDIR/fdtget $FILE /images/$PART 'avm,kernel-args' 2>/dev/null)"
		elif [ "$TYPE" == "kernel"     -o "$TYPE" == "avm,fit" ]; then
			KPART="$COUNT"; KTYPE="$TYPE"; KNAME="$PART"
		else
			echo "TYPE unknown: $TYPE"; return 1
		fi
	done

	if [ -n "$LINK" ]; then
		echo -n "$XARGS" > "$LINK/args.txt"
		$FTDIR/fdtget "$FILE" / 'timestamp' > "$LINK/date.txt"
		# root
		image="$(printf 'image.%03u' "$FPART")"
		echo -n "$image"  >  "$LINK/filesystem.txt"
		mv "$LINK/$image" "$LINK/filesystem.image"
		ln -sf "filesystem.image" "$LINK/$image"
		# kern
		image="$(printf 'image.%03u' "$KPART")"
		echo -n "$image"  >  "$LINK/kernel.txt"
		mv "$LINK/$image" "$LINK/kernel.image"
		ln -sf "kernel.image" "$LINK/$image"
	fi
}

# $1: source file to unpack
# $2: destination dir
unpack() {
	local c='0' FILE="$1" OUTP="${2:-.}"
	[ ! -e "$FILE" ] && echo "File $FILE does not exist" && exit 1
	mkdir -p "$OUTP"
#	$MYPWD/yf/fit_tools/fit-remove-avm-header.sh "$FILE" > "$OUTP/image.itb" 2>/dev/null || cat "$FILE" > "$OUTP/image.itb"
#	$FTDIR/fitdump --output="$OUTP" "$OUTP/image.itb"
	tail -c +73 "$FILE" | tee "$OUTP/image.itb" | $FTDIR/fitdump --output="$OUTP" -
#	$FTDIR/dtc -I dtb -O dts "$OUTP/image.itb" | tee "$OUTP/image.dts" | sed "s/^[ \t]*data = .*/XDATAXSEQUENCEX/g" > "$OUTP/image.its"
#	[ ! -s  "$OUTP/image.its" ] && rm -f "$OUTP"/image.* && exit 1
#	while grep -q "XDATAXSEQUENCEX" "$OUTP/image.its"; do
#		image="$(printf 'image.%03u' "$(($c+1))")"
#		sed "0,/XDATAXSEQUENCEX/s//\t\t\tdata = \/incbin\/(\"$image\");/" -i "$OUTP/image.its"
#		$FTDIR/dumpimage "$OUTP/image.itb" -T flat_dt -p "$c" -o "$OUTP/$image" >/dev/null
#		let c++
#	done
	analyze "$OUTP/image.itb" "$OUTP"
}

# $1: directory with *.itb to scan
scandir() {
	local DIR="${1:-.}"
	for FILE in $DIR/*; do
		[ -d "$FILE" ] && continue
		echo -e "\n ## $FILE"
		analyze "$FILE"
		[ -n "$FNAME$KNAME$XARGS" ] || continue
		                   echo -e "filesystem   $FNAME"
		                   echo -e "kernel       $KNAME"
		[ -n "$XARGS" ] && echo -e "kernel-args  $XARGS"
	done
}

# main
case "$1" in
	u|unpack)	unpack  "$2" "$3" ;;
	s|scandir)	scandir "$2"      ;;
	o|original)	$FTDIR/fdtdump $MYPWD/../build/original/fit-image/image.itb | grep -vE 'data = ' ;;
	m|modified)	$FTDIR/fdtdump $MYPWD/../build/modified/fit-image/image.itb | grep -vE 'data = ' ;;
	d|diff)		diff -Naur \
			  <($FTDIR/dtc -I dtb -O dts $MYPWD/../build/o*/fit-image/image.itb | grep -vE 'data = |^$') \
			  <($FTDIR/dtc -I dtb -O dts $MYPWD/../build/m*/fit-image/image.itb | grep -vE 'data = |^$') ;;
	*)		echo "Usage: $0 <unpack|scandir|original|modified|diff>" ;;
esac



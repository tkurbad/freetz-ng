#! /usr/bin/env bash
# shows all devices sorted by firmware-layout
MYPWD="$(dirname $(realpath $0))"

TWS="$(printf '\342\200\212')"
case "$1" in
	p|produkt)	SORT="cat" ;;
	s|stats)	SORT="sort -t- -k2" ;;
	"")		SORT="cat" ;;
	*)		echo "Usage: ${0##*/} [produkt|stats]"; exit 1 ;;
esac

for FWL in $(sed -rn 's/.* FREETZ_AVM_HAS_FWLAYOUT_//p' "$MYPWD/../config/.img/separate/"*.in | sort -u); do
	echo "# Gen$FWL"
	for IN in $(grep FREETZ_AVM_HAS_FWLAYOUT_$FWL "$MYPWD/../config/.img/separate/"*.in -l); do
		HWREV="$(grep " FREETZ_AVM_PROP_HWREV$" -A2 "$IN" | sed -rn 's/.* "(.*)"$/\1/p')"
		[ -z "$HWREV" ] && IN="${IN%.in}*.in"  # && echo "INHERITED: $IN"
		for INN in $IN; do
			[ -z "$HWREV" ] && HWREV="$(grep " FREETZ_AVM_PROP_HWREV$" -A2 $INN | sed -rn 's/.* "(.*)"$/\1/p')"
			[ -z "$HWREV" ] && echo "BAD: $INN" && continue
			NAME="$(grep " FREETZ_AVM_PROP_NAME$" -A2 ${INN%.in}*.in | sed -rn 's/.* "(.*)"$/\1/p' | tail -n1)"
			[ -z "$NAME" ] && echo "NON: $INN" && continue
			PRODUKT="$(grep " FREETZ_AVM_PROP_PRODUKT$" -A2 ${INN%.in}*.in | sed -rn 's/.* "(.*)"$/\1/p' | tail -n1)"
			[ -z "$PRODUKT" ] && echo "NON: $INN" && continue
			SYMB="$(grep "^if " "${INN}" | sed -rn 's/^if \(*([^ ]*).*/\1/p')"
			case "$1" in
				p|produkt)	echo "${PRODUKT%x} - $NAME" | sed "s/$TWS/ /g" ;;
				s|stats)	echo "$SYMB - $NAME" | sed "s/$TWS/ /g" ;;
				"")		echo "$HWREV - $NAME" | sed "s/$TWS/ /g" ;;
			esac
			break
		done
	done | sort -n | uniq |  tac|awk -F"[. ]" '!a[$1]++'|tac | $SORT
done

exit 0


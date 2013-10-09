#!/bin/sh

COLOR_NC='\e[0m'
COLOR_GREEN='\e[0;32m'
COLOR_RED='\e[0;31m'

COLOR_GOOD=$COLOR_GREEN
COLOR_BAD=$COLOR_RED

color_echo() {
	if [ "$CLICOLOR" = 1 ]; then
		/bin/echo -e "${1}: ${3}${2}${COLOR_NC}"
	else
		echo "$1: $2"
	fi
}

for i in ../schema/*.sql; do
	[ -e "$i" ] || continue

	f=`echo "$i" | awk -F'/' '{print $NF}'`

	grep -q "$f" setupDB.sh

	if [ $? -eq 0 ]; then
		color_echo "$f" "included" "$COLOR_GOOD"
	else
		color_echo "$f" "MISSING!" "$COLOR_BAD"
	fi
done

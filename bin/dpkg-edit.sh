#!/bin/bash

# This lets me lazily edit dpkg-pkgs

action=$1
name=$2

case "$action" in
	control)
		dpkg -x "$name" /tmp/"${name%_*}"
		dpkg -e "$name" /tmp/"${name%_*}"/DEBIAN
		nano /tmp/"${name%_*}"/DEBIAN/control
		;;
	files)
		dpkg -x "$name" /tmp/"${name%_*}"
		dpkg -e "$name" /tmp/"${name%_*}"/DEBIAN
		echo "Files in /tmp/${name%_*}"
		echo "Hit RETURN when ready for re-packaging"
		read
		;;
	*)
		echo "Usage"
		echo "  dpkg-edit.sh <action> <file>"
		echo
		echo "  Where action can be one of:"
		echo "      control - edit the control file"
		echo "      files   - work on the files"
		echo
		exit 1
		;;
esac

echo "Rebuild (y/n)?"
read answer
if [ "$answer" = "y" ]; then
	dpkg -b /tmp/"${name%_*}"/ "$name"
fi

rm -Rf /tmp/"${name%_*}"

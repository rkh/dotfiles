#! /bin/sh
#
# makedeb.sh - Utility for easy packaging of binaries
# Copyright (C) 2005-2006 Tommi Saviranta <wnd@iki.fi>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
#
# Version: makedeb.sh v0.1.2  17-Mar-2006  wnd@iki.fi

set -e

tmpdir=__makedeb__tmp__

section=misc
priority=optional
maintainer="Tim Felgentreff <timfelgentreff@gmail.com>"
version=0.1.0-1
branch=unstable
urgency=low
depends=apt
arch=i386


while test $# -gt 0; do
	case $1 in
	  --help)
		cat <<EOF
Usage: $0 --rootdir dir --package package --description description
		[--longdesc long-description] [--version version]
		[--arch architecture] [--branch bracnh] [--urgency urgency]
		[--maintainer maintainer] [--priority priority]
		[--section section] [--depends depends]
EOF
		exit 0
		;;
	  --[a-z]*)
		switch=$(echo "$1" | cut -c 3-)
		eval $switch=\""$2"\"
		shift
		;;
	  *)
		echo "Bad option: $1"
		exit 1
		;;
	esac
	shift
done

if [ "x$rootdir" = "x" ]; then
	echo "rootdir not set"
	exit 1
fi

if [ "x$package" = "x" ]; then
	echo "Package name not set"
	exit 1
fi

if [ "x$description" = "x" ]; then
	echo "Description not set"
	exit 1
fi

test ! "$longdesc" && longdesc="$description"


date=$(date "+%a, %d %b %Y %H:%M:%S %z")


if [ -d "$tmpdir" ]; then
	echo "$tmpdir already exists!"
	exit 1
fi

if [ ! -d "$rootdir" ]; then
	echo "$rootdir does not exist!"
	exit 1
fi


if [ "x$arch" = "x" ]; then
	if dpkg-architecture -qDEB_BUILD_ARCH_CPU 1>/dev/null 2>&1; then
		arch=$(dpkg-architecture -qDEB_BUILD_ARCH_CPU)
	else
		echo "Cannot get architecture with dpkg-architecture!"
		echo "Use --architecture foo to enter it manually."
		exit 1
	fi
fi




mkdir "$tmpdir"
trap "rm -rf \"$tmpdir\"" 0 1 2 15
mkdir "$tmpdir/debian"
echo 4 >"$tmpdir/debian/compat"

cat <<EOF >"$tmpdir/debian/changelog"
$package ($version) $branch; urgency=$urgency

  * Packaged with makedeb.

 -- $maintainer  $date
EOF

cat <<EOF >"$tmpdir/debian/control"
Source: $package
Section: $section
Priority: $priority
Maintainer: $maintainer
Build-Depends: debhelper (>= 4.0.0)
Standards-Version: 3.6.0

Package: $package
Section: $section
Architecture: $arch
Depends: $depends
Description: $description
 $longdesc
EOF

cp -r -p "$rootdir"/* "$tmpdir"

ls "$tmpdir" | grep -v debian >"$tmpdir/debian/$package.install"

cat <<EOF >"$tmpdir/debian/rules"
#! /usr/bin/make -f

# Uncomment this to turn on verbose mode.
#export DH_VERBOSE=1


# These are used for cross-compiling and for saving the configure script
# from having to guess our platform (since we know it already)
DEB_HOST_GNU_TYPE   ?= \$(shell dpkg-architecture -qDEB_HOST_GNU_TYPE)
DEB_BUILD_GNU_TYPE  ?= \$(shell dpkg-architecture -qDEB_BUILD_GNU_TYPE)


config.status: configure
	dh_testdir


build: build-stamp

build-stamp:
	dh_testdir

	touch build-stamp

clean:
	dh_testdir
	dh_testroot
	rm -f build-stamp

	dh_clean

install: build
	dh_testdir
	dh_testroot
	dh_clean -k

# Build architecture-independent files here.
binary-indep: build install

# Build architecture-dependent files here.
binary-arch: build install
	dh_testdir
	dh_testroot
	dh_installchangelogs
	dh_install
	dh_installdebconf
	dh_compress
	dh_fixperms
	dh_makeshlibs
	dh_installdeb
	dh_gencontrol
	dh_md5sums
	dh_builddeb

binary: binary-indep binary-arch
.PHONY: build clean binary-indep binary-arch binary install
EOF
chmod 755 "$tmpdir/debian/rules"

(cd "$tmpdir"; fakeroot dpkg-buildpackage -b)


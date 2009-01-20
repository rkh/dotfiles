#!/bin/bash

# This bundles windows programs with the currently running wine into a single dir. Got the idea from picasa. No more regressions!
# $1 is WINEPREFIX
# $2 is .exe - Path
# $3 is die exe selber

if [ $# -ne 3 ]; then
   echo "Usage: wine-bundling WINEBUNDLE-PREFIX EXE-PATH EXE-FILE"
   exit 1
fi

cd /usr/bin
mkdir -p $1/wine/bin/
mkdir $1/wine/share/
mkdir $1/wine/lib/

cp wine regedit regsvr32 uninstaller wcmd wdi wineboot winebrowser winecfg wineconsole winedbg winefile wine-kthread winelauncher winepath wine-preloader wine-pthread wineserver wineshelllink winhelp $1/wine/bin/
cp -R /usr/lib/wine/ $1/wine/lib/
cp /usr/lib/libwine.so.* /usr/lib/libwine.so.1.0 /usr/lib/libwine.so.1 $1/wine/lib/
cp -R /usr/share/wine/ $1/wine/share/

cd $1

echo "#!/bin/bash" > $1/start.sh
echo "# Script to set up the environment and launch an executable" >> $1/start.sh
echo "cd $1" >> $1/start.sh
echo "export PATH=$1/wine/bin:\$PATH" >> $1/start.sh
echo "export LD_LIBRARY_PATH=$1/wine/lib:\$LD_LIBRARY_PATH" >> $1/start.sh
echo "export WINEDLLPATH=$1/wine/lib/wine" >> $1/start.sh
echo "export WINELOADER=$1/wine/bin/wine" >> $1/start.sh
echo "export WINESERVER=$1/wine/bin/wineserver" >> $1/start.sh
echo "export WINEPREFIX=$1" >> $1/start.sh
echo "cd \"$1$2\"" >> $1/start.sh
echo "wine \"$3\"" >> $1/start.sh

chmod +x $1/start.sh

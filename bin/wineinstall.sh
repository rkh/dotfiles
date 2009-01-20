#!/bin/bash
# quick install into new wine-prefix

mkdir "$1"
export WINEPREFIX="$1"
wineprefixcreate 
echo export WINEPREFIX="$1"

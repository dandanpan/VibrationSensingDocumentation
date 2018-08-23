#!/usr/bin/env bash

if [[ -z "$INSTALLDIR" ]]; then
    INSTALLDIR="$HOME/Documents/Arduino"
fi
if [[ -z "$JARLIBSDIR" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        JARLIBSDIR="/Applications/Arduino.app/Contents/Java"
    else
        JARLIBSDIR="../../../"
    fi
fi
echo "INSTALLDIR: $INSTALLDIR"
echo "JARLIBSDIR: $JARLIBSDIR"

pde_path=`find $JARLIBSDIR -name pde.jar`
core_path=`find $JARLIBSDIR -name arduino-core.jar`
lib_path=`find $JARLIBSDIR -name commons-codec-1.7.jar`
if [[ -z "$core_path" || -z "$pde_path" ]]; then
    echo "Some java libraries have not been built yet (did you run ant build?)"
    return 1
fi
echo "pde_path: $pde_path"
echo "core_path: $core_path"
echo "lib_path: $lib_path"

set -e

mkdir -p bin
javac -target 1.8 -cp "$pde_path:$core_path:$lib_path" -d bin src/ESP8266FS.java

pushd bin
mkdir -p "$INSTALLDIR/tools"
rm -rf "$INSTALLDIR/tools/ESP8266FS"
mkdir -p "$INSTALLDIR/tools/ESP8266FS/tool"
zip -r "$INSTALLDIR/tools/ESP8266FS/tool/esp8266fs.jar" *
popd

dist=$PWD/dist
rev=$(git describe --tags)
mkdir -p "$dist"
pushd "$INSTALLDIR/tools"
zip -r "$dist/ESP8266FS-$rev.zip" ESP8266FS/
popd

#!/bin/bash

# ensure correct working directory
cd "$(dirname "$(realpath "$0")")"
# make directory structure
mkdir -p appimagebuild/LinuxToys-Atom.AppDir/usr/bin
mkdir -p appimagebuild/LinuxToys-Atom.AppDir/usr/lib

# get updated LinuxToys and set proper filename
cp linuxtoys.sh linuxtoys1.sh
mv linuxtoys1.sh linuxtoys
mv -f linuxtoys appimagebuild/LinuxToys-Atom.AppDir/usr/bin/

# fetch dependencies
cp /usr/bin/curl /usr/bin/wget /usr/bin/git /usr/bin/whiptail /usr/bin/bash appimagebuild/LinuxToys-Atom.AppDir/usr/bin/
# fetch libraries for dependencies
for bin in curl wget git whiptail bash; do
    for dep in $(ldd /usr/bin/$bin | awk '{if ($3 ~ /^\//) print $3}'); do
        cp -u --parents "$dep" appimagebuild/LinuxToys-Atom.AppDir/usr/lib/;
    done;
done

# adjust library dir structure
mv appimagebuild/LinuxToys-Atom.AppDir/usr/lib/lib/x86_64-linux-gnu appimagebuild/LinuxToys-Atom.AppDir/usr/
rm -r appimagebuild/LinuxToys-Atom.AppDir/usr/lib
mv appimagebuild/LinuxToys-Atom.AppDir/usr/x86_64-linux-gnu appimagebuild/LinuxToys-Atom.AppDir/usr/lib

# build appimage
./appimagebuild/appimagetool-x86_64.AppImage appimagebuild/LinuxToys-Atom.AppDir

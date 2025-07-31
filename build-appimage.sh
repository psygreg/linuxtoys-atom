#!/bin/bash

# ensure correct working directory
cd "$(dirname "$(realpath "$0")")"
# make directory structure
mkdir -p appimagebuild/LinuxToys-Atom.AppDir/usr/bin
mkdir -p appimagebuild/LinuxToys-Atom.AppDir/usr/lib

# get updated LinuxToys and set proper filename
cp -f appimage/linuxtoys.sh appimagebuild/LinuxToys-Atom.AppDir/usr/bin/
mv appimagebuild/LinuxToys-Atom.AppDir/usr/bin/linuxtoys.sh appimagebuild/LinuxToys-Atom.AppDir/usr/bin/linuxtoys

# get updated libraries
cp -f linuxtoys-atom.lib appimagebuild/LinuxToys-Atom.AppDir/usr/bin/
cp -f src/lang/* appimagebuild/LinuxToys-Atom.AppDir/usr/bin/

# fetch dependencies
cp /usr/bin/curl /usr/bin/wget /usr/bin/git /usr/bin/zenity /usr/bin/bash /usr/bin/ca-certificates appimagebuild/LinuxToys-Atom.AppDir/usr/bin/
cp /usr/bin/git-* appimagebuild/LinuxToys-Atom.AppDir/usr/bin/
# fetch libraries for dependencies
for bin in curl wget git bash; do
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

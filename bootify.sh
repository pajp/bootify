#!/bin/bash -e

# Based on http://anadoxin.org/blog/creating-a-bootable-el-capitan-iso-image.html

if ! which xml > /dev/null 2>&1 ; then
    echo "Error: 'xml' not found. brew install xmlstarlet?"
    exit 1
fi

if [ -d "/Volumes/OS X Base System" ] ; then
    diskutil eject "/Volumes/OS X Base System"
fi

appbundle="/Applications/Install OS X El Capitan.app"

mountpoint=$(hdiutil attach -plist "${appbundle}/Contents/SharedSupport/InstallESD.dmg" -noverify -nobrowse | xml sel -t -v '//key[.="mount-point"]/following-sibling::*[1]')
echo "Using OS installer disk image from \"$appbundle\" mounted at \"$mountpoint\""
hdiutil create -o ElCapitan3.cdr -size 7316m -layout SPUD -fs HFS+J
isomountpoint=$(hdiutil attach -plist ElCapitan3.cdr.dmg -noverify -nobrowse | xml sel -t -v '//key[.="mount-point"]/following-sibling::*[1]')
echo "Restoring to ISO image mounted at $isomountpoint"
asr restore -source "$mountpoint"/BaseSystem.dmg -target "$isomountpoint" -noprompt -noverify -erase --puppetstrings
echo "Fixing boot image"
rm /Volumes/OS\ X\ Base\ System/System/Installation/Packages
cp -rp "$mountpoint"/Packages /Volumes/OS\ X\ Base\ System/System/Installation
cp -rp "$mountpoint"/BaseSystem.chunklist /Volumes/OS\ X\ Base\ System/
cp -rp "$mountpoint"/BaseSystem.dmg /Volumes/OS\ X\ Base\ System/
hdiutil detach "$mountpoint"
hdiutil detach /Volumes/OS\ X\ Base\ System
hdiutil convert ElCapitan3.cdr.dmg -format UDTO -o ElCapitan3.iso
mv -v ElCapitan3.iso.cdr ElCapitan3.iso


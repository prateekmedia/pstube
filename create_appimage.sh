#!/bin/sh

sudo chmod +x appimagetool-x86_64.AppImage
cp -r build/linux/x64/release/bundle/* AppDir
mkdir -p AppDir/usr/share/icons/hicolor/256x256/apps/
cp assets/flutube.png AppDir/usr/share/icons/hicolor/256x256/apps/
cp assets/flutube.png AppDir/flutube.png
mkdir -p AppDir/usr/share/applications
cp assets/flutube.desktop AppDir/usr/share/applications/flutube.desktop
cp assets/flutube.desktop AppDir/flutube.desktop
sudo chmod +x appimagetool-x86_64.AppImage
ARCH=x86_64 ./appimagetool-x86_64.AppImage AppDir/ flutube-x86_64.AppImage

#!/bin/sh

# Create Application Directory
mkdir -p AppDir

# Create AppRun file(required by AppImage)
echo '#!/bin/sh

cd "$(dirname "$0")"
exec ./flutube' > AppDir/AppRun
sudo chmod +x AppDir/AppRun

# Copy all build files to AppDir
cp -r build/linux/x64/release/bundle/* AppDir

## Add Application metadata
# Copy app icon
sudo mkdir -p AppDir/usr/share/icons/hicolor/256x256/apps/
cp assets/flutube.png AppDir/flutube.png
sudo cp AppDir/flutube.png AppDir/usr/share/icons/hicolor/256x256/apps/flutube.png

sudo mkdir -p AppDir/usr/share/applications

# Either copy .desktop file content from file or with echo command
# cp assets/flutube.desktop AppDir/flutube.desktop

echo '[Desktop Entry]
Version=1.0
Type=Application
Name=FluTube
Icon=flutube
Exec=flutube %u
StartupWMClass=flutube
Categories=Utility;' > AppDir/flutube.desktop

# Also copy the same .desktop file to usr folder
sudo cp AppDir/flutube.desktop AppDir/usr/share/applications/flutube.desktop

## Start build
test ! -e appimagetool-x86_64.AppImage && curl -L https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -o appimagetool-x86_64.AppImage
sudo chmod +x appimagetool-x86_64.AppImage
ARCH=x86_64 ./appimagetool-x86_64.AppImage AppDir/ flutube-x86_64.AppImage

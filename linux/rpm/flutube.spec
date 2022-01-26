Name:       flutube
Version:    1.1.0
Release:    1
Summary:    Youtube client made using flutter.
License:    GPL-3.0

%description
Youtube client made using flutter.

%prep
# we have no source, so nothing here

%build
# already build using ci, so nothing here

%install
mkdir -p %{buildroot}/usr
cp -rf linux/packaging/usr/ %{buildroot}/usr

%files
/usr/bin/data/flutter_assets/AssetManifest.json
/usr/bin/data/flutter_assets/FontManifest.json
/usr/bin/data/flutter_assets/NOTICES.Z
/usr/bin/data/flutter_assets/assets/flutube.png
/usr/bin/data/flutter_assets/assets/fonts/NotoSans/NotoSans-Bold.ttf
/usr/bin/data/flutter_assets/assets/fonts/NotoSans/NotoSans-BoldItalic.ttf
/usr/bin/data/flutter_assets/assets/fonts/NotoSans/NotoSans-Italic.ttf
/usr/bin/data/flutter_assets/assets/fonts/NotoSans/NotoSans-Regular.ttf
/usr/bin/data/flutter_assets/assets/prateekmedia.jpeg
/usr/bin/data/flutter_assets/fonts/MaterialIcons-Regular.otf
/usr/bin/data/flutter_assets/packages/ant_icons/lib/icons/ant.ttf
/usr/bin/data/flutter_assets/version.json
/usr/bin/data/icudtl.dat
/usr/bin/flutube
/usr/bin/lib/libapp.so
/usr/bin/lib/libflutter_linux_gtk.so
/usr/bin/lib/liburl_launcher_linux_plugin.so
/usr/share/applications/flutube.desktop
/usr/share/icons/hicolor/128x128/apps/flutube.png
/usr/share/metainfo/flutube.appdata.xml

%changelog
# let's skip this for now
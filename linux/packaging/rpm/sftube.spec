Name:       sftube
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
mkdir -p %{buildroot}
cp -rf linux/packaging/deb/usr/ %{buildroot}

%files
FILES_HERE

%changelog
# let's skip this for now
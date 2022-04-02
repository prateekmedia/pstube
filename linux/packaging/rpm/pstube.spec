Name:       pstube
Version:    VERSION
Release:    1
Summary:    Watch and download videos without ads
License:    GPL-3.0
AutoReqProv: no

%description
Ever wondered how the videos in the internet will look without ads, no more wondering just use PsTube.

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
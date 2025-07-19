Name:           lsw-atom-shortcuts
Version:        1.0
Release:        1
Summary:        Linux Subsystem for Windows
BuildArch:      x86_64

License:        GPL3
Source0:        lsw-atom-shortcuts-%{version}.tar.xz

Requires:       bash docker-ce docker-ce-cli docker-compose-plugin dialog freerdp netcat
BuildRequires:  desktop-file-utils

%description
Linux Subsystem for Windows ported to atomic Fedora.

%global debug_package %{nil}

%prep
%setup -q

%install
mkdir -p %{buildroot}/usr/bin/lsw/
mkdir -p %{buildroot}/usr/share/icons/hicolor/scalable/apps/
install -m 755 lsw-desktop.png %{buildroot}/usr/share/icons/hicolor/scalable/apps/
install -m 755 lsw-on.png %{buildroot}/usr/share/icons/hicolor/scalable/apps/
install -m 755 lsw-off.png %{buildroot}/usr/share/icons/hicolor/scalable/apps/
install -m 755 lsw-refresh.png %{buildroot}/usr/share/icons/hicolor/scalable/apps/
install -m 755 lsw-on.sh %{buildroot}/usr/bin/lsw/
install -m 755 lsw-off.sh %{buildroot}/usr/bin/lsw/
install -m 755 lsw-refresh.sh %{buildroot}/usr/bin/lsw/
mkdir -p %{buildroot}/usr/share/applications/
desktop-file-install --dir=%{buildroot}/usr/share/applications lsw-on.desktop
desktop-file-install --dir=%{buildroot}/usr/share/applications lsw-off.desktop
desktop-file-install --dir=%{buildroot}/usr/share/applications lsw-refresh.desktop
desktop-file-install --dir=%{buildroot}/usr/share/applications lsw-desktop.desktop

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-, root, root, -)
/usr/bin/lsw/lsw-refresh.sh
/usr/bin/lsw/lsw-on.sh
/usr/bin/lsw/lsw-off.sh
/usr/share/icons/hicolor/scalable/apps/lsw-off.png
/usr/share/icons/hicolor/scalable/apps/lsw-on.png
/usr/share/icons/hicolor/scalable/apps/lsw-refresh.png
/usr/share/icons/hicolor/scalable/apps/lsw-desktop.png
/usr/share/applications/lsw-on.desktop
/usr/share/applications/lsw-off.desktop
/usr/share/applications/lsw-refresh.desktop
/usr/share/applications/lsw-desktop.desktop

%changelog
* Thu Jul  17 2025 Victor Gregory <psygreg@pm.me> - 1.0
- Linux Subsystem for Windows port for Fedora Silverblue/Kinoite

# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
# 

Name:       harbour-qtodo

# >> macros
%define __requires_exclude ^libQt5Widgets|libcrypto|libqca-qt5|libqmfclient5|libssl|libstdc++.*$
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    A Simple and Easy to Use To-do List Organizer
Version:    1.12.3
Release:    1
Group:      Qt/Qt
License:    GPLv3
Source0:    %{name}-%{version}.tar.bz2
Source100:  harbour-qtodo.yaml
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(qmfclient5)
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Quick)

%description
Q To-Do is a simple to-do list organizer. It features a clear, simple, and easy to use user interface.


%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5 

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
find %{buildroot}/%{_datadir}/harbour-qtodo -type f -exec chmod 644 {} \;
find %{buildroot}/%{_datadir}/harbour-qtodo -type f -exec sed -i 's/import qtodo/import harbour.qtodo/g' {} \;
find %{buildroot}/%{_datadir}/harbour-qtodo -type f -exec sed -i 's/import SyncToImap/import harbour.qtodo/g' {} \;
chmod 644 %{buildroot}/%{_datadir}/icons/hicolor/86x86/apps/harbour-qtodo.png
chmod 644 %{buildroot}/%{_datadir}/applications/harbour-qtodo.desktop
# << install post

%files
%defattr(-,root,root,-)
%{_datadir}/icons/hicolor/86x86/apps
%{_datadir}/applications
%{_datadir}/%{name}
%{_bindir}/%{name}
# >> files
# << files

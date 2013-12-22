# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.27
# 

Name:       qtodo

# >> macros
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    My SailfishOS Application
Version:    0.1
Release:    1
Group:      Qt/Qt
License:    LICENSE
Source0:    %{name}-%{version}.tar.bz2
Source100:  qtodo.yaml
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(qmfclient5)
BuildRequires:  pkgconfig(Qt5Qml)

%description
Short description of my SailfishOS Application


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
# << install post

%files
%defattr(-,root,root,-)
/opt/qtodo/qml
/opt/qtodo
/opt/qtodo/icons
/opt/qtodo/bin
/usr/share/icons/hicolor/80x80/apps/qtodo80.png
/usr/share/icons/hicolor/scalable/apps/qtodo.svg
# >> files
# << files

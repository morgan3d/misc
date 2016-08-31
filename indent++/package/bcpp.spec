Summary: bcpp - C(++) beautifier
%define AppProgram bcpp
%define AppVersion 20120318
# $Id: bcpp.spec,v 1.1 2012/03/18 16:05:43 tom Exp $
Name: %{AppProgram}
Version: %{AppVersion}
Release: 1
License: MIT
Group: Applications/Development
URL: ftp://invisible-island.net/%{AppProgram}
Source0: %{AppProgram}-%{AppVersion}.tgz
Packager: Thomas Dickey <dickey@invisible-island.net>

%description
bcpp indents C/C++ source programs, replacing tabs with spaces or the
reverse. Unlike indent, it does (by design) not attempt to wrap long
statements.

This version improves the parsing algorithm by marking the state of all
characters, recognizes a wider range of indention structures, and implements
a simple algorithm for indenting embedded SQL.

%prep

%setup -q -n %{AppProgram}-%{AppVersion}

%build

CPPFLAGS="$CPPFLAGS -DBCPP_CONFIG_DIR=\"%{_sysconfdir}\"" \
INSTALL_PROGRAM='${INSTALL}' \
	./configure \
		--program-prefix=b \
		--target %{_target_platform} \
		--prefix=%{_prefix} \
		--bindir=%{_bindir} \
		--datadir=%{_datadir} \
		--sysconfdir=%{_sysconfdir} \
		--libdir=%{_libdir} \
		--mandir=%{_mandir}

make

%install
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

make install                    DESTDIR=$RPM_BUILD_ROOT

mkdir -p $RPM_BUILD_ROOT%{_sysconfdir}
install code/bcpp.cfg $RPM_BUILD_ROOT%{_sysconfdir}

strip $RPM_BUILD_ROOT%{_bindir}/%{AppProgram}

%clean
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{_bindir}/%{AppProgram}
%{_bindir}/cb++
%{_sysconfdir}/bcpp.cfg
%{_mandir}/man1/%{AppProgram}.*

%changelog
# each patch should add its ChangeLog entries here

* Sun Mar 18 2012 Thomas Dickey
- initial version

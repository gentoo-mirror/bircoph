# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )

inherit autotools eutils flag-o-matic multilib python-single-r1 toolchain-funcs user

MY_P="${P/_}"
DESCRIPTION="Distribute compilation of C code across several machines on a network"
HOMEPAGE="https://distcc.org/"
SRC_URI="https://github.com/distcc/distcc/releases/download/v${PV/_}/${MY_P}.tar.bz2
		 https://dev.gentoo.org/~bircoph/patches/${P}-native.patch.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86"
IUSE="cc32_64 crossdev gssapi gtk hardened ipv6 +secure selinux xinetd zeroconf"

RESTRICT="test"

DEPEND="dev-libs/popt
	zeroconf? ( >=net-dns/avahi-0.6[dbus] )
	cc32_64? (
		amd64? ( sys-devel/gcc[multilib(-)] )
		x86? ( cross-x86_64-pc-linux-gnu/gcc )
	)
	gssapi? ( net-libs/libgssglue )
	gtk? ( x11-libs/gtk+:2 )"
RDEPEND="${DEPEND}
	!net-misc/pump
	>=sys-devel/gcc-config-1.4.1
	selinux? ( sec-policy/selinux-distcc )
	xinetd? ( sys-apps/xinetd )"
BDEPEND="
	virtual/pkgconfig"

# crosscompilation requirements
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	cc32_64? (
		!crossdev
		^^ ( amd64 x86 )
	)"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	enewuser distcc 240 -1 -1 daemon
	python-single-r1_pkg_setup

	if use cc32_64; then
			use x86 && arch="x86_64"
			use amd64 && arch="i686"
	fi
}

src_prepare() {
	DCCC_PATH="/usr/$(get_libdir)/distcc/bin"

	epatch "${FILESDIR}/${PN}-3.0-xinetd.patch"
	# bug #253786
	epatch "${FILESDIR}/${PN}-3.0-fix-fortify.patch"
	# bug #255188
	epatch "${FILESDIR}/${P}-freedesktop.patch"
	# bug #258364
	epatch "${FILESDIR}/${P}-python.patch"
	# bug #351979
	epatch "${FILESDIR}/${PN}-3.1-argc-fix.patch"
	# for net-libs/libgssglue
	epatch "${FILESDIR}/${P}-gssapi.patch"
	# for cross-compiling
	epatch "${FILESDIR}/${P}-crosscompile.patch"
	# to support native arguments
	epatch "${WORKDIR}/${P}-native.patch"

	# Bugs #120001, #167844 and probably more. See patch for description.
	use hardened && epatch "${FILESDIR}/distcc-hardened.patch"

	sed -i \
		-e "/PATH/s:\$distcc_location:${EPREFIX}${DCCC_PATH}:" \
		-e "s:@PYTHON@:${EPYTHON}:" \
		pump.in || die "sed failed"

	sed \
		-e "s:@EPREFIX@:${EPREFIX:-/}:" \
		-e "s:@libdir@:/usr/$(get_libdir):" \
		"${FILESDIR}/distcc-config-3.2_rc1-v2" > "${T}/distcc-config" || die "sed failed"

	# prepare conf.d before we fork it
	cp "${FILESDIR}/distccd.confd" "${T}/distccd.confd-base" || die "cp failed"
	if use zeroconf; then
		cat >> "${T}/distccd.confd" <<-EOF

		# Enable zeroconf support in distccd
		DISTCCD_OPTS="\${DISTCCD_OPTS} --zeroconf"
		EOF
	fi

	# conf.d and init.d arch deps
	sed -e "s%@DCCBIN@%distccd%" \
	    -e "s%@DCCPORT@%3632%" \
		"${T}/distccd.confd-base" > "${T}/distccd.confd" || die "sed failed"

	sed -e "s%@DCCPATH@%%" \
		"${FILESDIR}/distccd.initd" > "${T}/distccd.initd" || die "sed failed"

	# conf.d and init.d common deps
	if use cc32_64; then
		sed -e "s%@DCCBIN@%distccd-${arch}%" \
			-e "s%@DCCPORT@%3633%" \
			"${T}/distccd.confd-base" > "${T}/distccd-${arch}.confd" || die "sed failed"

		sed -e "s%@DCCPATH@%${EPREFIX}${DCCC_PATH}-${arch}:%" \
			"${FILESDIR}/distccd.initd" > "${T}/distccd-${arch}.initd" || die "sed failed"
	fi

	eaclocal -Im4 --output=aclocal.m4
	eautoconf

	if use cc32_64; then
		mkdir "${S}/bin-${arch}"
		cp "${FILESDIR}"/cross-${arch}/* "${S}/bin-${arch}" || die "helper cp failed"
	fi
}

src_configure() {
	local myconf="--disable-Werror"
	# More legacy stuff?
	[ "$(gcc-major-version)" = "2" ] && filter-lfs-flags

	# --disable-rfc2553 b0rked, bug #254176
	use ipv6 && myconf="${myconf} --enable-rfc2553"

	econf \
		$(use_with zeroconf avahi) \
		$(use_with gtk) \
		$(use_with gssapi auth) \
		--without-gnome \
		--with-docdir="${EPREFIX}/usr/share/doc/${PF}" \
		${myconf} || die "econf failed"
}

src_compile() {
	default
	use cc32_64 && emake -C "${S}/bin-${arch}"
}

src_install() {
	DCCC_PATH="/usr/$(get_libdir)/distcc/bin"

	default
	python_optimize

	if use cc32_64 ; then
		exeinto "${DCCC_PATH}-${arch}"
		doexe "${S}/bin-${arch}/"{c++,g++,gcc}
	fi

	newinitd "${T}/distccd.initd" distccd
	newconfd "${T}/distccd.confd" distccd
	if use cc32_64; then
		newinitd "${T}/distccd-${arch}.initd" "distccd-${arch}"
		newconfd "${T}/distccd-${arch}.confd" "distccd-${arch}"
	fi

	cat > "${T}/02distcc" <<-EOF
	# This file is managed by distcc-config; use it to change these settings.
	# DISTCC_LOG and DISTCC_DIR should not be set.
	DISTCC_VERBOSE="${DISTCC_VERBOSE:-0}"
	DISTCC_FALLBACK="${DISTCC_FALLBACK:-1}"
	DISTCC_SAVE_TEMPS="${DISTCC_SAVE_TEMPS:-0}"
	DISTCC_TCP_CORK="${DISTCC_TCP_CORK:-1}"
	DISTCC_SSH="${DISTCC_SSH}"
	UNCACHED_ERR_FD="${UNCACHED_ERR_FD}"
	DISTCC_ENABLE_DISCREPANCY_EMAIL="${DISTCC_ENABLE_DISCREPANCY_EMAIL}"
	DCC_EMAILLOG_WHOM_TO_BLAME="${DCC_EMAILLOG_WHOM_TO_BLAME}"
	EOF
	if use secure; then
		cat >> "${T}/02distcc" <<-EOF
		# Enable list of allowed commands
		DISTCC_CMDLIST_NUMWORDS="1"
		DISTCC_CMDLIST="${EPREFIX}/etc/distcc/commands.allow"
		EOF
	fi
	doenvd "${T}/02distcc"

	keepdir "${DCCC_PATH}"

	dobin "${T}/distcc-config"

	# create the distccd pid directory
	keepdir /var/run/distccd
	fowners distcc:daemon /var/run/distccd

	if use xinetd; then
		insinto /etc/xinetd.d || die
		newins "doc/example/xinetd" distcc
	fi

	rm -r "${ED}/etc/default" || die
	rm "${ED}/etc/distcc/clients.allow" || die
	rm "${ED}/etc/distcc/commands.allow.sh" || die
}

pkg_postinst() {
	pkg_config

	elog
	elog "Tips on using distcc with Gentoo can be found at"
	elog "https://www.gentoo.org/doc/en/distcc.xml"
	elog
	elog "How to use pump mode with Gentoo:"
	elog "# distcc-config --set-hosts \"foo,cpp,lzo bar,cpp,lzo baz,cpp,lzo\""
	elog "# echo 'FEATURES=\"\${FEATURES} distcc distcc-pump\"' >> /etc/make.conf"
	elog "# emerge -u world"
	elog
	elog "To use the distccmon programs with Gentoo you should use this command:"
	elog "# DISTCC_DIR=\"${DISTCC_DIR:-${BUILD_PREFIX}/.distcc}\" distccmon-text 5"

	elog
	elog "***SECURITY NOTICE***"
	elog "If you are upgrading distcc please make sure to run etc-update to"
	elog "update your /etc/conf.d/distccd and /etc/init.d/distccd files with"
	elog "added security precautions (the --listen and --allow directives)"
	elog

	ewarn "On gcc version bump please do not forget to update distcc setup."
	ewarn "You may do this by running emerge --config distcc"
}

pkg_postrm() {
	DCCC_PATH="/usr/$(get_libdir)/distcc/bin"

	# delete the masquerade directory
	if [ ! -f "${EPREFIX}/usr/bin/distcc" ] ; then
		einfo "Remove masquerade symbolic links."
		rm "${EPREFIX}${DCCC_PATH}/"*{cc,c++,gcc,g++}*
		rmdir "${EPREFIX}${DCCC_PATH}"
	fi
}

pkg_config() {
	if [ -x "${EPREFIX}/usr/bin/distcc-config" ] ; then
		if use crossdev; then
			"${EPREFIX}/usr/bin/distcc-config" --update-masquerade-with-crossdev
		elif use cc32_64; then
			"${EPREFIX}/usr/bin/distcc-config" --update-masquerade-with-cc32_64
		else
			"${EPREFIX}/usr/bin/distcc-config" --update-masquerade
		fi

		use secure && "${EPREFIX}/usr/bin/distcc-config" --generate-cmdlist
	else
		eerror "${EPREFIX}/usr/bin/distcc-config was not found!"
		eerror "Your distcc installation is broken."
	fi
}

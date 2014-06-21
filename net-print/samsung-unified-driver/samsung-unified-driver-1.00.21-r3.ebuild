# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit linux-info multilib

DESCRIPTION="Samsung Unified Linux Driver"
HOMEPAGE="http://www.samsung.com"
SRC_URI="http://downloadcenter.samsung.com/content/DR/201403/20140312091542348/ULD_V1.00.21.tar.gz -> ${P}.tar.gz"

LICENSE="samsung-eula"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cups network scanner"
RESTRICT="mirror strip"
REQUIRED_USE="network? ( cups )"

DEPEND=""
RDEPEND="
	cups? (
		net-print/cups
		!net-print/splix
	)
	scanner? (
		media-gfx/sane-backends
		dev-libs/libxml2:2
		virtual/libusb:0
	)
	network? (
		virtual/libusb:0
	)"

S=${WORKDIR}/uld

if use cups; then
	QA_FLAGS_IGNORED="usr/$(get_libdir)/libscmssc.so"
	QA_FLAGS_IGNORED+=" usr/libexec/cups/filter/pstosecps"
	QA_FLAGS_IGNORED+=" usr/libexec/cups/filter/rastertospl"
	QA_SONAME="usr/$(get_libdir)/libscmssc.so"
fi
if use scanner; then
	QA_FLAGS_IGNORED+=" usr/$(get_libdir)/sane/libsane-smfp.so.1.0.1"
fi
if use network; then
	QA_FLAGS_IGNORED+=" usr/libexec/cups/backend/smfpnetdiscovery"
fi

pkg_pretend() {
	if use scanner; then
		CONFIG_CHECK="~!USB_PRINTER"
		ERROR_USB_PRINTER="USB scanners will be managed via libusb. If you're going to use them"
		ERROR_USB_PRINTER+="USB_PRINTER support should be disabled in your kernel config."
		ERROR_USB_PRINTER+="Scanning WILL NOT work with loaded usblp module."
	fi
}

src_install() {
	local SARCH=""
	use amd64 && SARCH="x86_64"
	use arm && SARCH="arm"
	use x86 && SARCH="x86"
	[[ -z "${SARCH}" ]] && die "Unsupported architecture. Package supports amd64, arm, x86"

	# Printing support
	if use cups; then
		# libscmssc.so is now installed by default,
		# though ldd doesn't show any binary that needs it.
		# Apparently it is required for ppds with cms (cts) profile
		# and such drivers won't work otherwise.
		dolib.so ${SARCH}/libscmssc.so

		exeinto /usr/libexec/cups/filter
		doexe ${SARCH}/{pstosecps,rastertospl}

		dodir   /usr/share/cups/model/samsung
		insinto /usr/share/cups/model/samsung
		doins noarch/share/ppd/*.ppd
		gzip -9 "${D}"/usr/share/cups/model/samsung/*.ppd || die "gzip failed"

		dodir   /usr/share/cups/profiles/samsung
		insinto /usr/share/cups/profiles/samsung
		doins noarch/share/ppd/cms/*.cts
	fi

	# Scanning support
	if use scanner; then
		insinto /etc/sane.d
		doins noarch/etc/smfp.conf

		exeinto /usr/$(get_libdir)/sane
		doexe ${SARCH}/libsane-smfp.so.1.0.1

		dosym libsane-smfp.so.1.0.1 /usr/$(get_libdir)/sane/libsane-smfp.so.1
		dosym libsane-smfp.so.1 /usr/$(get_libdir)/sane/libsane-smfp.so
	fi

	# Network tool
	if use network; then
		exeinto /usr/libexec/cups/backend
		doexe ${SARCH}/smfpnetdiscovery
	fi
}

pkg_postinst() {
	if use scanner; then
		elog "You need to manually add smfp to /etc/sane.d/dll.conf:"
		elog "# echo smfp >> /etc/sane.d/dll.conf"
	fi
	if use network; then
		elog "If you're using firewall and want to use smfpnetdiscovery tool,"
		elog "you need to allow SNMP UDP packets (source port 161)"
	fi
}

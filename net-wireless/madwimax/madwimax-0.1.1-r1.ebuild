# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools

DESCRIPTION="madwimax driver for Samsung SWC-U200 Mobile WiMax dongle"
HOMEPAGE="http://code.google.com/p/madwimax/"
SRC_URI="http://madwimax.googlecode.com/files/madwimax-${PV}.tar.gz"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="doc"

DEPEND="
	>=dev-libs/libusb-1
	doc? ( app-text/asciidoc
		   app-text/docbook2X )
"
RDEPEND=">=dev-libs/libusb-1"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/madwimax-${PV}-gentoo.patch"
}

src_compile() {
	econf --with-script=gentoo $(use_with doc man-pages) || die "configure failed"
	emake || die "make failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "install failed"
	dodoc AUTHORS INSTALL NEWS README THANKS TODO
}

pkg_postinst() {
	udevadm control --reload_rules

	einfo "To enable automatic network interface configuration, please do:"
	einfo "  cd /etc/init.d"
	einfo "  ln -s net.lo net.wimax0"
}


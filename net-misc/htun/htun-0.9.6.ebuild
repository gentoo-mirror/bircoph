# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/htun/htun-0.9.5.ebuild,v 1.8 2009/01/14 03:47:53 vapier Exp $

EAPI="5"

inherit eutils

DESCRIPTION="Project to tunnel IP traffic over HTTP"
HOMEPAGE="http://linux.softpedia.com/get/System/Networking/HTun-14751.shtml"
SRC_URI="http://www.sourcefiles.org/Networking/Tools/Proxy/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="dev-util/yacc"
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}" || die
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-glibc.patch #248100
	epatch "${FILESDIR}"/${P}-makefile.patch
}

src_compile() {
	cd src || die
	emake CC="$(tc-getCC)"
}

src_install() {
	dosbin src/htund
	insinto /etc
	doins doc/htund.conf
	dodoc doc/* README
}

pkg_postinst() {
	einfo "NOTE: HTun requires the Universal TUN/TAP module"
	einfo "available in the Linux kernel.  Make sure you have"
	einfo "compiled the tun.o driver as a module!"
	einfo
	einfo "It can be found in the kernel configuration under"
	einfo "Network Device Support --> Universal TUN/TAP"
	einfo
	einfo "To configure HTun, run the following commands as root:"
	einfo "  # mknod /dev/net/tun c 10 200"
	einfo "  # echo \"alias char-major-10-200 tun\" >> /etc/modules.conf"
	einfo "  # depmod -e"
}

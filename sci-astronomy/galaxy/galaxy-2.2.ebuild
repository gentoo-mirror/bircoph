# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-astronomy/galaxy/galaxy-2.2.ebuild,v 1.1 2012/12/16 19:34:33 xarthisius Exp $

EAPI=4

inherit eutils fdo-mime toolchain-funcs

# probably change every release
PID="1/3/0/3/13035936"

DESCRIPTION="Stellar simulation program"
HOMEPAGE="http://www.kornelix.com/galaxy.html"
SRC_URI="http://www.kornelix.com/uploads/${PID}/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="x11-libs/gtk+:3"
RDEPEND="${DEPEND}
	x11-misc/xdg-utils"

pkg_setup() {
	tc-export CXX
	export PREFIX="${EPREFIX}/usr"
}

src_prepare() {
	sed -e '/DOCDIR/ s/PROGRAM)/&-\$(VERSION)/g' \
		-e '/xdg-desktop-menu/d' \
		-i Makefile || die
	epatch "${FILESDIR}/${P}-pthread.patch"
}

pkg_postinst() {
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
}

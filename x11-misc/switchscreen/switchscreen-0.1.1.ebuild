# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Utility for switching between multiple X screens"
HOMEPAGE="http://sampo.kapsi.fi/switchscreen/"
SRC_URI="http://sampo.kapsi.fi/switchscreen/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="x11-libs/libX11"
RDEPEND=${DEPEND}

PATCHES=( "${FILESDIR}"/${PN}-Makefile.diff )

src_install() {
	dobin switchscreen togglescreen.sh
	dodoc README
}

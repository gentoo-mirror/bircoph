# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils

DESCRIPTION="Utility for switching between multiple X screens"
HOMEPAGE="http://sampo.kapsi.fi/switchscreen/"
SRC_URI="http://sampo.kapsi.fi/switchscreen/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="x11-libs/libX11"
RDEPEND=${DEPEND}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-Makefile.diff
}

src_install() {
	exeinto /usr/bin/
	doexe switchscreen togglescreen.sh
	dodoc README
}

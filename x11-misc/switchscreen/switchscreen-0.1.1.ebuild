# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit eutils

DESCRIPTION="Utility for switching between multiple X screens"
HOMEPAGE="http://users.tkk.fi/spniskan/switchscreen/"
SRC_URI="http://users.tkk.fi/spniskan/switchscreen/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="x11-libs/libX11"
RDEPEND=${DEPEND}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-Makefile.diff
}

src_compile() {
	emake || die "emake failed"
}

src_install() {
	exeinto /usr/bin/
	doexe switchscreen togglescreen.sh
	dodoc README
}
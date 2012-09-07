# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit eutils subversion toolchain-funcs

DESCRIPTION="A library for handling the VESA BIOS Extension (aka VBE)"
HOMEPAGE="http://www.mplayerhq.hu/vesautils/index.html"
ESVN_REPO_URI="svn://svn.mplayerhq.hu/vesautils/trunk"
ESVN_PROJECT="vesautils"

S="${WORKDIR}/vesautils"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="" # this package can be used only on (~)x86.

DEPEND="sys-libs/lrmi"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/${PN}-makefile.patch"
}

src_compile() {
	CC="$(tc-getCC)" emake -C libvbe
}

src_install() {
	LIBDIR="${D}${EPREFIX}/usr/lib" \
	INCDIR="${D}${EPREFIX}/usr/include" \
	emake -C libvbe install
	dodoc README
}

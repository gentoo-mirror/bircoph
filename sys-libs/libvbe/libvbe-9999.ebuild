# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit subversion toolchain-funcs

DESCRIPTION="A library for handling the VESA BIOS Extension (aka VBE)"
HOMEPAGE="http://www.mplayerhq.hu/vesautils/index.html"
ESVN_REPO_URI="svn://svn.mplayerhq.hu/vesautils/trunk"
ESVN_PROJECT="vesautils"

S="${WORKDIR}/vesautils"

LICENSE="GPL-2"
SLOT="0"

DEPEND="sys-libs/lrmi"
RDEPEND="${DEPEND}"

PATCHES=( "${FILESDIR}/${PN}-makefile.patch" )

src_compile() {
	CC="$(tc-getCC)" emake -C libvbe
}

src_install() {
	LIBDIR="${D}${EPREFIX}/usr/lib" \
	INCDIR="${D}${EPREFIX}/usr/include" \
	emake -C libvbe install
	dodoc README
}

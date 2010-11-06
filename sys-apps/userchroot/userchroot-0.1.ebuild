# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit toolchain-funcs

DESCRIPTION="Safe chroot from userspace"
HOMEPAGE="http://koltsoff.com/pub/userchroot/"
SRC_URI="http://koltsoff.com/pub/userchroot/releases/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=""
RDEPEND=""

src_compile() {
	echo $(tc-getCC) ${CFLAGS} userchroot.c -o userchroot
	$(tc-getCC) ${CFLAGS} userchroot.c -o userchroot || die "compilation failed"
}

src_install() {
	exeinto /usr/bin/
	doexe userchroot
	fperms 4755 /usr/bin/userchroot
	dodoc CHANGELOG html/index.xhtml
}

# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit toolchain-funcs

DESCRIPTION="Safe chroot from userspace"
HOMEPAGE="http://koltsoff.com/pub/userchroot/"
SRC_URI="http://koltsoff.com/pub/userchroot/releases/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

src_compile() {
	$(tc-getCC) ${CFLAGS} ${LDFLAGS} userchroot.c -o userchroot || die "compilation failed"
}

src_install() {
	dobin userchroot
	fperms 4711 /usr/bin/userchroot
	dodoc -r CHANGELOG html
}

# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="Tunnels TCP/IP connections in a variety of ways, including through HTTP and SOCKS5 proxy servers"
HOMEPAGE="http://joshbeam.com/software/prtunnel.php"
SRC_URI="http://joshbeam.com/files/${P}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE="ipv6"
DEPEND="virtual/libc"
RDEPEND=${DEPEND}

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e "s:CFLAGS=:CFLAGS+=:" Makefile
	sed -i -e "s:-o prtunnel:\$\(LDFLAGS\) -o prtunnel:" Makefile
	use ipv6 || {
		sed -i -e "s:CFLAGS+= -DIPV6:#CFLAGS+= -DIPV6:" Makefile
		sed -i -e "s|direct6\.o:.*||" Makefile
		sed -i -e "s|direct6.o ||" Makefile
	}
}

src_install() {
	dobin prtunnel
	doman prtunnel.1
	dodoc README ChangeLog
}

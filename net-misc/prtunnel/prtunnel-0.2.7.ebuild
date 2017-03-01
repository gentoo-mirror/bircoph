# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Tunnels TCP/IP through HTTP, SOCKS5 proxies; IPv4/IPV6 bridge"
HOMEPAGE="http://joshbeam.com/software/prtunnel/"
SRC_URI="https://github.com/joshb/${PN}/releases/download/${PV}/${P}.tar.gz"
LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ipv6"

src_prepare() {
	default

	sed -i -e 's|CFLAGS=|CFLAGS+=|' \
		   -e 's|$(CC)|$(CC) $(CFLAGS) $(LDFLAGS)|' Makefile || die
	use ipv6 || sed -i -e "s|CFLAGS+= -DIPV6||" \
					   -e "s|direct6\.o:.*||" \
					   -e "s|direct6\.o ||" Makefile || die
}

src_install() {
	dobin prtunnel
	doman prtunnel.1
	dodoc ChangeLog README
}

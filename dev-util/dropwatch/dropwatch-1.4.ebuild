# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils linux-info

DESCRIPTION="An utility to interface to the kernel to monitor for dropped network packets"
HOMEPAGE="https://fedorahosted.org/dropwatch/"
SRC_URI="https://fedorahosted.org/releases/d/r/dropwatch/${P}.tbz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	dev-libs/libnl:3
	sys-libs/readline
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

CONFIG_CHECK="~NET_DROP_MONITOR"

src_prepare() {
	# honor system flags and be --as-needed friendly
	epatch "${FILESDIR}/${P}-makefile.patch"
}

src_compile() {
	emake -C src ${myconf}
}

src_install() {
	dobin src/dropwatch
	doman doc/dropwatch.1
	dodoc README
}

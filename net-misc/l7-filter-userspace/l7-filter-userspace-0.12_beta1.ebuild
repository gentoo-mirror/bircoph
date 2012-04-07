# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/l7-filter-userspace/l7-filter-userspace-0.11.ebuild,v 1.3 2012/03/03 15:31:46 pacho Exp $

EAPI=4

inherit eutils versionator

MY_P="${PN}-$(replace_version_separator 2 '-')"

DESCRIPTION="Userspace utilities for layer 7 iptables QoS"
HOMEPAGE="http://l7-filter.clearfoundation.com/"
SRC_URI="http://download.clearfoundation.com/l7-filter/${MY_P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64 ~x86"
IUSE=""
SLOT="0"
DEPEND=">=net-libs/libnetfilter_conntrack-0.0.100
		net-libs/libnetfilter_queue"
RDEPEND="net-misc/l7-protocols
		${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}/${PN}-0.11-libnetfilter_conntrack-0.0.100.patch"
	epatch "${FILESDIR}/${PN}-0.11-datatype.patch"
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc README TODO BUGS THANKS AUTHORS
}

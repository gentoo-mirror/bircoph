# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/ipaudit/ipaudit-1.0_beta2.ebuild,v 1.7 2011/04/02 12:53:39 ssuominen Exp $

EAPI=5

inherit eutils flag-o-matic multilib

DESCRIPTION="IPAudit monitors network activity on a network by host, protocol and port."
HOMEPAGE="http://ipaudit.sourceforge.net/"
MY_P="${PN}-${PV/_beta/BETA}"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"

KEYWORDS="~amd64 ppc x86"
IUSE="mysql"

DEPEND="net-libs/libpcap
		mysql? ( virtual/mysql )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_configure() {
	use mysql && append-ldflags "-L/usr/$(get_libdir)/mysql"
	econf $(use_with mysql)
}

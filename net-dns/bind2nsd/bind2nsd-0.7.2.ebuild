# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python{2_6,2_7,3_2,3_3} )
inherit distutils-r1 eutils

DESCRIPTION="Program to translate DNS information in BIND format to NSD format"
HOMEPAGE="http://bind2nsd.sourceforge.net"
SRC_URI="http://sourceforge.net/projects/bind2nsd/files/${PN}/${P}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-python/pexpect
	dev-python/pyDes
"

RDEPEND="${DEPEND}
	net-dns/nsd
"

RESTRICT_PYTHON_ABIS="3.*"

src_prepare() {
	epatch "${FILESDIR}/${P}-bind-sysconfig.patch"
}

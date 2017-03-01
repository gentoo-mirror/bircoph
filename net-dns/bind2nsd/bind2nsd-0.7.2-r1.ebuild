# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

PYTHON_COMPAT=( python2_7 )
inherit distutils-r1

DESCRIPTION="Program to translate DNS information in BIND format to NSD format"
HOMEPAGE="http://bind2nsd.sourceforge.net"
SRC_URI="http://sourceforge.net/projects/bind2nsd/files/${PN}/${P}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="
	dev-python/pexpect
	dev-python/pyDes
"
RDEPEND="${DEPEND}
	net-dns/nsd
"

PATCHES=( "${FILESDIR}/${P}-bind-sysconfig.patch" )

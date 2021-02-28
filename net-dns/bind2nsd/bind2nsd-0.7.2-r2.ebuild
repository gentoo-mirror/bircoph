# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )
DISTUTILS_USE_SETUPTOOLS=no
inherit distutils-r1

DESCRIPTION="Program to translate DNS information in BIND format to NSD format"
HOMEPAGE="http://bind2nsd.sourceforge.net"
SRC_URI="https://sourceforge.net/projects/bind2nsd/files/${PN}/${P}/${P}.tar.gz
	https://dev.gentoo.org/~bircoph/patches/${P}-patches-1.tar.xz"

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

PATCHES=( "${WORKDIR}/patches" )

src_prepare() {
	rm -rf pexpect-2.1 pyDes-1.2 || die
	default
}

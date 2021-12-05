# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..10} )
DISTUTILS_USE_SETUPTOOLS=no
inherit distutils-r1

DESCRIPTION="Python implementation of DES an Triple-DES algorithms"
HOMEPAGE="https://github.com/twhiteman/pyDes"
SRC_URI="https://dev.gentoo.org/~bircoph/distfiles/${P}.tar.xz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

python_test() {
	python test_pydes.py
}

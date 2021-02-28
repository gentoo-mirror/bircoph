# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8,9} )
DISTUTILS_USE_SETUPTOOLS=no
inherit distutils-r1

DESCRIPTION="Python implementation of DES an Triple-DES algorithms"
HOMEPAGE="http://twhiteman.netfirms.com/des.html"
SRC_URI="http://twhiteman.netfirms.com/pyDES/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

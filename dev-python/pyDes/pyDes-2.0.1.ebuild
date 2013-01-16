# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
SUPPORT_PYTHON_ABIS="1"

inherit distutils

DESCRIPTION="Python implementation of DES an Triple-DES algorithms"
HOMEPAGE="http://twhiteman.netfirms.com/des.html"
SRC_URI="http://twhiteman.netfirms.com/pyDES/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

PYTHON_MODNAME="pyDes.py"

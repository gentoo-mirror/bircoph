# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libnemesi/libnemesi-0.6.ebuild,v 1.1 2009/10/27 12:45:51 ssuominen Exp $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7} )
inherit git-2 python-r1

DESCRIPTION="Ren'Py's RPA data file extractor"
HOMEPAGE="https://github.com/Lattyware/unrpa"
EGIT_REPO_URI="https://github.com/Lattyware/unrpa.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND=${DEPEND}

pkg_setup() {
	python_pkg_setup
}

src_install() {
	dobin unrpa
	dodoc README
}

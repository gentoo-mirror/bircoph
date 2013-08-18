# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="System error description utility"
HOMEPAGE="http://strerror.sourceforge.net/"
SRC_URI="mirror://sourceforge/strerror/${P}.tar.bz2"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND=">=sys-devel/binutils-2.18"
RDEPEND=""

src_configure() {
	econf --disable-strip --enable-cflags
}

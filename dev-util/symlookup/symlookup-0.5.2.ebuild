# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

DESCRIPTION="Utility for searching of object files containing requested symbols"
HOMEPAGE="http://symbol-lookup.sourceforge.net/"
SRC_URI="mirror://sourceforge/symbol-lookup/${P}.tar.xz"
KEYWORDS="~x86 ~amd64"
LICENSE="GPL-3"
SLOT="0"
IUSE="+portage rpm"

DEPEND="
	dev-libs/elfutils
	portage? ( sys-apps/portage )
	rpm? ( app-arch/rpm )
"
RDEPEND="${DEPEND}"

src_configure() {
	local myconf="--disable-strip --enable-cflags"
	use portage || myconf+=" --disable-portage"
	use rpm || myconf+=" --disable-rpm"
	econf ${myconf}
}

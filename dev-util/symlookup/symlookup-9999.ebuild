# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

inherit subversion

DESCRIPTION="Utility for searching of object files containing requested symbols"
HOMEPAGE="http://symbol-lookup.sourceforge.net/"
ESVN_REPO_URI="svn://svn.code.sf.net/p/symbol-lookup/code/trunk"
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

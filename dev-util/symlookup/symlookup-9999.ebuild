# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

[[ ${PV} = *9999* ]] && inherit subversion
ESVN_REPO_URI="svn://svn.code.sf.net/p/symbol-lookup/code/trunk"

DESCRIPTION="Utility for searching of object files containing requested symbols"
HOMEPAGE="http://symbol-lookup.sourceforge.net/"
LICENSE="GPL-3"
SLOT="0"
IUSE="+portage rpm"

[[ ${PV} != *9999* ]] && {
	SRC_URI="mirror://sourceforge/symbol-lookup/${P}.tar.xz"
	KEYWORDS="~x86 ~amd64"
} || KEYWORDS=""

RDEPEND="
	dev-libs/elfutils
	portage? ( sys-apps/portage )
	rpm? ( app-arch/rpm )
"
DEPEND="${RDEPEND}"

src_unpack() {
	[[ ${PV} = *9999* ]] && subversion_src_unpack || default_src_unpack
}

src_configure() {
	local myconf="--disable-strip --enable-cflags"
	use portage || myconf+=" --disable-portage"
	use rpm || myconf+=" --disable-rpm"
	econf ${myconf}
}

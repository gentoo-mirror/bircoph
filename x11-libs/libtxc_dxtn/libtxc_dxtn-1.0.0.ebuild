# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit base multilib toolchain-funcs versionator

DESCRIPTION="Helper library for	S3TC texture (de)compression"
HOMEPAGE="http://cgit.freedesktop.org/~mareko/libtxc_dxtn"
SRC_URI="http://cgit.freedesktop.org/~mareko/libtxc_dxtn/snapshot/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="bindist"

src_compile() {
	local ABI

	tc-export CC
	for ABI in $(get_all_abis); do
		einfo "Building for ${ABI} ..."
		multilib_toolchain_setup ${ABI}
		mkdir ${ABI} || die
		emake || die
		mv ${PN}.so *.o ${ABI}/ || die
	done
}

src_install() {
	local ABI

	for ABI in $(get_all_abis); do
		dolib ${ABI}/${PN}.so || die
	done
}

pkg_postinst() {
	ewarn "Due to unclear patent situation, depending on where you live,"
	ewarn "you might need a valid license for s3tc in order to be legally"
	ewarn "allowed to use the external library."
	ewarn "Redistribution in binary form might also be problematic."
	ewarn
	ewarn "You have been warned. Have a nice day."
}

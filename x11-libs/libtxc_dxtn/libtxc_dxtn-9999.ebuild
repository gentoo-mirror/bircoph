# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit autotools autotools-utils git multilib

DESCRIPTION="Helper library for	S3TC texture (de)compression"
HOMEPAGE="http://cgit.freedesktop.org/~mareko/libtxc_dxtn/"
EGIT_REPO_URI="git://anongit.freedesktop.org/~mareko/libtxc_dxtn"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="bindist"

src_unpack() {
	git_src_unpack
}

foreachabi() {
	local ABI

	for ABI in $(get_all_abis); do
		multilib_toolchain_setup ${ABI}
		AUTOTOOLS_BUILD_DIR=${WORKDIR}/${ABI} "${@}"
	done
}

src_prepare() {
	autotools-utils_src_prepare
	eautoreconf
}

src_configure() {
	foreachabi autotools-utils_src_configure
}

src_compile() {
	foreachabi autotools-utils_src_compile
}

src_install() {
	foreachabi autotools-utils_src_install
	remove_libtool_files all
}

pkg_postinst() {
	ewarn "Depending on where you live, you might need a valid license for s3tc"
	ewarn "in order to be legally allowed to use the external library."
	ewarn "Redistribution in binary form might also be problematic."
	ewarn
	ewarn "You have been warned. Have a nice day."
}

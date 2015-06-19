# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/fdk-aac/fdk-aac-0.1.2.ebuild,v 1.2 2013/07/31 22:02:09 aballier Exp $

EAPI=5

if [[ ${PV} == *9999 ]] ; then
	SCM="git"
	EGIT_REPO_URI="git://github.com/mstorsjo/${PN}.git"
	[[ ${PV%9999} != "" ]] && EGIT_BRANCH="release/${PV%.9999}"
	AUTOTOOLS_AUTORECONF=yes
fi

inherit autotools-multilib ${SCM}

DESCRIPTION="Fraunhofer AAC codec library"
HOMEPAGE="http://sourceforge.net/projects/opencore-amr/"

if [[ ${PV} == *9999 ]] ; then
	SRC_URI=""
elif [[ ${PV%_p*} != ${PV} ]] ; then # Gentoo snapshot
	SRC_URI="mirror://gentoo/${P}.tar.xz"
else # Official release
	SRC_URI="mirror://sourceforge/opencore-amr/${P}.tar.gz"
fi

LICENSE="FraunhoferFDK"
SLOT="0"

[[ ${PV} == *9999 ]] || \
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86 ~amd64-fbsd ~x86-fbsd ~x64-macos"
IUSE="static-libs examples"

AUTOTOOLS_PRUNE_LIBTOOL_FILES=all

src_configure() {
	local myeconfargs=(
		"$(use_enable examples example)"
	)
	autotools-multilib_src_configure
}

src_install() {
	autotools-multilib_src_install
	use examples && mv "${ED}/usr/bin/aac-enc" "${ED}/usr/bin/fdk-aac-enc"
}

pkg_postinst() {
	use examples && einfo "aac-enc was renamed to fdk-aac-enc to prevent file collision with other packages"
}

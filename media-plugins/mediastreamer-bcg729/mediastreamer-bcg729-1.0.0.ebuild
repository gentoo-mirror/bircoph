# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils autotools multilib

MY_P="bcg729-${PV}"

DESCRIPTION="Backported G729 implementation for Linphone"
HOMEPAGE="http://www.linphone.org"
SRC_URI="mirror://nongnu/linphone/plugins/sources/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DOCS=( AUTHORS ChangeLog NEWS README )

RDEPEND="
	>=media-libs/mediastreamer-2.0.0
	>=net-libs/ortp-0.16.0"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_prepare(){
	# make sure to use host libtool version
	rm -f m4/libtool.m4 m4/lt*.m4 #282268
	eautoreconf
}

src_configure(){
	econf \
		--disable-static \
		--disable-strict \
		--libdir="${EPREFIX}/usr/$(get_libdir)"
}

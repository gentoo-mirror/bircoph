# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit eutils autotools multilib

MY_PN="mssilk"
SDK_FILE="SILK_SDK_SRC_v1.0.8.zip" # please update silk version on bumps!

DESCRIPTION="SILK (skype codec) implementation for Linphone"
HOMEPAGE="http://www.linphone.org"
SRC_URI="mirror://nongnu/linphone/plugins/sources/${MY_PN}-${PV}.tar.gz
http://developer.skype.com/silk/${SDK_FILE}"

LICENSE="GPL-3 as-is"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="bindist"

DEPEND=">=media-libs/mediastreamer-2.0.0"
RDEPEND="${DEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/${MY_PN}"

DOCS=( AUTHORS ChangeLog NEWS README )

RESTRICT="mirror" # silk license forbids distribution

pkg_setup() {
	if use bindist; then
		error "This package can't be redistributable due to SILK license."
		return 1
	fi
}

src_prepare() {
	epatch "${FILESDIR}/${P}-sdk.patch"
	eautoreconf
}

src_configure() {
	econf --libdir="${EPREFIX}/usr/$(get_libdir)"
}

src_install() {
	default
	# strip .la file for statically linked skype sdk
	sed -i 's/-lSKP_SILK_SDK//' \
		"${ED}usr/$(get_libdir)/mediastreamer/plugins/libmssilk.la" || die "sed failed"
	sed -r -i 's%-L[[:alnum:]/._-]*SILK_SDK_SRC[[:alnum:]/._-]*%%' libmssilk.la \
		"${ED}usr/$(get_libdir)/mediastreamer/plugins/libmssilk.la" || die "sed failed"
}

# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools git-r3

DESCRIPTION="a RTSP/RTP client library"
HOMEPAGE="https://github.com/bircoph/libnemesi"
EGIT_REPO_URI="https://github.com/bircoph/libnemesi.git"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE="doc examples ipv6 +sctp"

RDEPEND=">=net-libs/netembryo-0.0.9[sctp?]"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen[dot] )"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable ipv6) \
		$(use_enable sctp) \
		$(use_enable examples) \
		--disable-static \
		--disable-dependency-tracking
}

src_compile() {
	default
	use doc && doxygen
}

src_install() {
	default
	if use doc; then
		mv docs/html "${D}/usr/share/doc/${PF}/" || die
	fi
}

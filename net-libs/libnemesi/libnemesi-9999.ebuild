# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libnemesi/libnemesi-0.6.ebuild,v 1.1 2009/10/27 12:45:51 ssuominen Exp $

EAPI=2
inherit autotools git-2 multilib

DESCRIPTION="a RTSP/RTP client library"
HOMEPAGE="http://lscube.org/projects/libnemesi/"
EGIT_REPO_URI="git://git.lscube.org/libnemesi.git"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE="examples ipv6 +sctp"

DEPEND=">=net-libs/netembryo-0.0.9[sctp?]"
RDEPEND=${DEPEND}

src_prepare() {
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

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog CodingStyle README TODO
	find "${D}"usr/$(get_libdir) -name '*.la' -delete
}

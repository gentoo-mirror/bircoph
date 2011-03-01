# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-plugins/mediastreamer-ilbc/mediastreamer-ilbc-2.0.1.ebuild,v 1.3 2011/01/01 20:37:08 hwoarang Exp $

EAPI="3"

inherit multilib

MY_P="msilbc-${PV}"

DESCRIPTION="mediastreamer plugin: add iLBC support"
HOMEPAGE="http://www.linphone.org/"
SRC_URI="http://download.savannah.nongnu.org/releases/linphone/plugins/sources/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

RDEPEND="dev-libs/ilbc-rfc3951
	>=media-libs/mediastreamer-2.0.0"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

src_prepare() {
	sed -i -e "s:\(\$theprefix/\)lib:\1$(get_libdir):" configure \
		|| die "patching configure failed"
}

src_configure() {
	# dev-libs/ilbc-rfc3951 does not ship pkgconfig .pc file,
	# so these variables should be set here to satisfy configure
	export ILBC_CFLAGS="/usr/include"
	export ILBC_LIBS="/usr/include -lilbc"
	econf \
		--disable-dependency-tracking
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README || die "dodoc failed"
}

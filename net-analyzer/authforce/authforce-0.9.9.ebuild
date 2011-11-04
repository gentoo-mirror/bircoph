# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/authforce/authforce-0.9.9.ebuild,v 1.3 2009/06/09 15:49:40 flameeyes Exp $

EAPI=4

inherit base

DESCRIPTION="An HTTP authentication brute forcer"
HOMEPAGE="http://www.divineinvasion.net/authforce"
SRC_URI="http://www.divineinvasion.net/authforce/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc x86"
IUSE="curl nls"
DEPEND="sys-libs/readline
	nls? ( sys-devel/gettext )
	curl? ( net-misc/curl )"

PATCHES=( "${FILESDIR}/${P}-curl.patch" )

src_configure() {
	econf \
		$(use_with curl) \
		$(use_enable nls) \
		--with-path=/usr/share/${PN}/data:. || die
}

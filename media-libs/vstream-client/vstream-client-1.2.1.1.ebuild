# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="Allows streaming video from a hacked TiVo running vserver"
HOMEPAGE="http://code.google.com/p/vstream-client/"
SRC_URI="http://vstream-client.googlecode.com/files/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

src_configure() {
	./configure --prefix=/usr
}

src_install() {
	dolib libvstream-client.a
	dobin vstream-client
	insinto /usr/include/
	doins vstream-client.h
}

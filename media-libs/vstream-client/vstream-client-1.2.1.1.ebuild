# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Allows streaming video from a hacked TiVo running vserver"
HOMEPAGE="https://code.google.com/p/vstream-client/"
SRC_URI="https://storage.googleapis.com/google-code-archive-source/v2/code.google.com/vstream-client/source-archive.zip -> ${P}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

BDEPEND="app-arch/unzip"

src_configure() {
	./configure --prefix=/usr
}

src_install() {
	dolib.a libvstream-client.a
	dobin vstream-client
	insinto /usr/include/
	doins vstream-client.h
}

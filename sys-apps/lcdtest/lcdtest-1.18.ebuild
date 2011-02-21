# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils toolchain-funcs scons-utils

DESCRIPTION="Displays test patterns to spot dead/hot pixels on LCD screens"
HOMEPAGE="http://www.brouhaha.com/~eric/software/lcdtest/"
SRC_URI="http://www.brouhaha.com/~eric/software/lcdtest/download/${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

DEPEND=">=media-libs/libsdl-1.2.7-r2
	>=media-libs/sdl-image-1.2.3-r1
	>=media-libs/sdl-ttf-2.0.9"
RDEPEND="${DEPEND}
	media-fonts/liberation-fonts"

src_prepare() {
	epatch "${FILESDIR}/${P}-SConscript.patch"
	sed -i -e \
		"s|/usr/share/fonts/liberation/|/usr/share/fonts/liberation-fonts/|" \
		src/lcdtest.c || die
}

src_compile() {
	CC=$(tc-getCC) escons --prefix=/usr || die
}

src_install() {
	escons install --prefix=/usr --buildroot="${D}" || die
	dodoc README
}

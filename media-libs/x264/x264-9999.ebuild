# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/x264/x264-0.0.20100423.ebuild,v 1.1 2010/04/24 15:46:48 aballier Exp $

EAPI=2
inherit eutils multilib toolchain-funcs git

EGIT_REPO_URI="git://git.videolan.org/x264.git"

DESCRIPTION="A free library for encoding X264/AVC streams"
HOMEPAGE="http://www.videolan.org/developers/x264.html"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="debug +threads pic"

RDEPEND=""
DEPEND="amd64? ( >=dev-lang/yasm-0.6.2 )
	x86? ( >=dev-lang/yasm-0.6.2 )
	x86-fbsd? ( >=dev-lang/yasm-0.6.2 )"

src_unpack() {
	git_src_unpack
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-nostrip.patch \
		"${FILESDIR}"/${PN}-onlylib.patch
}

src_configure() {
	tc-export CC

	local myconf=""
	use debug && myconf="${myconf} --enable-debug"

	if use x86 && use pic; then
		myconf="${myconf} --disable-asm"
	fi

	./configure \
		--prefix=/usr \
		--libdir=/usr/$(get_libdir) \
		--disable-avs \
		--disable-lavf \
		--disable-swscale \
		--disable-gpac \
		$(use threads || echo "--disable-thread") \
		--enable-pic \
		--enable-shared \
		--extra-asflags="${ASFLAGS}" \
		--extra-cflags="${CFLAGS}" \
		--extra-ldflags="${LDFLAGS}" \
		--host="${CHOST}" \
		${myconf} \
		|| die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS doc/*.txt
}

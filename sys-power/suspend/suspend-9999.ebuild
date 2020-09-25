# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools git-r3

DESCRIPTION="Userspace Software Suspend and S2Ram"
HOMEPAGE="http://suspend.sourceforge.net
https://github.com/bircoph/suspend"
EGIT_REPO_URI="https://github.com/bircoph/${PN}.git"

LICENSE="GPL-2"
SLOT="0"
IUSE="crypt +lzo threads"

RDEPEND="
	dev-libs/libx86
	>=sys-apps/pciutils-2.2.4
	crypt? (
		>=dev-libs/libgcrypt-1.6.3:0[static-libs]
		dev-libs/libgpg-error[static-libs] )
	lzo? ( >=dev-libs/lzo-2[static-libs] ) "
DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-lang/perl-5.10
	virtual/pkgconfig"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--disable-fbsplash \
		$(use_enable crypt encrypt) \
		$(use_enable lzo compress) \
		$(use_enable threads)
}

src_install() {
	dodir etc
	emake DESTDIR="${D}" install
	rm "${D}/usr/share/doc/${PF}"/COPYING* || die
}

pkg_postinst() {
	elog "In order to make this package work with genkernel see:"
	elog "https://bugs.gentoo.org/show_bug.cgi?id=156445"
}

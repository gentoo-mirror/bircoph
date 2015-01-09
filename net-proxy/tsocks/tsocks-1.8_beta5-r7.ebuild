# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-proxy/tsocks/tsocks-1.8_beta5-r6.ebuild,v 1.2 2015/01/08 14:58:40 bircoph Exp $

EAPI="5"

inherit autotools eutils multilib toolchain-funcs

DESCRIPTION="Transparent SOCKS v4 proxying library"
HOMEPAGE="http://tsocks.sourceforge.net/"
SRC_URI="mirror://sourceforge/tsocks/${PN}-${PV/_}.tar.gz
	tordns? ( http://dev.gentoo.org/~bircoph/patches/${PN}-${PV/_beta/b}-tordns1-gentoo-r3.patch.xz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="dns envconf tordns server-lookups"

REQUIRED_USE="
	dns? ( !dns !server-lookups )
	tordns? ( !tordns !server-lookups )
"

S="${WORKDIR}/${P%%_*}"

src_prepare() {
	epatch \
	"${FILESDIR}/${P}-flags.patch" \
	"${FILESDIR}/${P}-ld_preload.patch" \
	"${FILESDIR}/${P}-rename.patch" \
	"${FILESDIR}/${P}-bsd.patch" \
	"${FILESDIR}/${P}-poll.patch"
	use tordns && epatch "../${PN}-${PV/_beta/b}-tordns1-gentoo-r3.patch"

	sed -i 's/TSOCKS_CONFFILE/TSOCKS_CONF_FILE/' tsocks.8 || die "sed tsocks.8 failed"
	eautoreconf
}

src_configure() {
	tc-export CC

	# NOTE: the docs say to install it into /lib. If you put it into
	# /usr/lib and add it to /etc/ld.so.preload on many systems /usr isn't
	# mounted in time :-( (Ben Lutgens) <lamer@gentoo.org>
	econf \
		$(use_enable dns socksdns) \
		$(use_enable envconf) \
		$(use_enable server-lookups hostnames) \
		--with-conf=/etc/socks/tsocks.conf \
		--libdir=/$(get_libdir)
}

src_compile() {
	# Fix QA notice lack of SONAME
	emake DYNLIB_FLAGS=-Wl,--soname,libtsocks.so.${PV/_beta*}
}

src_install() {
	emake DESTDIR="${D}" install
	newbin validateconf tsocks-validateconf
	newbin saveme tsocks-saveme
	dobin inspectsocks
	insinto /etc/socks
	doins tsocks.conf.*.example
	dodoc FAQ
	use tordns && dodoc README*
}

pkg_postinst() {
	einfo "Make sure you create /etc/socks/tsocks.conf from one of the examples in that directory"
	einfo "The following executables have been renamed:"
	einfo "    /usr/bin/saveme renamed to tsocks-saveme"
	einfo "    /usr/bin/validateconf renamed to tsocks-validateconf"
}

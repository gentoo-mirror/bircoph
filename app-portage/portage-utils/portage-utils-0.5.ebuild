# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/portage-utils/portage-utils-0.5.ebuild,v 1.1 2011/03/17 04:08:37 vapier Exp $

EAPI="4"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="small and fast portage helper tools written in C"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="static"

src_prepare() {
	epatch "${FILESDIR}/qlop-0.5.patch"
}

src_compile() {
	tc-export CC
	use static && append-ldflags -static
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die

	exeinto /etc/portage/bin
	doexe "${FILESDIR}"/post_sync || die
	insinto /etc/portage/postsync.d
	doins "${FILESDIR}"/q-reinitialize || die
}

pkg_preinst() {
	# preserve +x bit on postsync files #301721
	local x
	pushd "${D}" >/dev/null
	for x in etc/portage/postsync.d/* ; do
		[[ -x ${ROOT}/${x} ]] && chmod +x "${x}"
	done
}

pkg_postinst() {
	elog "/etc/portage/postsync.d/q-reinitialize has been installed for convenience"
	elog "If you wish for it to be automatically run at the end of every --sync:"
	elog "   # chmod +x /etc/portage/postsync.d/q-reinitialize"
	elog "Normally this should only take a few seconds to run but file systems"
	elog "such as ext3 can take a lot longer.  To disable, simply do:"
	elog "   # chmod -x /etc/portage/postsync.d/q-reinitialize"
}

# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib

DESCRIPTION="Windows 32-bit binary codecs for video and audio playback support"
SRC_URI="mirror://mplayer/releases/codecs/all-${PV}.tar.bz2"
HOMEPAGE="http://www.mplayerhq.hu/"
LICENSE="HPND"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="real"

S="${WORKDIR}/all-${PV}"

RESTRICT="strip binchecks"

pkg_setup() {
	# This is a binary x86 package => ABI=x86
	# Please keep this in future versions
	# Daniel Gryniewicz <dang@gentoo.org>
	has_multilib_profile && ABI="x86"
}

src_install() {
	insinto /usr/$(get_libdir)/win32
	doins *.dll *.ax *.xa *.acm *.vwp *.drv *.DLL *.qtx *.qts *.DRV *.vcm

	if use real
	then
		insinto /usr/$(get_libdir)/real
		doins *so.6.0

		# copy newly introduced codecs from realplayer10
		# see the ChangeLog online
		doins *.so

		# fix bug #80321
		local x
		for x in *so.6.0 *.so; do
			dosym ../real/$x /usr/$(get_libdir)/win32
		done
	fi

	dodoc README

	cat > "${T}/50${PN}" <<EOF
SEARCH_DIRS_MASK="${EPREFIX}/usr/$(get_libdir)/real ${EPREFIX}/usr/$(get_libdir)/win32"
EOF
	insinto /etc/revdep-rebuild
	doins "${T}/50${PN}"
}

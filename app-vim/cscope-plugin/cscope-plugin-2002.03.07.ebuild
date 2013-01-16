# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4
inherit vim-plugin
MY_PN="cscope_maps.vim"

DESCRIPTION="vim plugin: cscope settings"
HOMEPAGE="http://cscope.sourceforge.net/cscope_vim_tutorial.html"
SRC_URI="http://cscope.sourceforge.net/${MY_PN}"
LICENSE="as-is"
KEYWORDS="~amd64 ~x86"
IUSE="swap-meta"
RDEPEND="app-editors/vim[cscope]"

VIM_PLUGIN_HELPTEXT=\
"This plugin provides C-\ and C-@ shortcuts for :[s]cs f commands and
simplifies cscope DB loading."

src_unpack() {
	mkdir -p "${S}/plugin"
	cp "${DISTDIR}/${A}" "${S}/plugin/"
}

src_prepare() {
	if use swap-meta; then
		sed -i 's%C-\\%C-X%g' "plugin/${MY_PN}" || die "sed failed"
		sed -i 's%C-@%C-\\%g' "plugin/${MY_PN}" || die "sed failed"
		sed -i 's%C-X%C-@%g' "plugin/${MY_PN}" || die "sed failed"
	fi
}

# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/unadf/unadf-0.7.9b.ebuild,v 1.11 2010/01/01 19:41:00 fauli Exp $

EAPI=5

inherit autotools eutils

DESCRIPTION="Extract files from Amiga adf disk images"
SRC_URI="http://lclevy.free.fr/adflib/adflib-0.7.12.tar.bz2"
HOMEPAGE="http://lclevy.free.fr/adflib/"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="hppa ppc x86 ~amd64 ~x86-interix ~x86-linux ~x86-solaris ~ppc-macos ~sparc-solaris"
IUSE="static-libs"
DEPEND=""
RDEPEND=""

MY_PN="adflib"
S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf $(use_enable static-libs static)
}

src_install() {
	default
	prune_libtool_files
}

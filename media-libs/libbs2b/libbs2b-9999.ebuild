# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils autotools subversion

DESCRIPTION="Bauer stereophonic-to-binaural DSP library"
HOMEPAGE="http://bs2b.sourceforge.net/"
ESVN_REPO_URI="http://bs2b.svn.sourceforge.net/svnroot/bs2b/trunk/libbs2b"
ESVN_PROJECT="libbs2b"
S="${WORKDIR}/${PN}"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="media-libs/libsndfile"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_unpack()
{
	subversion_src_unpack
	./autogen.sh
}

src_install()
{
	emake install DESTDIR="${D}" || die "emake install failed"
}

# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit toolchain-funcs

MY_PN="NetPIPE"
MY_P="${MY_PN}-${PV}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="A Network Protocol Independent Performance Evaluator"
HOMEPAGE="http://bitspjoule.org/netpipe/"
SRC_URI="http://bitspjoule.org/netpipe/code/${MY_P}.tar.gz"

LICENSE="GPL-1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples infiniband ipv6 +memcpy mpi sctp +tcp utils"

DEPEND="
	infiniband? ( sys-fabric/ofed )
	mpi? ( virtual/mpi )
"
RDEPEND="${DEPEND}
	utils? (
		app-shells/tcsh
		app-text/gv
		sci-visualization/gnuplot
		virtual/ssh
	)
"

# ipv6 is meaningless itself, but enables tcp6 or sctp6
# at least single test module must be enabled
REQUIRED_USE="
	ipv6? ( || ( sctp tcp ) )
	|| ( memcpy infiniband mpi sctp tcp )
"

PATCHES=(
	"${FILESDIR}/${P}-ipv6.patch"
	"${FILESDIR}/${PN}-3.7.1-gv.patch"
	"${FILESDIR}/${PN}-3.7.1-makefile.patch" )

src_configure() {
	# no configure script, create list of make targets
	make_targets=""
	use memcpy			 && make_targets+="memcpy "
	use mpi				 && make_targets+="mpi mpi2 "
	use infiniband		 && make_targets+="ibv "
	use sctp			 && make_targets+="sctp "
	use sctp && use ipv6 && make_targets+="sctp6 "
	use tcp				 && make_targets+="tcp "
	use tcp && use ipv6  && make_targets+="tcp6 "
}

src_compile() {
	CC=$(tc-getCC) emake ${make_targets}
	unset ${make_targets}
}

src_install() {
	# no install target, going manual
	dobin NP*
	dodoc dox/README
	doman dox/netpipe.1

	use utils && dobin bin/*

	use doc && dodoc dox/{netpipe_paper.ps,np_cluster2002.pdf,np_euro.pdf}
	if use examples; then
	    docinto examples
	    dodoc hosts/*
	fi
}

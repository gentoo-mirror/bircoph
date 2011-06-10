# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit base linux-info

DESCRIPTION="Userspace tools for kernel L2TP implementation."
HOMEPAGE="http://openl2tp.sourceforge.net"
SRC_URI="mirror://sourceforge/openl2tp/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+client doc +examples pppd rpc server -stats"

REQUIRED_USE="|| ( client server )"

CDEPEND="net-dialup/ppp
	sys-libs/readline
	"
DEPEND="${CDEPEND}
	sys-devel/bison
	sys-devel/flex
	"
RDEPEND="${CDEPEND}
	rpc? ( || (
		net-nds/rpcbind
		net-nds/portmap
	) )"

CONFIG_CHECK="~PPPOL2TP"

PATCHES=(
	"${FILESDIR}/${P}-werror.patch"
	"${FILESDIR}/${P}-ldflags.patch"
	"${FILESDIR}/${P}-pppd-2.patch"
	"${FILESDIR}/${P}-man.patch"
	"${FILESDIR}/${P}-l2tpconfig.patch"
	"${FILESDIR}/${P}-parallelbuild.patch"
	"${FILESDIR}/${P}-optionsfile.patch"
	"${FILESDIR}/${P}-clientip_as_ipparam.patch"
	"${FILESDIR}/${P}-setkey.patch"
)

src_configure() {
	myconf=""	# not local, should be used at src_compile()

	use client || myconf+="L2TP_FEATURE_LAC_SUPPORT=n \
						   L2TP_FEATURE_LAIC_SUPPORT=n \
						   L2TP_FEATURE_LAOC_SUPPORT=n "

	use server || myconf+="L2TP_FEATURE_LNS_SUPPORT=n \
						   L2TP_FEATURE_LNIC_SUPPORT=n \
						   L2TP_FEATURE_LNOC_SUPPORT=n "

	use rpc || myconf+="L2TP_FEATURE_RPC_MANAGEMENT=n "

	use stats && myconf+="L2TP_FEATURE_LOCAL_STAT_FILE=y "

	# pppd plugin is only needed for pppd < 2.4.5
	unset PPPD_SUBDIR
	if use pppd; then
		export PPPD_VERSION=$( gawk '{
			if ($2=="VERSION") {
				gsub("\"","",$3);
				print $3
			}
		}' /usr/include/pppd/patchlevel.h ) || die "gawk failed"
		einfo "Building for pppd version $PPPD_VERSION"
	fi
}

src_compile() {
	# upstream use OPT_CFLAGS for optimizations
	export OPT_CFLAGS=${CFLAGS}
	emake ${myconf} || die "emake failed"
}

src_install() {
	emake ${myconf} DESTDIR="${D}" install || die "emake install failed"
	dodoc CHANGES INSTALL README

	if use examples; then
		dodoc doc/*.c
	fi

	if use doc; then
		dodoc doc/*.txt doc/README.event_sock "${FILESDIR}"/openl2tpd.conf.sample
		newdoc plugins/README README.plugins
		use pppd && newdoc pppd/README README.pppd
		docinto ipsec
		dodoc ipsec/*
	fi

	newinitd "${FILESDIR}"/openl2tpd.initd openl2tpd
	# init.d script is quite different for RPC and non-RPC versions.
	use rpc || sed -i s/userpc=\"yes\"/userpc=\"no\"/ "${D}/etc/init.d/openl2tpd" || die "sed failed"
	newconfd "${FILESDIR}"/openl2tpd.confd openl2tpd
}

pkg_postinst() {
	if use rpc; then
		ewarn
		ewarn "RPC control does not provide any auth checks for control connection."
		ewarn "Unless you need this you should disable it, for reference:"
		ewarn "http://forums.openl2tp.org/viewtopic.php?f=4&t=41"
		ewarn
		ewarn "Therefore DO NOT USE RPC IN INSECURE ENVIRONMENTS!"
	else
		ewarn
		ewarn "Without RPC support you won't be able to use l2tpconfig."
		ewarn "Please read http://forums.openl2tp.org/viewtopic.php?f=4&t=41"
		ewarn "for more information about the security risk before enabling."
		ewarn
		ewarn "If you are using numerical strings (e.g. login name containing only"
		ewarn "digits) or special characters in password, please use double quotes"
		ewarn "to enclose them."
	fi
	if use stats; then
		ewarn
		ewarn "To enable status files openl2tpd must be started with -S option."
		ewarn "Upstream warns about runtime overhead with status files enabled."
	fi
}

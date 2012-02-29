# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-cluster/pvfs2/Attic/pvfs2-2.7.1-r1.ebuild,v 1.3 2011/07/15 13:57:08 xarthisius dead $

EAPI=4
inherit autotools linux-info linux-mod toolchain-funcs

DESCRIPTION="OrangeFS is a branch of PVFS2 cluster filesystem"
HOMEPAGE="http://www.orangefs.org/"
SRC_URI="http://orangefs.org/downloads/2.8.5/source/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+aio apidocs debug doc examples fuse gtk infiniband memtrace +mmap
+modules open-mx secure +sendfile +server ssl static +tcp +threads valgrind"

CDEPEND="
	dev-lang/perl
	>=sys-libs/db-4.8.30
	virtual/perl-Math-BigInt
	fuse? ( sys-fs/fuse )
	gtk? ( x11-libs/gtk+:2 )
	infiniband? ( sys-infiniband/openib )
	open-mx? ( sys-cluster/open-mx )
	ssl? ( dev-libs/openssl )
	valgrind? ( dev-util/valgrind )
"
RDEPEND="${CDEPEND}
	modules? ( sys-apps/module-init-tools )
"
DEPEND="${CDEPEND}
	>=sys-devel/autoconf-2.59
	sys-devel/bison
	sys-devel/flex
	apidocs? ( app-doc/doxygen )
	doc? ( dev-tex/latex2html )
	modules? ( virtual/linux-sources )
"

# aio and sendfile are only meaningful for kernel module;
# apidocs needs docs to be build first;
# memtrace and valgrind witout debug info will be a pain;
# if both Myrinet and TCP interfaces are enabled in BMI, 5 sec delays will
# occur, though, at lest one of them must be enabled
REQUIRED_USE="
	aio? ( modules )
	apidocs? ( doc )
	sendfile? ( modules )
	memtrace? ( debug )
	tcp? ( !infiniband !open-mx )
	valgrind? ( debug )
	|| ( infiniband open-mx tcp )
"

BUILD_TARGETS="just_kmod"
MODULE_NAMES="pvfs2(fs::src/kernel/linux-2.6)"

src_prepare() {
	# Upstream doesn't seem to want to apply this which makes
	# sense as it probably only matters to us.  Simple patch
	# to split the installation of the module (which we use
	# the eclass for) and the installation of the kernapps.
	epatch "${FILESDIR}"/${P}-split-kernapps.patch

	# Make visualization tools (VIS) build controllable via configure options,
	# otherwise it will be automagically enabled when SDL libraries are present.
	epatch "${FILESDIR}"/${P}-vis.patch

	# Fix build of a static server
	epatch "${FILESDIR}"/${P}-static-server.patch

	# Fix sandbox violation during pvfs2fuse install
	epatch "${FILESDIR}"/${P}-fuse.patch

	# Change defalt server logfile location to more appropriate value
	# used by init script.
	sed -i "s%/tmp/pvfs2-server.log%/var/log/pvfs2/server.log%g" \
	src/apps/admin/pvfs2-genconfig || die "sed on pvfs2-genconfig failed"

	AT_M4DIR=./maint/config eautoreconf
}

src_configure() {
	# VIS build is broken at this moment.
	# Please add SDL dependency on reenable.

	local myconf=""

	use threads && use aio || myconf+=" --disable-aio-threaded-callbacks"
	use threads && use modules && myconf+=" --enable-threaded-kmod-helper"

	# fast mode disables optimizations
	use debug && myconf+=" --disable-fast --with-berkdb-debug" \
			  || myconf+=" --enable-fast  --without-berkdb-debug"

	use modules && myconf+=" --with-kernel=${KV_DIR}"

	# ARCH is used to define linux header path, should be not set.
	unset ARCH
	econf \
		--disable-nptl-workaround \
		--disable-redhat24 \
		--enable-epoll \
	    --enable-shared \
		--enable-thread-safety \
		--enable-verbose-build \
	    --sysconfdir="${EPREFIX}"/etc/pvfs2 \
	    $(use_enable aio kernel-aio) \
	    $(use_enable debug perf-counters) \
	    $(use_enable debug segv-backtrace) \
	    $(use_enable fuse) \
	    $(use_enable gtk karma) \
	    $(use_enable mmap mmap-racache) \
	    $(use_enable secure trusted-connections) \
	    $(use_enable sendfile kernel-sendfile) \
	    $(use_enable server) \
	    $(use_enable static) \
	    $(use_enable static static-server) \
	    $(use_with infiniband openib "${EPREFIX}"/usr/) \
	    $(use_with memtrace mtrace) \
	    $(use_with open-mx mx "${EPREFIX}"/usr/) \
	    $(use_with ssl openssl "${EPREFIX}"/usr/) \
	    $(use_with tcp bmi-tcp) \
	    $(use_with valgrind) \
		${myconf}
}

src_compile() {
	emake all
	if use modules; then
		linux-mod_src_compile || die "kernel module compilation failed"
		emake kernapps
	fi

	use doc && emake docs
	if use apidocs; then
		cd "${S}"/doc
		doxygen doxygen/pvfs2-doxygen.conf || die "doxygen failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install
	if use modules; then
		linux-mod_src_install || die
		emake DESTDIR="${D}" kernapps_install
	fi

	if use server; then
	    newinitd "${FILESDIR}"/pvfs2-server-init.d pvfs2-server
	    newconfd "${FILESDIR}"/pvfs2-server-conf.d pvfs2-server
	fi

	newinitd "${FILESDIR}"/pvfs2-client-init.d pvfs2-client
	newconfd "${FILESDIR}"/pvfs2-client-conf.d pvfs2-client

	dodoc AUTHORS CREDITS ChangeLog INSTALL README

	if use doc; then
		dodoc doc/{coding/,}*.{pdf,txt} doc/random/*.pdf \
			doc/{coding/valgrind,add-client-syscall,add-server-req,REFERENCES.bib}

	    if use apidocs; then
	        dohtml -A map -A md5 doc/doxygen/html/*
	    fi

		docinto design
		dodoc doc/design/*.{pdf,txt}
	fi
	if use examples; then
	    docinto examples
	    dodoc -r examples/heartbeat examples/fs.conf
	fi
}

pkg_postinst() {
	linux-mod_pkg_postinst || die
	local f="$(source "${ROOT}"etc/conf.d/pvfs2-server; echo ${PVFS2_FS_CONF})"
	elog "OrangeFS is a PVFS2 successor and uses a unified configuration file."
	elog
	elog "1) If you have configuration files from an earlier PVFS2 versions,"
	elog "use the provided:"
	elog "${ROOT}usr/bin/pvfs2-config-convert"
	elog "to automatically update to the newer configuration scheme."
	elog
	elog "2) Use emerge --config orangefs to create new configuration files."
	elog
	elog "3) If the storage space has not been previously created, either set"
	elog "PVFS2_AUTO_MKFS=1 in ${ROOT}etc/conf.d/pvfs2-server or run:"
	elog "${ROOT}usr/sbin/pvfs2-server --mkfs ${f}"
	elog
	elog "4) orangefs pvfs2-server init script can now be multiplexed."
	elog "The default init script forces /etc/pvfs2/fs.conf to exist."
	elog "If you symlink the init script to another one, say pvfs2-server.foo"
	elog "then that uses /etc/pvfs2/foo.fs.conf instead."
	elog
	elog "Example:"
	elog "  cd /etc/init.d"
	elog "  ln -s pvfs2-server pvfs2-server.foo"
	elog "You can now treat pvfs2-server.foo like any other service"
	elog
	elog "5) OrangeFS supports ROMIO I/O. You should build your MPI package"
	elog "with USE=romio in order to use it."
	elog
	elog "6) To use configured and created partition aside from starting "
	elog "pvfs2-server you should either provide an /etc/fstab or /etc/pvfs2tab"
	elog "entry (recommended) like:"
	elog "tcp://testhost:3334/pvfs2-fs /mnt/pvfs2 pvfs2 defaults,noauto 0 0"
	elog "or mount partition specifying full paths prior to usage even with"
	elog "PVFS2 libraries without kernel VFS. The same applies for ROMIO I/O"
	elog "interface."
}

pkg_config() {
	local s
	local f="$(source "${ROOT}"etc/conf.d/pvfs2-server; echo ${PVFS2_FS_CONF})"
	[[ -z "${f}" ]] && f="${ROOT}etc/pvfs2/fs.conf"
	if [[ -f "${f}" ]]; then
		ewarn "Previous install detected."
		ewarn "We're about to wipe out ${f} and replace it with"
		ewarn "the file generated by running pvfs2-genconfig.  If this is what"
		ewarn "you want to do, hit any key to continue.  Otherwise hit ctrl+C"
		ewarn "to abort."
		read s
	fi
	einfo "Creating unified configuration file"
	ewarn "WARNING: OrangeFS is picky about hostnames.  Make sure you use the"
	ewarn "correct shortname for all nodes and have name resolution for these"
	ewarn "shortnames correctly configured on all nodes."
	[ ! -d "${ROOT}$(dirname "${f}")" ] && mkdir -p "${ROOT}$(dirname "${f}")"
	"${ROOT}"usr/bin/pvfs2-genconfig "${f}"
}
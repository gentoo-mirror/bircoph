# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit autotools linux-info linux-mod readme.gentoo-r1

PV_MAJ="2.9beta"
MY_P="${PN}-${PV_MAJ}.20130530"

DESCRIPTION="OrangeFS is a branch of PVFS2 cluster filesystem"
HOMEPAGE="https://www.orangefs.org/"
SRC_URI="https://s3.amazonaws.com/download.orangefs.org/releases/2.9beta/source/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="aio apidocs capcache certcache debug doc examples fuse gtk infiniband
kmod-threads ldap memtrace +mmap modules reset-file-pos security-key
security-cert sendfile +server ssl static static-libs +tcp +threads
trusted-connections +usrint usrint-cache +usrint-cwd usrint-kmount valgrind"

DEPEND="
	dev-lang/perl
	>=sys-libs/db-4.8.30:=
	virtual/perl-Math-BigInt
	fuse? ( sys-fs/fuse:= )
	gtk? ( x11-libs/gtk+:2 )
	infiniband? ( sys-fabric/ofed )
	ldap? ( net-nds/openldap )
	ssl? ( dev-libs/openssl[static-libs?] )
	valgrind? ( dev-util/valgrind )
"
RDEPEND="${DEPEND}
	modules? ( sys-apps/kmod )
"
BDEPEND="
	>=sys-devel/autoconf-2.59
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
	apidocs? ( app-doc/doxygen )
	doc? ( dev-tex/latex2html )
	modules? ( virtual/linux-sources )
"

# aio and sendfile are only meaningful for kernel module;
# apidocs needs docs to be build first;
# kernel threads obviously needs kernel module and threads
# memtrace and valgrind witout debug info will be a pain;
# if both Myrinet and TCP interfaces are enabled in BMI, 5 sec delays will
# occur, though, at lest one of them must be enabled;
# static flag affects only server, so it must depend on it;
REQUIRED_USE="
	aio? ( modules )
	apidocs? ( doc )
	capcache? ( || ( security-cert security-key ) )
	certcache? ( security-cert )
	kmod-threads? ( modules threads )
	memtrace? ( debug )
	reset-file-pos? ( modules )
	security-cert? ( ldap ssl )
	security-key? ( ssl )
	sendfile? ( modules )
	static? ( server static-libs )
	tcp? ( !infiniband )
	usrint-cache? ( usrint )
	usrint-cwd? ( usrint )
	usrint-kmount? ( usrint )
	valgrind? ( debug )
	|| ( infiniband tcp )
	?? ( security-cert security-key )
"

BUILD_TARGETS="just_kmod"
MODULE_NAMES="pvfs2(fs::src/kernel/linux-2.6)"

pkg_setup() {
	use modules && linux-mod_pkg_setup
	if use modules && kernel_is -ge 3 4; then
		eerror "Sorry, linux kernels >= 3.4 are not support yet."
		eerror "(Well they are, but you'll have a dead lock.)"
		eerror "You may disable modules use flag and use fuse client to mount filesystem."
		eerror "PVFS2 server and ROMIO I/O API are still available too."
		return 1
	fi

	if use security-key || use security-cert && ! use capcache; then
		ewarn "Upstream recommends to enable capabilities cache (--enable-capcache) when"
		ewarn "security-key or security-cert is used."
	fi
	if use security-cert && ! use certcache; then
		ewarn "Upstream recommends to enable certificate cache (--enable-certcache) when"
		ewarn "security-cert is used."
	fi
}

src_prepare() {
	# Upstream doesn't seem to want to apply this which makes
	# sense as it probably only matters to us.  Simple patch
	# to split the installation of the module (which we use
	# the eclass for) and the installation of the kernapps.
	epatch "${FILESDIR}"/${PN}-2.8.5-split-kernapps.patch

	# Fix libm underliking issue for kernapps
	epatch "${FILESDIR}"/${P}-kernapps-lm.patch

	# Change defalt server logfile location to more appropriate value
	# used by init script.
	sed -i "s%/tmp/pvfs2-server.log%${EPREFIX}var/log/pvfs2/server.log%g" \
	src/apps/admin/pvfs2-genconfig || die "sed on pvfs2-genconfig failed"

	AT_M4DIR=./maint/config eautoreconf
}

src_configure() {
	local myconf=""

	use threads && use aio || myconf+=" --disable-aio-threaded-callbacks"

	# fast mode disables optimizations
	use debug && myconf+=" --disable-fast --with-berkdb-debug" \
			  || myconf+=" --enable-fast  --without-berkdb-debug"

	use modules && myconf+=" --with-kernel=${KV_DIR}"

	# ARCH is used to define linux header path, should be not set.
	unset ARCH
	# FIXME: VIS build is broken at this moment.
	# Please add SDL dependency on reenable.
	# Note: jdk, jni, hadoop are disabled because hadoop is out of portage
	# and jdk/jni is useless otherwise
	econf \
		--disable-jni \
		--disable-hadoop \
		--disable-nptl-workaround \
		--disable-redhat24 \
		--disable-visual \
		--enable-epoll \
	    --enable-shared \
		--enable-verbose-build \
	    --sysconfdir="${EPREFIX}"/etc/pvfs2 \
	    $(use_enable aio kernel-aio) \
	    $(use_enable capcache) \
	    $(use_enable certcache) \
	    $(use_enable debug perf-counters) \
	    $(use_enable debug segv-backtrace) \
	    $(use_enable fuse) \
	    $(use_enable gtk karma) \
	    $(use_enable mmap mmap-racache) \
	    $(use_enable kmod-threads threaded-kmod-helper) \
	    $(use_enable reset-file-pos) \
	    $(use_enable security-cert) \
	    $(use_enable security-key) \
	    $(use_enable sendfile kernel-sendfile) \
	    $(use_enable server) \
	    $(use_enable static static-server) \
	    $(use_enable static-libs static) \
	    $(use_enable trusted-connections) \
	    $(use_enable usrint) \
	    $(use_enable usrint-cache ucache) \
	    $(use_enable usrint-cwd) \
	    $(use_enable usrint-kmount) \
	    $(use_with infiniband openib "${EPREFIX}"/usr/) \
	    $(use_with memtrace mtrace) \
	    $(use_with ldap) \
	    $(use_with ssl) \
	    $(use_with tcp bmi-tcp) \
	    $(use_with valgrind) \
		${myconf}
}

src_compile() {
	emake all
	if use modules; then
		linux-mod_src_compile
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
		linux-mod_src_install
		emake DESTDIR="${D}" kernapps_install

		newinitd "${FILESDIR}"/pvfs2-client-init.d pvfs2-client
		newconfd "${FILESDIR}"/pvfs2-client-conf.d pvfs2-client
	fi

	if use server; then
	    newinitd "${FILESDIR}"/pvfs2-server-init.d pvfs2-server
	    newconfd "${FILESDIR}"/pvfs2-server-conf.d pvfs2-server
	fi

	keepdir "${EPREFIX}var/log/pvfs2"

	dodoc AUTHORS CREDITS ChangeLog INSTALL README SecuritySetup
	readme.gentoo_create_doc

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
	    dodoc -r examples/{certs,heartbeat,keys}
	fi
}

pkg_postinst() {
	use modules && linux-mod_pkg_postinst

	readme.gentoo_print_elog
	if ! use modules; then
		ewarn
		ewarn "Without modules support you wouldn't be able to use pvfs2-client and mount"
		ewarn "partitions using kernel VFS. Though, you are still able to use libpvfs2,"
		ewarn "ROMIO interface, and FUSE client (if fuse use flag is enabled)."
	fi
	if use modules && kernel_is -ge 3 1; then
		ewarn
		ewarn "ACL support for 3.1 and 3.2 kernels is known to have bugs."
	fi
	if use sendfile; then
		ewarn
		ewarn "With sendfile enabled performance will be degraded for small access patterns."
	fi
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
	[ ! -d "${ROOT}$(dirname "${f}")" ] && mkdir -p "${ROOT}$(dirname "${f}")"
	"${ROOT}"usr/bin/pvfs2-genconfig "${f}"
}

# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/wine/wine-1.3.26.ebuild,v 1.5 2011/08/20 19:23:56 vapier Exp $

EAPI="2"

inherit eutils flag-o-matic multilib

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="git://source.winehq.org/git/wine.git"
	inherit git-2
	SRC_URI=""
	#KEYWORDS=""
else
	AUTOTOOLS_AUTO_DEPEND="no"
	MY_P="${PN}-${PV/_/-}"
	SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"
	KEYWORDS="-* ~amd64 ~x86 ~x86-fbsd"
	S=${WORKDIR}/${MY_P}
fi

GV="1.4"
DESCRIPTION="free implementation of Windows(tm) on Unix"
HOMEPAGE="http://www.winehq.org/"
SRC_URI="${SRC_URI}
	gecko? (
		mirror://sourceforge/wine/wine_gecko-${GV}-x86.msi
		win64? ( mirror://sourceforge/wine/wine_gecko-${GV}-x86_64.msi )
	)"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="alsa capi cups custom-cflags dbus fontconfig +gecko gnutls gphoto2 gsm gstreamer hardened jpeg lcms ldap mp3 ncurses nls openal opencl +opengl +oss +perl png prelink samba scanner ssl test +threads +truetype v4l +win32 +win64 +X xcomposite xinerama xml"
RESTRICT="test" #72375

MLIB_DEPS="amd64? (
	truetype? ( >=app-emulation/emul-linux-x86-xlibs-2.1 )
	X? (
		>=app-emulation/emul-linux-x86-xlibs-2.1
		>=app-emulation/emul-linux-x86-soundlibs-2.1
	)
	openal? ( app-emulation/emul-linux-x86-sdl )
	opengl? ( app-emulation/emul-linux-x86-opengl )
	v4l? ( app-emulation/emul-linux-x86-medialibs )
	app-emulation/emul-linux-x86-baselibs
	>=sys-kernel/linux-headers-2.6
	)"
RDEPEND="truetype? ( >=media-libs/freetype-2.0.0 media-fonts/corefonts )
	perl? ( dev-lang/perl dev-perl/XML-Simple )
	capi? ( net-dialup/capi4k-utils )
	ncurses? ( >=sys-libs/ncurses-5.2 )
	fontconfig? ( media-libs/fontconfig )
	gphoto2? ( media-libs/libgphoto2 )
	openal? ( media-libs/openal )
	dbus? ( sys-apps/dbus )
	gnutls? ( net-libs/gnutls )
	gstreamer? ( media-libs/gstreamer media-libs/gst-plugins-base )
	X? (
		x11-libs/libXcursor
		x11-libs/libXrandr
		x11-libs/libXi
		x11-libs/libXmu
		x11-libs/libXxf86vm
		x11-apps/xmessage
	)
	xinerama? ( x11-libs/libXinerama )
	alsa? ( media-libs/alsa-lib )
	cups? ( net-print/cups )
	opencl? ( x11-drivers/nvidia-drivers >=dev-util/nvidia-cuda-toolkit-3.1 )
	opengl? ( virtual/opengl )
	gsm? ( media-sound/gsm )
	jpeg? ( virtual/jpeg )
	ldap? ( net-nds/openldap )
	lcms? ( =media-libs/lcms-1* )
	mp3? ( >=media-sound/mpg123-1.5.0 )
	nls? ( sys-devel/gettext )
	samba? ( >=net-fs/samba-3.0.25 )
	xml? ( dev-libs/libxml2 dev-libs/libxslt )
	scanner? ( media-gfx/sane-backends )
	ssl? ( dev-libs/openssl )
	png? ( media-libs/libpng )
	v4l? ( media-libs/libv4l )
	!win64? ( ${MLIB_DEPS} )
	win32? ( ${MLIB_DEPS} )
	xcomposite? ( x11-libs/libXcomposite )"
DEPEND="${RDEPEND}
	X? (
		x11-proto/inputproto
		x11-proto/xextproto
		x11-proto/xf86vidmodeproto
	)
	xinerama? ( x11-proto/xineramaproto )
	!hardened? ( prelink? ( sys-devel/prelink ) )
	virtual/yacc
	sys-devel/flex"

pkg_setup() {
	enewgroup wine

	if use win64 ; then
		[[ $(( $(gcc-major-version) * 100 + $(gcc-minor-version) )) -lt 404 ]] \
			&& die "you need gcc-4.4+ to build 64bit wine"
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.1.15-winegcc.patch #260726
	epatch_user #282735
	sed -i '/^UPDATE_DESKTOP_DATABASE/s:=.*:=true:' tools/Makefile.in || die
	sed -i '/^MimeType/d' tools/wine.desktop || die #117785
}

do_configure() {
	local builddir="${WORKDIR}/wine$1"
	mkdir -p "${builddir}"
	pushd "${builddir}" >/dev/null

	ECONF_SOURCE=${S} \
	econf \
		--sysconfdir=/etc/wine \
		$(use_with alsa) \
		$(use_with capi) \
		$(use_with lcms cms) \
		$(use_with cups) \
		$(use_with ncurses curses) \
		$(use_with fontconfig) \
		$(use_with gnutls) \
		$(use_with gphoto2 gphoto) \
		$(use_with gsm) \
		$(use_with gstreamer) \
		--without-hal \
		$(use_with jpeg) \
		$(use_with ldap) \
		$(use_with mp3 mpg123) \
		$(use_with nls gettext) \
		$(use_with openal) \
		$(use_with opencl) \
		$(use_with opengl) \
		$(use_with ssl openssl) \
		$(use_with oss) \
		$(use_with png) \
		$(use_with threads pthread) \
		$(use_with scanner sane) \
		$(use_enable test tests) \
		$(use_with truetype freetype) \
		$(use_with v4l) \
		$(use_with X x) \
		$(use_with xcomposite) \
		$(use_with xinerama) \
		$(use_with xml) \
		$(use_with xml xslt) \
		$2

	emake -j1 depend || die "depend"

	popd >/dev/null
}
src_configure() {
	export LDCONFIG=/bin/true
	use custom-cflags || strip-flags

	if use win64 ; then
		do_configure 64 --enable-win64
		use win32 && ABI=x86 do_configure 32 --with-wine64=../wine64
	else
		ABI=x86 do_configure 32 --disable-win64
	fi
}

src_compile() {
	local b
	for b in 64 32 ; do
		local builddir="${WORKDIR}/wine${b}"
		[[ -d ${builddir} ]] || continue
		emake -C "${builddir}" all || die
	done
}

src_install() {
	local b
	for b in 64 32 ; do
		local builddir="${WORKDIR}/wine${b}"
		[[ -d ${builddir} ]] || continue
		emake -C "${builddir}" install DESTDIR="${D}" || die
	done
	dodoc ANNOUNCE AUTHORS README
	if use gecko ; then
		insinto /usr/share/wine/gecko
		doins "${DISTDIR}"/wine_gecko-${GV}-x86.msi || die
		use win64 && { doins "${DISTDIR}"/wine_gecko-${GV}-x86_64.msi || die ; }
	fi
	if ! use perl ; then
		rm "${D}"/usr/bin/{wine{dump,maker},function_grep.pl} "${D}"/usr/share/man/man1/wine{dump,maker}.1 || die
	fi

	# for all bins and libs disable world access and group write access
	# only users from wine group may be able to use it
	local filelist=$( find "${D}"/usr/{bin,lib} -type f | gawk -v path="${D}" '{ gsub("^"path,""); print $0 }')
	fowners :wine ${filelist} || die "chown failed"
	fperms -R o-rwx,g-w ${filelist} || die "chmod failed"
}

pkg_postinst() {
	paxctl -psmr "${ROOT}"/usr/bin/wine{,-preloader} 2>/dev/null #255055

	ewarn "You must be in the wine group in order to be able to use wine."
	ewarn "It is recommended to use a separate user for running wine in order"
	ewarn "to improve security by isolation. See Risks section in the wine FAQ:"
	ewarn "http://wiki.winehq.org/FAQ#head-3cb8f054b33a63be30f98a1b6225d74e305a0459"
}
# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

EGIT_REPO_URI="git://git.videolan.org/ffmpeg.git"
ESVN_REPO_URI="svn://svn.mplayerhq.hu/mplayer/trunk"

inherit flag-o-matic git-r3 multilib subversion toolchain-funcs ${SVN_ECLASS}

IUSE="cpu_flags_x86_3dnow cpu_flags_x86_3dnowext +a52 aalib +alsa altivec amr aqua bidi bindist bl bluray
bs2b cddb +cdio cdparanoia cpudetection debug dga +dirac
doc +dts +dv dvb +dvd +dvdnav dxr3 +enca +encode -external-ffmpeg faac +faad fbcon
ftp gif ggi gsm +iconv ipv6 jack joystick jpeg jpeg2k kernel_linux ladspa
+libass libcaca libmpeg2 lirc +live lzo mad md5sum +cpu_flags_x86_mmx cpu_flags_x86_mmxext mng +mp3 mpg123 nas nemesi
+network openal +opengl opus +osdmenu oss png pnm pulseaudio pvr +quicktime
radio +rar +real +rtc rtmp samba +shm sdl +speex cpu_flags_x86_sse cpu_flags_x86_sse2 cpu_flags_x86_ssse3 svga svga-helper
tga +theora tivo +tremor +truetype toolame +twolame +unicode v4l vdpau vidix
+vorbis vpx win32codecs +X +x264 xinerama +xscreensaver +xv +xvid xvmc yuv4mpeg zoran"

VIDEO_CARDS="s3virge mga tdfx vesa"
for x in ${VIDEO_CARDS}; do
	IUSE+=" video_cards_${x}"
done

FONT_URI="
	mirror://mplayer/releases/fonts/font-arial-iso-8859-1.tar.bz2
	mirror://mplayer/releases/fonts/font-arial-iso-8859-2.tar.bz2
	mirror://mplayer/releases/fonts/font-arial-cp1250.tar.bz2
"
SRC_URI="!truetype? ( ${FONT_URI} )"

DESCRIPTION="Media Player for Linux"
HOMEPAGE="http://www.mplayerhq.hu/"

FONT_RDEPS="
	virtual/ttf-fonts
	media-libs/fontconfig
	>=media-libs/freetype-2.2.1:2
"
X_RDEPS="
	x11-libs/libXext
	x11-libs/libXxf86vm
"
# Rar: althrought -gpl version is nice, it cant do most functions normal rars can
#	nemesi? ( net-libs/libnemesi )
RDEPEND+="
	sys-libs/ncurses:0=
	app-arch/bzip2
	sys-libs/zlib
	a52? ( media-libs/a52dec )
	aalib? ( media-libs/aalib )
	alsa? ( media-libs/alsa-lib )
	amr? ( media-libs/opencore-amr )
	libass? ( ${FONT_RDEPS} >=media-libs/libass-0.9.10[enca(+)?] )
	bidi? ( dev-libs/fribidi )
	bluray? ( >=media-libs/libbluray-0.2.1 )
	bs2b? ( media-libs/libbs2b )
	cdio? ( dev-libs/libcdio )
	cdparanoia? ( !cdio? ( media-sound/cdparanoia ) )
	dga? ( x11-libs/libXxf86dga )
	dirac? ( media-video/dirac )
	dts? ( media-libs/libdca )
	dv? ( media-libs/libdv )
	dvd? ( >=media-libs/libdvdread-4.1.3 )
	dvdnav? ( >=media-libs/libdvdnav-4.1.3 )
	encode? (
		toolame? ( media-sound/toolame )
		twolame? ( media-sound/twolame )
		faac? ( media-libs/faac )
		mp3? ( media-sound/lame )
		x264? ( >=media-libs/x264-0.0.20100423 )
		xvid? ( media-libs/xvid )
	)
	enca? ( app-i18n/enca )
	external-ffmpeg? ( >=media-video/ffmpeg-0.11.1 )
	faad? ( media-libs/faad2 )
	ggi? ( media-libs/libggi media-libs/libggiwmh )
	gif? ( media-libs/giflib )
	gsm? ( media-sound/gsm )
	iconv? ( virtual/libiconv )
	jack? ( media-sound/jack-audio-connection-kit )
	jpeg? ( virtual/jpeg:0= )
	jpeg2k? ( media-libs/openjpeg:= )
	ladspa? ( media-libs/ladspa-sdk )
	libcaca? ( media-libs/libcaca )
	libmpeg2? ( media-libs/libmpeg2 )
	lirc? ( app-misc/lirc )
	live? ( media-plugins/live )
	lzo? ( >=dev-libs/lzo-2 )
	mad? ( media-libs/libmad )
	mng? ( media-libs/libmng )
	mpg123? ( media-sound/mpg123 )
	nas? ( media-libs/nas )
	nemesi? ( net-libs/libnemesi )
	openal? ( media-libs/openal )
	opengl? ( virtual/opengl )
	opus? ( media-libs/opus )
	png? ( media-libs/libpng:0= )
	pnm? ( media-libs/netpbm )
	pulseaudio? ( media-sound/pulseaudio )
	rar? (
		|| (
			app-arch/unrar
			app-arch/rar
		)
	)
	rtmp? ( media-video/rtmpdump )
	samba? ( net-fs/samba )
	sdl? ( media-libs/libsdl )
	speex? ( media-libs/speex )
	svga? (
		svga-helper? ( media-libs/svgalib[kernel-helper] )
		!svga-helper? ( media-libs/svgalib )
	)
	theora? ( media-libs/libtheora[encode?] )
	tivo? ( media-libs/vstream-client )
	truetype? ( ${FONT_RDEPS} )
	vdpau? ( x11-libs/libvdpau )
	video_cards_vesa? ( sys-libs/libvbe )
	vorbis? ( media-libs/libvorbis )
	vpx? ( media-libs/libvpx )
	X? ( ${X_RDEPS} )
	x86? ( win32codecs? ( media-libs/win32codecs ) )
	xinerama? ( x11-libs/libXinerama )
	xscreensaver? ( x11-libs/libXScrnSaver )
	xv? ( x11-libs/libXv )
	xvmc? ( x11-libs/libXvMC )
"

ASM_DEP="dev-lang/yasm"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	dga? ( x11-base/xorg-proto )
	dvb? ( virtual/linuxtv-dvb-headers )
	X? ( x11-base/xorg-proto )
	xinerama? ( x11-base/xorg-proto )
	xscreensaver? ( x11-base/xorg-proto )
	amd64? ( ${ASM_DEP} )
	doc? (
		dev-libs/libxslt app-text/docbook-xml-dtd
		app-text/docbook-xsl-stylesheets
	)
	x86? ( ${ASM_DEP} )
"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS=""

# bindist does not cope with amr codecs (#299405#c6), faac codecs are nonfree, win32codecs are nonfree
# libcdio support: prefer libcdio over cdparanoia and don't check for cddb w/cdio
# dvd navigation requires dvd read support
# ass and freetype font require iconv and ass requires freetype fonts
# unicode transformations are usefull only with iconv
# libvorbis require external tremor to work
# radio requires oss or alsa backend
# xvmc requires xvideo support
REQUIRED_USE="bindist? ( !amr !faac !win32codecs )
	cdio? ( !cdparanoia )
	dvdnav? ( dvd )
	libass? ( truetype )
	toolame? ( !twolame )
	twolame? ( !toolame )
	truetype? ( iconv )
	unicode? ( iconv )
	vorbis? ( tremor )
	radio? ( || ( alsa oss ) )
	xvmc? ( xv )"
# encoder codecs needs encoder support enabled
uses="faac x264 xvid toolame twolame"
for x in ${uses}; do
	REQUIRED_USE+="
		${x}? ( encode )
	"
done
# xorg options require X useflag enabled
uses="dga dxr3 ggi vdpau vidix xinerama xscreensaver xv"
for x in ${uses}; do
	REQUIRED_USE+="
		${x}? ( X )
	"
done
uses="opengl osdmenu"
for x in ${uses}; do
	REQUIRED_USE+="
		${x}? ( || ( X aqua ) )
	"
done
unset uses

pkg_setup() {
	elog
	elog "This is a live ebuild which installs the latest from upstream's"
	elog "subversion repository, and is unsupported by Gentoo."
	elog "Everything but bugs in the ebuild itself will be ignored."
	elog

	if use cpudetection; then
		ewarn
		ewarn "You've enabled the cpudetection flag. This feature is"
		ewarn "included mainly for people who want to use the same"
		ewarn "binary on another system with a different CPU architecture."
		ewarn "MPlayer will already detect your CPU settings by default at"
		ewarn "buildtime; this flag is used for runtime detection."
		ewarn "You won't need this turned on if you are only building"
		ewarn "mplayer for this system. Also, if your compile fails, try"
		ewarn "disabling this use flag."
	fi
}

src_unpack() {
	subversion_src_unpack
	cd "${WORKDIR}"
	rm -rf "${WORKDIR}/${P}/ffmpeg/"
	( EGIT_CHECKOUT_DIR="${WORKDIR}/${P}/ffmpeg/" git-r3_src_unpack )

	if ! use truetype; then
		unpack font-arial-iso-8859-1.tar.bz2 \
			font-arial-iso-8859-2.tar.bz2 \
			font-arial-cp1250.tar.bz2
	fi
}

src_prepare() {
	# Set SVN version manually
	subversion_wc_info
	sed -i -e "s/UNKNOWN/${ESVN_WC_REVISION}/" "${S}/version.sh" || die

	# fix path to bash executable in configure scripts
	sed -i -e "1c\#!${EPREFIX}/bin/bash" configure version.sh || die

	base_src_prepare

	# change libvbe header location according to Gentoo's libvbe
	eapply "${FILESDIR}/${PN}-vesa.patch"

	eapply_user
}

src_configure() {
	local myconf=""
	local uses i

	# set LINGUAS
	[[ -n $LINGUAS ]] && LINGUAS="${LINGUAS/da/dk}"

	# mplayer ebuild uses "use foo || --disable-foo" to forcibly disable
	# compilation in almost every situation. The reason for this is
	# because if --enable is used, it will force the build of that option,
	# regardless of whether the dependency is available or not.

	###################
	#Optional features#
	###################
	# disable svga since we don't want it
	# disable arts since we don't have kde3
	# always disable internal ass
	myconf+="
		--disable-ass-internal
		--disable-arts
		--disable-kai
		$(use_enable network networking)
		$(use_enable joystick)
	"
	uses="bl bluray enca ftp nemesi rtc svga"
	for i in ${uses}; do
		use ${i} || myconf+=" --disable-${i}"
	done
	use libass || myconf+=" --disable-ass"
	use bidi || myconf+=" --disable-fribidi"
	use ipv6 || myconf+=" --disable-inet6"
	use rar || myconf+=" --disable-unrarexec"
	use samba || myconf+=" --disable-smb"
	use svga && use svga-helper && myconf+=" --enable-svgalib_helper"
	use tivo || myconf="${myconf} --disable-vstream"
	use lirc || myconf+=" --disable-lirc --disable-lircc --disable-apple-ir"

	use cdio && myconf+=" --disable-cdparanoia"
	use cdio || myconf+=" --disable-libcdio"
	use cdparanoia || myconf+=" --disable-cdparanoia"
	use cddb || myconf+=" --disable-cddb"

	################################
	# DVD read, navigation support #
	################################
	#
	# dvdread - accessing a DVD
	# dvdnav - navigation of menus
	#
	# use libdvdcss, dvdread and dvdnav
	use dvd || myconf+=" --disable-dvdread"
	use dvdnav || myconf+=" --disable-dvdnav"

	#############
	# Subtitles #
	#############
	#
	# SRT/ASS/SSA (subtitles) requires freetype support
	# freetype support requires iconv
	# iconv optionally can use unicode
	use truetype || myconf+=" --disable-freetype"
	use iconv || myconf+=" --disable-iconv --charset=noconv"
	use iconv && use unicode && myconf+=" --charset=UTF-8"

	#####################################
	# DVB / Video4Linux / Radio support #
	#####################################
	myconf+=" --disable-tv-bsdbt848"
	# broken upstream, won't work with recent kernels
	myconf+=" --disable-tv-v4l1"
	if { use dvb || use v4l || use pvr || use radio; }; then
		use dvb || myconf+=" --disable-dvb"
		use pvr || myconf+=" --disable-pvr"
		use v4l || myconf+=" --disable-tv-v4l2"
		if use radio && { use dvb || use v4l; }; then
			myconf+="
				--enable-radio
				$(use_enable encode radio-capture)
			"
		else
			myconf+="
				--disable-radio-v4l2
				--disable-radio-bsdbt848
			"
		fi
	else
		myconf+="
			--disable-tv
			--disable-tv-v4l2
			--disable-radio
			--disable-radio-v4l2
			--disable-radio-bsdbt848
			--disable-dvb
			--disable-v4l2
			--disable-pvr"
	fi

	##########
	# Codecs #
	##########
	myconf+=" --disable-musepack" # Use internal musepack codecs for SV7 and SV8 support
	myconf+=" --disable-libmpeg2-internal" # always use system media-libs/libmpeg2
	use dirac || myconf+=" --disable-libdirac-lavc"
	use dts || myconf+=" --disable-libdca"
	if ! use mp3; then
		myconf+="
			--disable-mp3lame
			--disable-mp3lame-lavc
			--disable-mp3lib
		"
	fi
	uses="a52 bs2b dv gsm lzo opus rtmp"
	for i in ${uses}; do
		use ${i} || myconf+=" --disable-lib${i}"
	done
	use amr || myconf+=" --disable-libopencore_amrnb --disable-libopencore_amrwb"

	uses="faad gif jpeg libmpeg2 live mad mng mpg123 png pnm speex tga theora"
	for i in ${uses}; do
		use ${i} || myconf+=" --disable-${i}"
	done
	use jpeg2k || myconf+=" --disable-libopenjpeg"
	# use tremor && myconf+=" --disable-tremor-internal"
	use tremor || myconf+=" --disable-tremor-internal --disable-tremor"
	use vorbis || myconf+=" --disable-libvorbis"
	use vpx || myconf+=" --disable-libvpx-lavc"
	# Encoding
	uses="faac x264 xvid toolame twolame"
	if use encode; then
		for i in ${uses}; do
			use ${i} || myconf+=" --disable-${i}"
		done
	else
		myconf+=" --disable-mencoder"
		for i in ${uses}; do
			myconf+=" --disable-${i}"
			use ${i} && elog "Useflag \"${i}\" will only be useful for encoding, i.e., with \"encode\" useflag enabled."
		done
	fi
	use faac || myconf+=" --disable-faac-lavc"

	#################
	# Binary codecs #
	#################
	# bug 213836
	if ! use x86 || ! use win32codecs; then
		use quicktime || myconf+=" --disable-qtx"
	fi

	######################
	# RealPlayer support #
	######################
	# Realplayer support shows up in four places:
	# - libavcodec (internal)
	# - win32codecs
	# - realcodecs (win32codecs libs)
	# - realcodecs (realplayer libs)

	# internal
	use real || myconf+=" --disable-real"

	myconf+=" $(use_enable win32codecs win32dll)"

	################
	# Video Output #
	################
	uses="md5sum sdl yuv4mpeg"
	for i in ${uses}; do
		use ${i} || myconf+=" --disable-${i}"
	done
	use aalib || myconf+=" --disable-aa"
	use fbcon || myconf+=" --disable-fbdev"
	use fbcon && use video_cards_s3virge && myconf+=" --enable-s3fb"
	use libcaca || myconf+=" --disable-caca"
	use zoran || myconf+=" --disable-zr"

	if ! use kernel_linux || ! use video_cards_mga; then
		 myconf+=" --disable-mga --disable-xmga"
	fi

	if use video_cards_tdfx; then
		myconf+="
			$(use_enable video_cards_tdfx tdfxvid)
			$(use_enable fbcon tdfxfb)
		"
	else
		myconf+="
			--disable-3dfx
			--disable-tdfxvid
			--disable-tdfxfb
		"
	fi

	# sun card, disable by default, see bug #258729
	myconf+=" --disable-xvr100"

	################
	# Audio Output #
	################
	# esound is outdated and removed from portage
	myconf+=" --disable-esd"
	uses="alsa jack ladspa nas openal"
	for i in ${uses}; do
		use ${i} || myconf+=" --disable-${i}"
	done
	use pulseaudio || myconf+=" --disable-pulse"
	use oss || myconf+=" --disable-ossaudio"

	####################
	# Advanced Options #
	####################
	# Platform specific flags, hardcoded on amd64 (see below)
	use cpudetection && myconf+=" --enable-runtime-cpudetection"

	uses="3dnow 3dnowext mmx mmxext sse sse2 ssse3"
	for i in ${uses}; do
		myconf+=" $(use_enable cpu_flags_x86_${i} ${i})"
	done
	uses="altivec shm"
	for i in ${uses}; do
		myconf+=" $(use_enable ${i})"
	done

	use debug && myconf+=" --enable-debug=3"

	if use x86 && gcc-specs-pie; then
		filter-flags -fPIC -fPIE
		append-ldflags -nopie
	fi

	# workaround bug, x86 just has too few registers, see c.f.
	# http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=402950#44
	# and 32-bits OSX, bug 329861
	if [[ ${CHOST} == i?86-* ]] ; then
		use debug || append-flags -fomit-frame-pointer
	fi

	###########################
	# X enabled configuration #
	###########################
	myconf+=" --disable-gui"
	uses="dxr3 ggi vdpau vidix xinerama xv"
	for i in ${uses}; do
		use ${i} || myconf+=" --disable-${i}"
	done
	use dga || myconf+=" --disable-dga1 --disable-dga2"
	use opengl || myconf+=" --disable-gl"
	use osdmenu && myconf+=" --enable-menu"
	use video_cards_vesa || myconf+=" --disable-vesa"
	use vidix || myconf+=" --disable-vidix-pcidb"
	use X || myconf+=" --disable-x11"
	use xscreensaver || myconf+=" --disable-xss"
	use xvmc && myconf+=" --enable-xvmc --with-xvmclib=XvMCW"

	############################
	# OSX (aqua) configuration #
	############################
	if use aqua; then
		myconf+="
			--enable-macosx-finder
			--enable-macosx-bundle
		"
	fi

	###################
	# External FFmpeg #
	###################
	use external-ffmpeg && myconf+=" --disable-ffmpeg_a"

	tc-export PKG_CONFIG
	./configure \
		--cc="$(tc-getCC)" \
		--host-cc="$(tc-getBUILD_CC)" \
		--prefix="${EPREFIX}/usr" \
		--bindir="${EPREFIX}/usr/bin" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--confdir="${EPREFIX}/etc/mplayer" \
		--datadir="${EPREFIX}/usr/share/mplayer${namesuf}" \
		--mandir="${EPREFIX}/usr/share/man" \
		${myconf} || die "configure died"
}

src_compile() {
	base_src_compile
	# Build only user-requested docs if they're available.
	if use doc ; then
		# select available languages from $LINGUAS
		LINGUAS=${LINGUAS/zh/zh_CN}
		local ALLOWED_LINGUAS="cs de en es fr hu it pl ru zh_CN"
		local BUILT_DOCS=""
		for i in ${LINGUAS} ; do
			has ${i} ${ALLOWED_LINGUAS} && BUILT_DOCS+=" ${i}"
		done
		if [[ -z $BUILT_DOCS ]]; then
			emake -j1 html-chunked
		else
			for i in ${BUILT_DOCS}; do
				emake -j1 html-chunked-${i}
			done
		fi
	fi
}

src_install() {
	local i

	emake \
		DESTDIR="${D}" \
		INSTALLSTRIP="" \
		install

	dodoc AUTHORS Changelog Copyright README etc/codecs.conf

	docinto tech/
	dodoc DOCS/tech/{*.txt,MAINTAINERS,mpsub.sub,playtree,TODO,wishlist}
	docinto TOOLS/
	dodoc -r TOOLS/*
	if use real; then
		docinto tech/realcodecs/
		dodoc DOCS/tech/realcodecs/*
	else
		rm -rf "${ED}/usr/share/doc/${P}/TOOLS/realcodecs"
	fi
	docinto tech/mirrors/
	dodoc DOCS/tech/mirrors/*

	if use doc; then
		docinto html/
		dohtml -r "${S}"/DOCS/HTML/*
	fi

	if ! use truetype; then
		dodir /usr/share/mplayer/fonts
		# Do this generic, as the mplayer people like to change the structure
		# of their zips ...
		for i in $(find "${WORKDIR}/" -type d -name 'font-arial-*'); do
			cp -pPR "${i}" "${ED}/usr/share/mplayer/fonts"
		done
		# Fix the font symlink ...
		rm -rf "${ED}/usr/share/mplayer/font"
		dosym fonts/font-arial-14-iso-8859-1 /usr/share/mplayer/font
	fi

	insinto /etc/mplayer
	newins "${S}/etc/example.conf" mplayer.conf
	cat >> "${ED}/etc/mplayer/mplayer.conf" << _EOF_
# Config options can be section specific, global
# options should go in the default section
[default]
_EOF_
	doins "${S}/etc/input.conf"
	if use osdmenu; then
		doins "${S}/etc/menu.conf"
	fi

	if use truetype; then
		cat >> "${ED}/etc/mplayer/mplayer.conf" << _EOF_
fontconfig=1
subfont-osd-scale=4
subfont-text-scale=3
_EOF_
	fi

	# bug 256203
	if use rar; then
		cat >> "${ED}/etc/mplayer/mplayer.conf" << _EOF_
unrarexec=${EPREFIX}/usr/bin/unrar
_EOF_
	fi

	dosym ../../../etc/mplayer/mplayer.conf /usr/share/mplayer/mplayer.conf
	newbin "${S}/TOOLS/midentify.sh" midentify
}

pkg_preinst() {
	[[ -d ${EROOT}/usr/share/mplayer/Skin/default ]] && \
		rm -rf "${EROOT}/usr/share/mplayer/Skin/default"
}

pkg_postrm() {
	# Cleanup stale symlinks
	[ -L "${EROOT}/usr/share/mplayer/font" -a \
			! -e "${EROOT}/usr/share/mplayer/font" ] && \
		rm -f "${EROOT}/usr/share/mplayer/font"

	[ -L "${EROOT}/usr/share/mplayer/subfont.ttf" -a \
			! -e "${EROOT}/usr/share/mplayer/subfont.ttf" ] && \
		rm -f "${EROOT}/usr/share/mplayer/subfont.ttf"
}

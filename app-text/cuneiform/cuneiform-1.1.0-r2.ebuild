# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils versionator

PV_MAJ=$(get_version_component_range 1-2)
MY_P=${PN}-linux-${PV}

DESCRIPTION="An enterprise quality OCR engine by Cognitive Technologies"
HOMEPAGE="https://launchpad.net/cuneiform-linux"
SRC_URI="https://launchpad.net/${PN}-linux/${PV_MAJ}/${PV_MAJ}/+download/${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="debug graphicsmagick"

RDEPEND="
	!graphicsmagick? ( media-gfx/imagemagick:= )
	graphicsmagick? ( media-gfx/graphicsmagick:= )"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}

DOCS=( readme.txt )
PATCHES=(
	"${FILESDIR}/c-assert.diff"
	"${FILESDIR}/libm.diff"
	"${FILESDIR}/abs-types_cast.patch"
	"${FILESDIR}/charset-signedness.patch"
	"${FILESDIR}/minmax.patch"
)

src_prepare(){
	if use graphicsmagick; then
		PATCHES+=( "${FILESDIR}/graphicsmagick.diff" )
	else
		sed -e 's/GraphicsMagick/ImageMagick/g' \
			-e 's/fBgm/fBImageMagick/g' \
		"${FILESDIR}/${PN}.1" > "${PN}.1" || die
	fi
	cmake-utils_src_prepare

	# respect LDFLAGS
	sed -i 's:\(set[(]CMAKE_SHARED_LINKER_FLAGS "[^"]*\):\1 $ENV{LDFLAGS}:' \
		cuneiform_src/CMakeLists.txt || die "failed to sed for LDFLAGS"

	# Fix automagic dependencies / linking
	if use graphicsmagick; then
		sed -i "s:find_package(ImageMagick COMPONENTS Magick++):#DONOTFIND:" \
			cuneiform_src/CMakeLists.txt \
			|| die "Sed for ImageMagick automagic dependency failed."
	fi
}

src_install() {
	cmake-utils_src_install
	doman "${PN}.1"
}

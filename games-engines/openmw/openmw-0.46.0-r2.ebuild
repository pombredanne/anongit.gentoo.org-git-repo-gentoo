# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake flag-o-matic xdg-utils readme.gentoo-r1

DESCRIPTION="Open source reimplementation of TES III: Morrowind"
HOMEPAGE="https://openmw.org/ https://gitlab.com/OpenMW/openmw"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/OpenMW/openmw.git"
else
	SRC_URI="
		https://github.com/OpenMW/openmw/archive/${P}.tar.gz
		https://gitlab.com/OpenMW/openmw/-/merge_requests/163.patch -> ${P}-floattest.patch
	"
	KEYWORDS="~amd64 ~x86"
	S="${WORKDIR}/${PN}-${P}"
fi

LICENSE="GPL-3 MIT BitstreamVera ZLIB"
SLOT="0"
IUSE="doc devtools +osg-fork test +qt5"
RESTRICT="!test? ( test )"

# FIXME: Unbundle dev-games/openscenegraph-qt in extern/osgQt directory,
# used when BUILD_OPENCS flag is enabled. See bug #676266.

RDEPEND="
	dev-games/mygui
	dev-games/recastnavigation
	dev-libs/boost:=[threads(+),zlib]
	dev-libs/tinyxml:=[stl]
	media-libs/libsdl2[joystick,opengl,video]
	media-libs/openal
	media-video/ffmpeg:=
	>=sci-physics/bullet-2.86:=[-double-precision]
	virtual/opengl
	osg-fork? ( =dev-games/openscenegraph-openmw-3.4*:=[ffmpeg,jpeg,png,sdl,svg,truetype,zlib] )
	!osg-fork? ( >=dev-games/openscenegraph-3.5.5:=[ffmpeg,jpeg,png,sdl,svg,truetype,zlib] )
	qt5? (
		app-arch/unshield
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtopengl:5
		dev-qt/qtwidgets:5
	)
"

DEPEND="${RDEPEND}"

BDEPEND="
	virtual/pkgconfig
	doc? (
		app-doc/doxygen[doc]
		dev-python/sphinx
	)
	test? (
		dev-cpp/gtest
	)
"

PATCHES=(
	"${FILESDIR}"/openmw-0.46.0-mygui-license.patch
	"${FILESDIR}"/openmw-0.46.0-recastnavigation.patch
	"${FILESDIR}"/openmw-0.46.0-missing-include.patch
	"${FILESDIR}"/openmw-0.46.0-fix-cast.patch
	"${FILESDIR}"/openmw-0.46.0-nifbullet-test.patch
	# https://gitlab.com/OpenMW/openmw/-/merge_requests/163
	"${DISTDIR}"/openmw-0.46.0-floattest.patch
	"${FILESDIR}"/openmw-0.46.0-floattest2.patch
	"${FILESDIR}"/openmw-0.46.0-gcc11.patch
	"${FILESDIR}"/openmw-0.46.0-boost-1.77.patch
)

src_prepare() {
	cmake_src_prepare

	# Use the system tinyxml headers
	rm -v extern/oics/tiny{str,xml}* || die

	# Unbundle recastnavigation
	rm -vr extern/recastnavigation || die
	sed -i "s#GENTOO_RECAST_LIBDIR#${EPREFIX}/usr/$(get_libdir)#" CMakeLists.txt || die
}

src_configure() {
	use devtools && ! use qt5 && \
		elog "'qt5' USE flag is disabled, 'openmw-cs' will not be installed"

	append-cxxflags "-I${EPREFIX}/usr/include/recastnavigation"

	local mycmakeargs=(
		-DBUILD_BSATOOL=$(usex devtools)
		-DBUILD_DOCS=$(usex doc)
		-DBUILD_ESMTOOL=$(usex devtools)
		-DBUILD_LAUNCHER=$(usex qt5)
		-DBUILD_NIFTEST=$(usex devtools)
		-DBUILD_OPENCS=$(usex devtools $(usex qt5))
		-DBUILD_WIZARD=$(usex qt5)
		-DBUILD_UNITTESTS=$(usex test)
		-DGLOBAL_DATA_PATH="${EPREFIX}/usr/share"
		-DICONDIR="${EPREFIX}/usr/share/icons/hicolor/256x256/apps"
		-DMORROWIND_DATA_FILES="${EPREFIX}/usr/share/morrowind-data"
		-DUSE_SYSTEM_TINYXML=ON
		-DDESIRED_QT_VERSION=5
	)

	cmake_src_configure
}

src_compile() {
	cmake_src_compile

	if use doc ; then
		cmake_src_compile doc
		find "${CMAKE_BUILD_DIR}"/docs/Doxygen/html \
			-name '*.md5' -type f -delete || die
		HTML_DOCS=( "${CMAKE_BUILD_DIR}"/docs/Doxygen/html/. )
	fi
}

src_test() {
	"${BUILD_DIR}/openmw_test_suite" || die
}

src_install() {
	cmake_src_install

	local DOC_CONTENTS="
	You need the original Morrowind data files. If you haven't
	installed them yet, you can install them straight via the
	installation wizard which is the officially supported method
	(either by using the launcher or by calling 'openmw-wizard'
	directly).\n"

	if ! use qt5; then
		local DOC_CONTENTS+="\n\n
		USE flag 'qt5' is disabled, 'openmw-launcher' and
		'openmw-wizard' are not available. You are on your own for
		making the Morrowind data files available and pointing
		openmw at them.\n\n
		Additionally; you must import the Morrowind.ini file before
		running openmw with the Morrowind data files for the first
		time. Typically this can be done like so:\n\n
		\t mkdir -p ~/.config/openmw\n
		\t openmw-iniimporter /path/to/Morrowind.ini ~/.config/openmw/openmw.cfg"
	fi

	readme.gentoo_create_doc
}

pkg_postinst() {
	xdg_icon_cache_update
	readme.gentoo_print_elog
}

pkg_postrm() {
	xdg_icon_cache_update
}

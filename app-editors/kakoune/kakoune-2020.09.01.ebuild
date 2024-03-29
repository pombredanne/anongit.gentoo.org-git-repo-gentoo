# Copyright 2020-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Modal editor inspired by vim"
HOMEPAGE="http://kakoune.org/ https://github.com/mawww/kakoune"
SRC_URI="https://github.com/mawww/kakoune/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Unlicense"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~x86"

DEPEND="sys-libs/ncurses:=[unicode(+)]"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${PN}-2020.09.01-enable-ebuild-syntax-highlight.patch
	"${FILESDIR}"/${PN}-2020.09.01-gcc-11.patch
)

src_prepare() {
	sed -i '/CXXFLAGS += -O3/d' src/Makefile || die
	default
}

src_configure() {
	tc-export CXX
}

src_compile() {
	emake -C src all
}

src_test() {
	emake -C src test
}

src_install() {
	emake PREFIX="${D}"/usr docdir="${ED}/usr/share/doc/${PF}" install

	rm "${ED}/usr/share/man/man1/kak.1.gz" || die
	doman doc/kak.1
}

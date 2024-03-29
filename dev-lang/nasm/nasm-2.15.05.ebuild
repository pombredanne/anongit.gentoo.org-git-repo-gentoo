# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="groovy little assembler"
HOMEPAGE="https://www.nasm.us/"
SRC_URI="https://www.nasm.us/pub/nasm/releasebuilds/${PV/_}/${P/_}.tar.xz"
S="${WORKDIR}"/${P/_}

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~ia64 ~ppc64 x86 ~amd64-linux ~x86-linux"
IUSE="doc"

# [fonts note] doc/psfonts.ph defines ordered list of font preference.
# Currently 'media-fonts/source-pro' is most preferred and is able to
# satisfy all 6 font flavours: tilt, chapter, head, etc.
BDEPEND="
	dev-lang/perl
	doc? (
		app-text/ghostscript-gpl
		dev-perl/Font-TTF
		dev-perl/Sort-Versions
		media-fonts/source-pro
		virtual/perl-File-Spec
	)
"

PATCHES=(
	"${FILESDIR}"/${PN}-2.15-bsd-cp-doc.patch
)

src_compile() {
	default
	use doc && emake doc
}

src_install() {
	default
	emake DESTDIR="${ED}" install_rdf $(usex doc install_doc '')
}

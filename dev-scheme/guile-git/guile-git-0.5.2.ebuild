# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# I extract those manually from https://gitlab.com/guile-git/guile-git/-/releases
# from 'source tarball' link. Is there a better stable link?
UPLOAD_PV=0.5.2
UPLOAD_ID=6450f3991aa524484038cdcea3fb248d

[[ $PV == ${UPLOAD_PV} ]] || die "${CATEGORY}/${P}: update 'UPLOAD_ID' to match ${PV}"

DESCRIPTION="Guile bindings of git"
HOMEPAGE="https://gitlab.com/guile-git/guile-git"
SRC_URI="https://gitlab.com/guile-git/guile-git/uploads/${UPLOAD_ID}/guile-git-${PV}.tar.gz"

LICENSE="LGPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

# Works without sandbox. But under sandbox sshd claims to break the protocol.
RESTRICT=test

# older libgit seems to be incompatible with guile-git bindings
# https://github.com/trofi/nix-guix-gentoo/issues/7
RDEPEND="
	>=dev-scheme/guile-2.0.11:=
	dev-scheme/bytestructures
	>=dev-libs/libgit2-1:=
"
DEPEND="${RDEPEND}"

# guile generates ELF files without use of C or machine code
# It's a portage's false positive. bug #677600
QA_FLAGS_IGNORED='.*[.]go'

src_prepare() {
	default

	# guile is trying to avoid recompilation by checking if file
	#     /usr/lib64/guile/2.2/site-ccache/<foo>
	# is newer than
	#     <foo>
	# In case it is instead of using <foo> guile
	# loads system one (from potentially older version of package).
	# To work it around we bump last modification timestamp of
	# '*.scm' files.
	# http://debbugs.gnu.org/cgi/bugreport.cgi?bug=38112
	find "${S}" -name "*.scm" -exec touch {} + || die
}

src_test() {
	emake check VERBOSE=1
}

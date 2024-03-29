# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..10} )
inherit distutils-r1

DESCRIPTION="A high-performance immutable mapping type for Python"
HOMEPAGE="https://github.com/MagicStack/immutables"
SRC_URI="https://github.com/MagicStack/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~sparc ~x86"

PATCHES=(
	# https://github.com/MagicStack/immutables/commit/fa355239e70411179c70b16ed4ff7113d8008dad
	"${FILESDIR}"/${P}-32bit-hash.patch
)

distutils_enable_tests pytest

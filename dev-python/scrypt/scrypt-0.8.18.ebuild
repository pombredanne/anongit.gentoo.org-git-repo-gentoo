# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7..10} pypy3 )

inherit distutils-r1

DESCRIPTION="Bindings for the scrypt key derivation function library"
HOMEPAGE="https://github.com/holgern/py-scrypt/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD-2"
# no functional changes since 0.8.16, so no point in upgrading
KEYWORDS="~m68k"
SLOT="0"

RDEPEND="dev-libs/openssl:0="
DEPEND="${RDEPEND}"

distutils_enable_tests unittest

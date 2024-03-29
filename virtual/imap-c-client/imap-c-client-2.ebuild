# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Virtual for IMAP c-client"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~mips ppc ppc64 ~s390 sparc x86"
IUSE="kerberos ssl"

RDEPEND="net-libs/c-client[kerberos=,ssl=]"

# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

USE_RUBY="ruby25 ruby26 ruby27 ruby30"

RUBY_FAKEGEM_EXTRADOC="CHANGELOG.md README.md ROADMAP.md SECURITY.md"

RUBY_FAKEGEM_EXTRAINSTALL="ext"

RUBY_FAKEGEM_GEMSPEC="nokogiri.gemspec"

RUBY_FAKEGEM_EXTENSIONS=(ext/nokogiri/extconf.rb)

inherit ruby-fakegem multilib

DESCRIPTION="Nokogiri is an HTML, XML, SAX, and Reader parser"
HOMEPAGE="https://www.nokogiri.org/"
LICENSE="MIT"
SRC_URI="https://github.com/sparklemotion/nokogiri/archive/v${PV}.tar.gz -> ${P}-git.tgz"

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
SLOT="0"
IUSE=""

RDEPEND="${RDEPEND}
	>=dev-libs/libxml2-2.9.12:=
	>=dev-libs/libxslt-1.1.34
	sys-libs/zlib
	virtual/libiconv"
DEPEND="${DEPEND}
	>=dev-libs/libxml2-2.9.12
	>=dev-libs/libxslt-1.1.34
	sys-libs/zlib
	virtual/libiconv"

ruby_add_rdepend ">=dev-ruby/racc-1.4:0"

ruby_add_bdepend "
	>=dev-ruby/pkg-config-1.1.7
	>=dev-ruby/rexical-1.0.7
	dev-ruby/rdoc
	test? ( dev-ruby/minitest )"

all_ruby_prepare() {
	sed -i \
		-e '/tasks\/cross_compile/s:^:#:' \
		-e '/:test.*prerequisites/s:^:#:' \
		-e '/license/ s:^:#:' \
		Rakefile || die
	# Remove the cross compilation options since they interfere with
	# native building.
	sed -i -e 's/cross_compile  = true/cross_compile = false/' Rakefile || die
	sed -i -e '/cross_config_options/d' Rakefile || die

	sed -e '/simplecov/,/^end/ s:^:#:' \
		-e '/reporters/I s:^:#:' \
		-i test/helper.rb || die

	sed -i -e '/mini_portile2/ s:^:#:' ${RUBY_FAKEGEM_GEMSPEC} || die

	# Account for fix making it upstream into our libxml2 system version
	sed -i -e '116 s/using_packaged/using_system/ ; 131 s/if/if false and /' test/html/test_comments.rb || die
}

each_ruby_configure() {
	NOKOGIRI_USE_SYSTEM_LIBRARIES=true \
		${RUBY} -Cext/${PN} extconf.rb \
		--with-zlib-include="${EPREFIX}"/usr/include \
		--with-zlib-lib="${EPREFIX}"/$(get_libdir) \
		--with-iconv-include="${EPREFIX}"/usr/include \
		--with-iconv-lib="${EPREFIX}"/$(get_libdir) \
		--with-xml2-include="${EPREFIX}"/usr/include/libxml2 \
		--with-xml2-lib="${EPREFIX}"/usr/$(get_libdir) \
		--with-xslt-dir="${EPREFIX}"/usr \
		--with-iconvlib=iconv \
		|| die "extconf.rb failed"
}

each_ruby_compile() {
	if ! [[ -f lib/nokogiri/css/tokenizer.rb ]]; then
		${RUBY} -S rake lib/nokogiri/css/tokenizer.rb || die "rexical failed"
	fi

	if ! [[ -f lib/nokogiri/css/parser.rb ]]; then
		${RUBY} -S rake lib/nokogiri/css/parser.rb || die "racc failed"
	fi

	emake -Cext/${PN} \
		V=1 \
		CFLAGS="${CFLAGS} -fPIC" \
		archflag="${LDFLAGS}" || die "make extension failed"
	cp -l ext/${PN}/${PN}$(get_modname) lib/${PN}/ || die
}

each_ruby_test() {
	${RUBY} -Ilib:.:test -e 'Dir["test/**/test_*.rb"].each {|f| require f}' || die
}

each_ruby_install() {
	each_fakegem_install

	# Clean up "ext" directory before installing it. nokogumbo expects
	# the header files and shared object to be in ext.
	rm -rf ext/java ext/nokogiri/*.o ext/nokogiri/{mkmf.log,Makefile} || die
}

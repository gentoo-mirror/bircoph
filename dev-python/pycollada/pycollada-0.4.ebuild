# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
PYTHON_COMPAT=( python{2_7,3_3} )
PYTHON_MULTIPLE_ABI=1

EGIT_REPO_URI="https://github.com/pycollada/pycollada.git"
[ "${PV}" == 9999 ] || EGIT_COMMIT="v${PV}"

inherit distutils-r1 git-2

DESCRIPTION="python library for reading and writing collada documents"
HOMEPAGE="http://pycollada.github.com/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples"

DEPEND="doc? ( dev-python/sphinx )"
RDEPEND="dev-python/numpy
	dev-python/lxml
	>=dev-python/python-dateutil-2.0
	virtual/python-unittest2"

src_compile()
{
	distutils-r1_src_compile

	if use doc ; then
		pushd docs
		emake html
		popd
	fi
}

src_install()
{
	distutils-r1_src_install

	if use doc ; then
		pushd docs/_build/html
		dohtml -r *
		popd
	fi

	if use examples ; then
		insinto /usr/share/${P}/
		doins -r ${S}/examples
	fi

	install_test_data() {
		insinto $(python_get_sitedir)/collada/tests/
		doins -r ${S}/collada/tests/data
	}
	python_foreach_impl install_test_data
}

src_test()
{
	test_collada() {
		for script in ${S}/collada/tests/*.py
		do
			$EPYTHON "${script}"
		done
	}
	python_foreach_impl test_collada
}

# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="AMD ROCm Software stack"
HOMEPAGE="https://github.com/ROCm/ROCm"

ROCM_VERSION=${PV}
SLOT="0/$(ver_cut 1-2)"

LICENSE="MIT"
KEYWORDS="~amd64"

RDEPEND="
	|| (
		dev-util/hip:${SLOT}
	)
"

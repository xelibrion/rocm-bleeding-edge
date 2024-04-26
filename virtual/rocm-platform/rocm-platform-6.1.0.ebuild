# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm llvm

DESCRIPTION="AMD ROCm Software stack"
HOMEPAGE="https://github.com/ROCm/ROCm"

LICENSE="MIT"
KEYWORDS="~amd64"
SLOT="0/$(ver_cut 1-2)"

RDEPEND="dev-util/hip"

DEPEND="${RDEPEND}"


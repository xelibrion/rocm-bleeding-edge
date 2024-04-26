# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RESTRICT="strip"

inherit cmake llvm

DESCRIPTION="Radeon Open Compute Device Libraries"
HOMEPAGE="https://github.com/ROCm/llvm-project"
LICENSE="MIT"

LLVM_MAX_SLOT=17
SLOT="0/$(ver_cut 1-2)"
ROCM_VERSION="${PV}"

SRC_URI="https://github.com/ROCm/llvm-project/archive/refs/tags/rocm-${ROCM_VERSION}.tar.gz -> rocm-${ROCM_VERSION}.tar.gz"
S="${WORKDIR}/llvm-project-rocm-${ROCM_VERSION}/amd/device-libs/"
KEYWORDS="~amd64"

IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="sys-devel/clang:${LLVM_MAX_SLOT}"
DEPEND="${RDEPEND}"

CMAKE_BUILD_TYPE=Release

PATCHES=(
	"${FILESDIR}/${PN}-5.5.1-fix-llvm-link.patch"
	# "${FILESDIR}/${PN}-6.0.2-revert-install-into-clang.patch"
	# "${FILESDIR}/${PN}-6.0.0-gws-feature.patch"
	)

pkg_setup() {
	export CC="$(get_llvm_prefix ${LLVM_MAX_SLOT})/bin/clang" CXX="$(get_llvm_prefix ${LLVM_MAX_SLOT})/bin/clang++"
	tc-is-clang || Clang required
	strip-unsupported-flags
	
	append-cxxflags -O3 -flto=thin
}

src_prepare() {
	cmake_src_prepare
	sed -e "s:amdgcn/bitcode:lib/amdgcn/bitcode:" -i "${S}/cmake/OCL.cmake" || die
	sed -e "s:amdgcn/bitcode:lib/amdgcn/bitcode:" -i "${S}/cmake/Packages.cmake" || die
}

src_configure() {
	local mycmakeargs=(
		# -DLLVM_DIR="${EPREFIX}/usr/lib/llvm/roc/lib/cmake/llvm"
		-DLLVM_DIR="$(get_llvm_prefix "${LLVM_MAX_SLOT}")"
	)
	cmake_src_configure
}

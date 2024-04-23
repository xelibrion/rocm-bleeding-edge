# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm llvm

DESCRIPTION="CU / ROCM agnostic hip RAND implementation"
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/hipRAND"
SRC_URI="https://github.com/ROCmSoftwarePlatform/hipRAND/archive/refs/tags/rocm-${PV}.tar.gz -> hipRAND-rocm-${PV}.tar.gz"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

LICENSE="MIT"
KEYWORDS="~amd64"
SLOT="0/$(ver_cut 1-2)"

RESTRICT="test"

RDEPEND="dev-util/hip
	sci-libs/rocRAND:${SLOT}[${ROCM_USEDEP}]"
DEPEND="${RDEPEND}"
BDEPEND=""

S="${WORKDIR}/hipRAND-rocm-${PV}"

pkg_setup() {
	export CC="$(get_llvm_prefix ${LLVM_MAX_SLOT})/bin/clang" CXX="$(get_llvm_prefix ${LLVM_MAX_SLOT})/bin/clang++" F77="$(get_llvm_prefix)/bin/flang" FC="$(get_llvm_prefix)/bin/flang"
	tc-is-clang || die Clang required
	strip-unsupported-flags
}

src_configure() {
	local mycmakeargs=(
		-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		-DBUILD_FILE_REORG_BACKWARD_COMPATIBILITY=OFF
		-DROCM_SYMLINK_LIBS=OFF
	)

	CXX=hipcc cmake_src_configure
}

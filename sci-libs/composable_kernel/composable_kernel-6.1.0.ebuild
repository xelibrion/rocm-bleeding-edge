# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}

inherit cmake rocm llvm

DESCRIPTION="Composable Kernel (CK) library aims to provide a programming model for writing performance critical kernels for machine learning workloads."
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/composable_kernel"
COMPOSABLE_KERNEL_COMMIT_HASH=af471c2308a2eb72a03eaf107b0994a60e443c66 #rocm-${PV}
SRC_URI="https://github.com/ROCmSoftwarePlatform/composable_kernel/archive/${COMPOSABLE_KERNEL_COMMIT_HASH}.tar.gz -> composable_kernel-${COMPOSABLE_KERNEL_COMMIT_HASH}.tar.gz"

LICENSE="MIT"
KEYWORDS="~amd64"
SLOT="0/$(ver_cut 1-2)"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

RDEPEND="dev-util/hip"

DEPEND="${RDEPEND}
	dev-build/rocm-cmake"

BDEPEND="dev-build/rocm-cmake
	>=dev-build/cmake-3.22"

S="${WORKDIR}/${PN}-${COMPOSABLE_KERNEL_COMMIT_HASH}"

PATCHES=(
	"${FILESDIR}/${PN}-6.1.0-do-not-build-tests-examples-profiler.patch"
	"${FILESDIR}/sqrtf.patch"
	"${FILESDIR}/${PN}-6.1.0-vanilla-llvm.patch"
)

pkg_setup() {
	export CC="$(get_llvm_prefix ${LLVM_MAX_SLOT})/bin/clang" CXX="$(get_llvm_prefix ${LLVM_MAX_SLOT})/bin/clang++"
	export AR="$(get_llvm_prefix)/bin/llvm-ar" RANLIB="$(get_llvm_prefix)/bin/llvm-ranlib"
	tc-is-clang || die Needs Clang
	strip-unsupported-flags

	addpredict /dev/kfd
	addpredict /dev/dri/

	#append-cxxflags -Wno-error=reserved-identifier
	append-cxxflags -fhip-new-launch-api -O3 -Wno-error=unsafe-buffer-usage
}

src_configure() {
	local mycmakeargs=(
		-DDL_KERNELS=on
		-DCMAKE_SKIP_RPATH=On
		-DGPU_TARGETS="$(get_amdgpu_flags)"
	)

	CXX="hipcc --include hip/hip_runtime.h" cmake_src_configure
}

# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake llvm prefix

DESCRIPTION="Radeon Open Compute Code Object Manager"
HOMEPAGE="https://github.com/ROCm/llvm-project"
LICENSE="MIT"

LLVM_MAX_SLOT=17
ROCM_VERSION="${PV}"
SLOT="0/$(ver_cut 1-2)"

SRC_URI="https://github.com/ROCm/llvm-project/archive/refs/tags/rocm-${ROCM_VERSION}.tar.gz -> rocm-${ROCM_VERSION}.tar.gz"
S="${WORKDIR}/llvm-project-rocm-${ROCM_VERSION}/amd/comgr/"
KEYWORDS="~amd64"

IUSE="test"
RESTRICT="!test? ( test )"

PATCHES=(
	"${FILESDIR}/${PN}-5.1.3-rocm-path.patch"
	"${FILESDIR}/0001-Find-CLANG_RESOURCE_DIR-using-clang-print-resource-d.patch"
	"${FILESDIR}/${PN}-5.7.1-correct-license-install-dir.patch"
)


RDEPEND=">=dev-libs/rocm-device-libs-${PV}
	sys-devel/clang:${LLVM_MAX_SLOT}=
	sys-devel/clang-runtime:=
	sys-devel/lld:${LLVM_MAX_SLOT}="
DEPEND="${RDEPEND}"

CMAKE_BUILD_TYPE=Release

src_prepare() {
	sed '/sys::path::append(HIPPath/s,"hip","",' -i src/comgr-env.cpp || die
	sed "/return LLVMPath;/s,LLVMPath,llvm::SmallString<128>(\"$(get_llvm_prefix ${LLVM_MAX_SLOT})\")," -i src/comgr-env.cpp || die
	eapply $(prefixify_ro "${FILESDIR}"/${PN}-5.0-rocm_path.patch)
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DLLVM_DIR="$(get_llvm_prefix ${LLVM_MAX_SLOT})"
		-DCMAKE_STRIP=""  # disable stripping defined at lib/comgr/CMakeLists.txt:58
		-DBUILD_TESTING=$(usex test ON OFF)
	)
	cmake_src_configure
}

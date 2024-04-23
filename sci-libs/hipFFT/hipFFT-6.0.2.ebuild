# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=${PV}
HIPFFT_COMMIT=18c75d803dfd52bfd7cd07d8a4cede64bb945078

inherit cmake rocm llvm

DESCRIPTION="CU / ROCM agnostic hip FFT implementation"
HOMEPAGE="https://github.com/ROCmSoftwarePlatform/hipFFT"
#SRC_URI="https://github.com/ROCmSoftwarePlatform/hipFFT/archive/refs/tags/rocm-${PV}.tar.gz -> hipFFT-rocm-${PV}.tar.gz"
#Post 6.0.0 commits needed to build from tarball
SRC_URI="https://github.com/ROCmSoftwarePlatform/hipFFT/archive/${HIPFFT_COMMIT}.tar.gz -> hipFFT-rocm-${PV}.tar.gz"
REQUIRED_USE="${ROCM_REQUIRED_USE}"

LICENSE="MIT"
KEYWORDS="~amd64"
SLOT="0/$(ver_cut 1-2)"

RESTRICT="test"

RDEPEND="dev-util/hip
	sci-libs/rocFFT:${SLOT}[${ROCM_USEDEP}]"
DEPEND="${RDEPEND}"
BDEPEND=""

#S="${WORKDIR}/hipFFT-rocm-${PV}"
S="${WORKDIR}/hipFFT-${HIPFFT_COMMIT}"

#PATCHES=(
#	"${FILESDIR}/${PN}-5.0.2-remove-git-dependency.patch"
#)

pkg_setup() {
	export CC="$(get_llvm_prefix ${LLVM_MAX_SLOT})/bin/clang" CXX="$(get_llvm_prefix ${LLVM_MAX_SLOT})/bin/clang++"
	tc-is-clang || die Clang required
	strip-unsupported-flags
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_INCLUDEDIR="include"
		-DCMAKE_MODULE_PATH="${EPREFIX}"/usr/$(get_libdir)/cmake/hip
		-DHIP_ROOT_DIR="${EPREFIX}/usr"
		-DROCM_SYMLINK_LIBS=OFF
		-DBUILD_CLIENTS_TESTS=OFF
		-DBUILD_CLIENTS_RIDER=OFF
		-DBUILD_FILE_REORG_BACKWARD_COMPATIBILITY=OFF
	)

	CXX=hipcc cmake_src_configure
}

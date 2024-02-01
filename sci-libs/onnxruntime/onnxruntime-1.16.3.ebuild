# Copyright 2021 Haelwenn (lanodan) Monnier <contact@hacktivis.me>
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ROCM_VERSION=6.0.0
LLVM_MAX_SLOT="18"

inherit llvm cmake rocm

SAFEINT_COMMIT=ff15c6ada150a5018c5ef2172401cb4529eac9c0
FLATBUFFERS_PV=1.12.0
DATE_PV=2.4.1

DESCRIPTION="cross-platform, high performance ML inferencing and training accelerator"
HOMEPAGE="https://github.com/microsoft/onnxruntime"
SRC_URI="
	https://github.com/microsoft/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/dcleblanc/SafeInt/archive/${SAFEINT_COMMIT}.tar.gz -> SafeInt-${SAFEINT_COMMIT:0:10}.tar.gz
	https://github.com/google/flatbuffers/archive/v${FLATBUFFERS_PV}.tar.gz -> flatbuffers-${FLATBUFFERS_PV}.tar.gz
	https://github.com/HowardHinnant/date/archive/v${DATE_PV}.tar.gz -> hhdate-${DATE_PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="benchmark test rocm"

RESTRICT="test"

PATCHES=(
	"${FILESDIR}/re2-pkg-config-r1.patch"
	"${FILESDIR}/system-onnx-r1.patch"
	"${FILESDIR}/system-cpuinfo.patch"
	"${FILESDIR}/system-nsync.patch"
	"${FILESDIR}/system-composable_kernel.patch"
	"${FILESDIR}/system-protobuf.patch"
	"${FILESDIR}/system-mp11.patch"
	"${FILESDIR}/rocm-version-override-r2.patch"
	"${FILESDIR}/hip-gentoo.patch"
	"${FILESDIR}/rocblas-half.patch"
)

S="${WORKDIR}/${P}/cmake"

# Needs https://gitlab.com/libeigen/eigen/-/commit/d0e3791b1a0e2db9edd5f1d1befdb2ac5a40efe0.patch on eigen-3.4.0
RDEPEND="
	dev-python/numpy
	dev-libs/date:=
	>=dev-libs/boost-1.66:=
	dev-libs/protobuf:=
	dev-libs/re2:=
	dev-cpp/nlohmann_json:=
	dev-libs/nsync
	dev-cpp/eigen:3
	benchmark? ( dev-cpp/benchmark )
	sci-libs/onnx:=
	dev-util/hipify-clang
	sci-libs/composable_kernel
	dev-cpp/ms-gsl:=
	sci-libs/hipFFT:=
	sci-libs/hipCUB:=
"

DEPEND="
	${RDEPEND}
	test? ( dev-cpp/gtest )
	sys-devel/clang
	rocm? (
		>=dev-libs/rocr-runtime-${ROCM_VERSION}:=
		>=dev-util/hip-${ROCM_VERSION}:=
		>=dev-libs/rccl-${ROCM_VERSION}:=
		>=sci-libs/miopen-${ROCM_VERSION}:=
		>=dev-util/roctracer-${ROCM_VERSION}:=
	)
"

pkg_setup() {
	CC="$(get_llvm_prefix)/bin/clang" CXX="$(get_llvm_prefix)/bin/clang++"
	tc-is-clang || die Clang required

	strip-unsupported-flags

	append-cppflags "-I/usr/include/eigen3"
	append-flags "-Wno-error=deprecated-declarations"
	append-flags "-Wno-error=instantiation-after-specialization"
	append-flags "-Wno-error=shorten-64-to-32" "-Wno-error=unused-private-field"
}

src_prepare() {
	pushd ..
	eapply "${FILESDIR}/shared-build-fix.patch"
	eapply "${FILESDIR}/hip-libdir.patch"
	eapply "${FILESDIR}/composable_kernel-6.patch"
	popd

	cmake_src_prepare
}

src_configure() {
	export ROCM_PATH=/usr MIOPEN_PATH=/usr
	#export ROCM_VERSION_INT=$(($(ver_cut 1 ${ROCM_VERSION})*10000 + $(ver_cut 2 ${ROCM_VERSION})*100 + $(ver_cut 3 ${ROCM_VERSION})))
	export ROCM_VERSION="${ROCM_VERSION}"-

	local mycmakeargs=(
		-Donnxruntime_BUILD_BENCHMARKS=$(usex benchmark)
		-Donnxruntime_BUILD_UNIT_TESTS=$(usex test)
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
		-DFETCHCONTENT_SOURCE_DIR_SAFEINT="${WORKDIR}/SafeInt-${SAFEINT_COMMIT}"
		-DFETCHCONTENT_SOURCE_DIR_FLATBUFFERS="${WORKDIR}/flatbuffers-${FLATBUFFERS_PV}"
		-DFETCHCONTENT_SOURCE_DIR_DATE="${WORKDIR}/date-${DATE_PV}"
		-Donnxruntime_USE_TENSORRT=OFF
		-Donnxruntime_USE_CUDA=OFF
		-Donnxruntime_USE_ROCM=$(usex rocm ON OFF)
		-Donnxruntime_DISABLE_ABSEIL=ON
		-Donnxruntime_BUILD_FOR_NATIVE_MACHINE=ON
		-Donnxruntime_BUILD_SHARED_LIB=ON
		-Donnxruntime_USE_FULL_PROTOBUF=OFF
		-DCMAKE_HIP_COMPILER="$(get_llvm_prefix)/bin/clang++"
		-DCMAKE_HIP_ARCHITECTURES="$(get_amdgpu_flags)"
	)
	cmake_src_configure
}

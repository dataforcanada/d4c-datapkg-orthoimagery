#!/usr/bin/env bash
#
# Stage 1: GDAL "ubuntu-full" image with the proprietary ECW + MrSID SDKs.
#
# Uses OSGeo's docker/ubuntu-full/Dockerfile *unmodified*, pinned to a GDAL
# release tag. Nothing in the GDAL checkout is patched; everything is driven by
# build args the upstream Dockerfile already exposes (WITH_ECW / WITH_MRSID
# download the SDKs themselves).
#
# Note: checking out the tag is NOT enough to pin the build. bh-gdal.sh wipes
# the copied checkout and downloads whatever GDAL_VERSION says (default:
# master). The checkout only contributes docker/ubuntu-full/*; the pin lives
# in --build-arg GDAL_VERSION=v<tag>, which is also how OSGeo builds releases.
#
# Note: the *builder* stage runs on builder-base.Dockerfile (ubuntu:26.04 with
# GNU `uname` first on PATH) via the upstream BASE_IMAGE arg, because
# bh-gdal.sh gates the ECW/MrSID CMake flags on `uname -p`, which prints
# "unknown" under Ubuntu 26.04's default uutils coreutils. See that file for
# details. The runtime image (TARGET_BASE_IMAGE) is stock ubuntu:26.04.
#
# Result: ${IMAGE}:${TAG}   (default dataforcanada/gdal-ecw-mrsid:3.13.3)
#
# Usage:
#   docker/gdal/build.sh                        # build + verify
#   GDAL_VERSION=3.13.4 docker/gdal/build.sh    # bump GDAL
#   WITH_CCACHE= docker/gdal/build.sh           # disable ccache
#   BUILDKIT_PROGRESS=plain docker/gdal/build.sh 2>&1 | tee build.log
#
set -euo pipefail

GDAL_VERSION="${GDAL_VERSION:-3.13.3}"          # GDAL release tag, without the leading "v"
PROJ_VERSION="${PROJ_VERSION:-9.8.1}"           # PROJ release tag (upstream default is "master")
IMAGE="${IMAGE:-dataforcanada/gdal-ecw-mrsid}"
TAG="${TAG:-${GDAL_VERSION}}"
WITH_CCACHE="${WITH_CCACHE-1}"                  # set to "" to disable
GDAL_REPO="${GDAL_REPO:-https://github.com/OSGeo/gdal.git}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="${GDAL_SRC_DIR:-${SCRIPT_DIR}/src}"    # git-ignored
PLATFORM=linux/amd64

die() { echo "ERROR: $*" >&2; exit 1; }

# --- linux/amd64 only ---------------------------------------------------------
# Both SDKs are x86_64 glibc binaries and the upstream Dockerfile silently
# skips them on any other architecture (uname -m gate), which would yield an
# image *without* ECW/MrSID after an hours-long build. Fail fast instead.
daemon_arch="$(docker info --format '{{.Architecture}}')"
if [ "${daemon_arch}" != "x86_64" ] && [ "${D4C_ALLOW_EMULATED_BUILD:-}" != "1" ]; then
  die "the Docker daemon runs on ${daemon_arch}, but this image is linux/amd64 only
       (the ECW and MrSID SDKs are x86_64 binaries and OSGeo's Dockerfile only
       installs them when 'uname -m' is x86_64). Build on an x86_64 host, or
       set D4C_ALLOW_EMULATED_BUILD=1 to force a (very slow) QEMU build."
fi

# --- source checkout at the pinned tag ---------------------------------------
if [ -d "${SRC_DIR}/.git" ]; then
  git -C "${SRC_DIR}" fetch --depth 1 origin "refs/tags/v${GDAL_VERSION}:refs/tags/v${GDAL_VERSION}"
  git -C "${SRC_DIR}" checkout -q "v${GDAL_VERSION}"
else
  git clone --depth 1 --branch "v${GDAL_VERSION}" "${GDAL_REPO}" "${SRC_DIR}"
fi
# Sanity: make sure we are on the tag we think we are.
[ "$(git -C "${SRC_DIR}" describe --tags --exact-match)" = "v${GDAL_VERSION}" ] \
  || die "checkout in ${SRC_DIR} is not at v${GDAL_VERSION}"

# --- builder base image (GNU uname on PATH; see builder-base.Dockerfile) ------
BUILDER_BASE_IMAGE="${BUILDER_BASE_IMAGE:-dataforcanada/gdal-builder-base:26.04}"
echo ">>> Building ${BUILDER_BASE_IMAGE}"
docker buildx build \
  --platform "${PLATFORM}" \
  --file "${SCRIPT_DIR}/builder-base.Dockerfile" \
  --tag "${BUILDER_BASE_IMAGE}" \
  --load \
  "${SCRIPT_DIR}"

# --- build --------------------------------------------------------------------
# The Dockerfile does `COPY --link . gdal/`, so the build context must be the
# repo root and the Dockerfile referenced with -f.
echo ">>> Building ${IMAGE}:${TAG} (GDAL v${GDAL_VERSION}, PROJ ${PROJ_VERSION}, ECW + MrSID)"
cd "${SRC_DIR}"
docker buildx build \
  --platform "${PLATFORM}" \
  --file docker/ubuntu-full/Dockerfile \
  --build-arg BASE_IMAGE="${BUILDER_BASE_IMAGE}" \
  --build-arg GDAL_VERSION="v${GDAL_VERSION}" \
  --build-arg GDAL_BUILD_IS_RELEASE=YES \
  --build-arg PROJ_VERSION="${PROJ_VERSION}" \
  --build-arg WITH_ECW=yes \
  --build-arg WITH_MRSID=yes \
  --build-arg WITH_DEBUG_SYMBOLS=no \
  ${WITH_CCACHE:+--build-arg WITH_CCACHE=1} \
  --tag "${IMAGE}:${TAG}" \
  --load \
  .

# --- verify (assert, don't print) --------------------------------------------
echo ">>> Verifying ${IMAGE}:${TAG}"
run() { docker run --rm --platform "${PLATFORM}" "${IMAGE}:${TAG}" "$@"; }

got_version="$(run gdal-config --version)"
[ "${got_version}" = "${GDAL_VERSION}" ] \
  || die "gdal-config --version is '${got_version}', expected '${GDAL_VERSION}'"

formats="$(run gdalinfo --formats)"
grep -Eq '^ +ECW -raster-'   <<<"${formats}" || die "ECW driver missing from 'gdalinfo --formats'"
grep -Eq '^ +MrSID -raster-' <<<"${formats}" || die "MrSID driver missing from 'gdalinfo --formats'"

echo ">>> OK: ${IMAGE}:${TAG} — GDAL ${got_version} with ECW and MrSID"
grep -E '^ +(ECW|JP2ECW|MrSID|JP2MrSID) ' <<<"${formats}"

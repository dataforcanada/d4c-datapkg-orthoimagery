#!/usr/bin/env bash
#
# Stage 2: Python (uv venv holding the repo's pyproject.toml + uv.lock set:
# rioxarray, rasterio, xarray, dask, numpy, portolan-cli) on top of the stage-1
# GDAL + ECW + MrSID image. Requires stage 1 to exist locally:
#   docker/gdal/build.sh
#
# The build context is the repo root (that is where pyproject.toml and uv.lock
# live); .dockerignore keeps it to a handful of files rather than the hundreds
# of GB of imagery under data/ and scripts/.
#
# Result: ${IMAGE}:${TAG}   (default dataforcanada/gdal-ecw-mrsid-python:3.13.3)
#
# Usage:
#   docker/python/build.sh
#   GDAL_VERSION=3.13.4 docker/python/build.sh     # after building stage 1 for it
#   USER_UID=$(id -u) USER_GID=$(id -g) docker/python/build.sh
#
# The build itself runs verify-gdal-drivers as its last step, so a successful
# build already implies: ECW + MrSID in gdalinfo --formats, rasterio linked to
# GDAL ${GDAL_VERSION}, and ECW + MrSID in rasterio.Env().drivers().
#
set -euo pipefail

GDAL_VERSION="${GDAL_VERSION:-3.13.3}"
GDAL_IMAGE="${GDAL_IMAGE:-dataforcanada/gdal-ecw-mrsid}"
IMAGE="${IMAGE:-dataforcanada/gdal-ecw-mrsid-python}"
TAG="${TAG:-${GDAL_VERSION}}"
USER_UID="${USER_UID:-1000}"
USER_GID="${USER_GID:-${USER_UID}}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PLATFORM=linux/amd64

die() { echo "ERROR: $*" >&2; exit 1; }

docker image inspect "${GDAL_IMAGE}:${GDAL_VERSION}" >/dev/null 2>&1 \
  || die "base image ${GDAL_IMAGE}:${GDAL_VERSION} not found locally — run docker/gdal/build.sh first"

# The image is built straight from these two; `uv sync --locked` in the
# Dockerfile refuses to build if they have drifted apart.
for f in pyproject.toml uv.lock; do
  [ -f "${REPO_ROOT}/${f}" ] || die "${REPO_ROOT}/${f} not found — the image is built from it"
done

echo ">>> Building ${IMAGE}:${TAG} FROM ${GDAL_IMAGE}:${GDAL_VERSION}"
docker buildx build \
  --platform "${PLATFORM}" \
  --build-arg GDAL_VERSION="${GDAL_VERSION}" \
  --build-arg GDAL_IMAGE="${GDAL_IMAGE}" \
  --build-arg USER_UID="${USER_UID}" \
  --build-arg USER_GID="${USER_GID}" \
  --tag "${IMAGE}:${TAG}" \
  --file "${SCRIPT_DIR}/Dockerfile" \
  --load \
  "${REPO_ROOT}"

# Re-run the assertions against the finished image, as the runtime user.
echo ">>> Verifying ${IMAGE}:${TAG}"
docker run --rm --platform "${PLATFORM}" "${IMAGE}:${TAG}" verify-gdal-drivers --expect-gdal "${GDAL_VERSION}"
echo ">>> OK: ${IMAGE}:${TAG}"

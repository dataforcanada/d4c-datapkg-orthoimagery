#!/usr/bin/env bash
# initializeCommand for the dev container: runs on the *host* before the
# container is created. The image is built locally (it embeds proprietary
# SDKs, so it is not on a registry); without this check a missing image
# surfaces as a confusing "pull access denied" from Docker.
set -euo pipefail

image="${1:?usage: check-image.sh IMAGE:TAG}"

if ! docker image inspect "${image}" >/dev/null 2>&1; then
  cat >&2 <<EOF

ERROR: dev-container image '${image}' is not built yet.

Build it first (from the repo root; stage 1 takes a while, see docker/README.md):

    docker/gdal/build.sh      # stage 1: GDAL + ECW + MrSID
    docker/python/build.sh    # stage 2: uv venv with rioxarray/rasterio/...

then reopen the folder in the container.

EOF
  exit 1
fi

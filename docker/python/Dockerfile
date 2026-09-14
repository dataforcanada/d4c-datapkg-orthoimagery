# syntax=docker/dockerfile:1
#
# Stage 2: Python environment (uv-managed venv with rioxarray/rasterio/xarray/
# dask/numpy) on top of the stage-1 GDAL + ECW + MrSID image.
#
# To bump GDAL, change GDAL_VERSION (the base image tag) and rebuild. Nothing
# else here encodes the GDAL version: rasterio is compiled against whatever
# `gdal-config` the base image ships, and the build asserts that it matches.
#
# Build (from the repo root):
#   docker/python/build.sh
#   # or by hand:
#   docker buildx build --platform linux/amd64 \
#     --build-arg GDAL_VERSION=3.13.3 \
#     -t dataforcanada/gdal-ecw-mrsid-python:3.13.3 docker/python

ARG GDAL_VERSION=3.13.3
ARG GDAL_IMAGE=dataforcanada/gdal-ecw-mrsid
ARG UV_VERSION=0.12.13

# uv ships as a static binary in a scratch image; copying it in is the
# documented install method for Docker and avoids a curl|sh.
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv

FROM ${GDAL_IMAGE}:${GDAL_VERSION}
ARG GDAL_VERSION
ARG TARGETARCH

# ---- linux/amd64 only --------------------------------------------------------
# The ECW and MrSID SDKs are x86_64 binaries and the upstream GDAL Dockerfile
# only installs them on x86_64, so on any other architecture the base image
# would silently lack both drivers. Fail here, before doing any work.
RUN if [ "${TARGETARCH:-}" != "amd64" ] || [ "$(uname -m)" != "x86_64" ]; then \
      echo "ERROR: this image is linux/amd64 only (TARGETARCH=${TARGETARCH:-unset}, uname -m=$(uname -m))." >&2; \
      echo "       The ECW and MrSID SDKs are x86_64 binaries; build with --platform linux/amd64 on an x86_64 host." >&2; \
      exit 1; \
    fi

# ---- build deps for compiling rasterio against the image's GDAL -------------
# Deliberately NOT installing libgdal-dev: the base image already provides
# gdal-config, the headers and libgdal.so for the pinned GDAL. Ubuntu's
# libgdal-dev would install a *second*, driver-less GDAL next to it, which is
# exactly the shadowing this image exists to prevent (see the warning in
# GDAL's docker/README.md). git is for the dev-container use case.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
        build-essential \
        python3-dev \
        git \
        openssh-client

# Guard: gdal-config must be the pinned GDAL, and no apt GDAL may be present.
RUN test "$(gdal-config --version)" = "${GDAL_VERSION}" \
      || { echo "ERROR: gdal-config --version is '$(gdal-config --version)', expected '${GDAL_VERSION}'" >&2; exit 1; } \
    && if dpkg-query -W -f '${Status} ${Package}\n' 'libgdal*' 2>/dev/null | grep '^install ok installed'; then \
         echo "ERROR: apt-provided GDAL packages are installed (above); they would shadow the built GDAL. Refusing to build." >&2; \
         exit 1; \
       fi

COPY --from=uv /uv /uvx /usr/local/bin/
# Image-wide default: never install wheels that bundle libgdal (see file).
COPY uv.toml /etc/uv/uv.toml

# ---- non-root runtime user ---------------------------------------------------
# Ubuntu 26.04 ships a stock "ubuntu" user at uid 1000; drop it so USER_UID can
# default to 1000 (what dev-container UID remapping and most hosts expect).
ARG USERNAME=d4c
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
RUN if id ubuntu >/dev/null 2>&1; then userdel -r ubuntu; fi \
    && groupadd --gid "${USER_GID}" "${USERNAME}" \
    && useradd --uid "${USER_UID}" --gid "${USER_GID}" --create-home --shell /bin/bash "${USERNAME}" \
    && mkdir -p /opt/venv \
    && chown "${USER_UID}:${USER_GID}" /opt/venv \
    && echo "source /usr/share/bash-completion/bash_completion" >> "/home/${USERNAME}/.bashrc"

COPY --chmod=0755 verify_gdal_drivers.py /usr/local/bin/verify-gdal-drivers

# VIRTUAL_ENV/PATH: the venv is the default python for everything downstream.
# UV_PYTHON_DOWNLOADS=never: always use the system interpreter, never a
#   uv-managed one.
# GDAL_CONFIG: what rasterio's setup.py consults; explicit rather than PATH luck.
# D4C_GDAL_VERSION: what verify-gdal-drivers checks against at runtime.
#   (Not named GDAL_VERSION: rasterio's setup.py treats that as an override.)
# (No UV_NO_BINARY_PACKAGE here on purpose: it does not apply to
#   `uv pip install`; /etc/uv/uv.toml covers both interfaces.)
ENV VIRTUAL_ENV=/opt/venv \
    PATH=/opt/venv/bin:${PATH} \
    UV_PYTHON_DOWNLOADS=never \
    UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    GDAL_CONFIG=/usr/bin/gdal-config \
    D4C_GDAL_VERSION=${GDAL_VERSION}

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# ---- venv + packages ---------------------------------------------------------
# --no-binary rasterio is the critical bit: rasterio's PyPI wheels bundle their
# own libgdal (built without ECW/MrSID). Building the sdist makes it link
# against this image's libgdal via gdal-config. (`uv pip install` takes the
# pip-style `--no-binary <pkg>`; `--no-binary-package` is the `uv sync`/`uv add`
# spelling. /etc/uv/uv.toml already says the same; the flag is belt-and-braces.)
COPY --chown=${USER_UID}:${USER_GID} requirements.txt /tmp/requirements.txt
RUN --mount=type=cache,target=/home/${USERNAME}/.cache/uv,uid=${USER_UID},gid=${USER_GID} \
    uv venv --python /usr/bin/python3 "${VIRTUAL_ENV}" \
    && uv pip install --no-binary rasterio --requirements /tmp/requirements.txt \
    && rm /tmp/requirements.txt

# ---- verification: the build fails unless all of these hold ------------------
#   gdalinfo --formats lists ECW and MrSID
#   rasterio.__gdal_version__ == GDAL_VERSION
#   rasterio.Env().drivers() includes ECW and MrSID
#   (+ exactly one libgdal, the system one, is loaded; rioxarray round-trips)
RUN verify-gdal-drivers --expect-gdal "${GDAL_VERSION}"

CMD ["/bin/bash", "-l"]

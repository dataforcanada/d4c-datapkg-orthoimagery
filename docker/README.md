# Building the GDAL + ECW + MrSID images for the dev container

The dev container in [`.devcontainer/devcontainer.json`](../.devcontainer/devcontainer.json)
uses a locally built image (it embeds proprietary SDKs, so it is not published
to a registry). Build it in two stages, from the repo root:

```bash
docker/gdal/build.sh      # stage 1: GDAL 3.13.3 + ECW + MrSID   (~18 min cold on 16 cores; 3.6 GB)
docker/python/build.sh    # stage 2: uv venv with rioxarray etc.  (~1.5 min; 4.5 GB)
```

Then in VS Code: **Dev Containers: Reopen in Container**. If the image is
missing, the container's `initializeCommand` stops with a message pointing
back here instead of a cryptic "pull access denied".

| Stage | Image | Contents |
| --- | --- | --- |
| 1 | `dataforcanada/gdal-ecw-mrsid:3.13.3` | OSGeo's `ubuntu-full` GDAL build (Ubuntu 26.04, PROJ 9.8.1, all PROJ grids) plus the **ECW** (libecwj2 3.3) and **MrSID** (DSDK 9.5.5) drivers. Built from GDAL's own `docker/ubuntu-full/Dockerfile`, unmodified. |
| 2 | `dataforcanada/gdal-ecw-mrsid-python:3.13.3` | `FROM` stage 1. `uv`-managed venv at `/opt/venv` (system Python 3.14) with `rioxarray`, `rasterio` (compiled against the image's GDAL), `xarray`, `dask[array]`, `numpy`. Non-root user `d4c`. This is what the dev container runs. |

## Prerequisites

- Docker with BuildKit/buildx (Docker 23+; tested with 29.x) on an **x86_64
  host**. Both SDKs are x86_64 glibc binaries; the scripts refuse to run
  elsewhere. (Apple Silicon: possible under emulation with
  `D4C_ALLOW_EMULATED_BUILD=1`, but expect many hours.)
- ~15 GB free disk for build cache + images, and a decent network connection:
  stage 1 downloads Ubuntu dev packages, ~10 source tarballs, the two SDK
  zips and ~600 MB of PROJ grids.
- `git` (stage 1 shallow-clones GDAL into `docker/gdal/src/`, git-ignored).

## Stage 1 — `docker/gdal/build.sh`

What it does:

1. Builds a tiny builder base image `dataforcanada/gdal-builder-base:26.04`
   from [`gdal/builder-base.Dockerfile`](gdal/builder-base.Dockerfile) — see
   [Why a builder base image](#why-a-builder-base-image) below.
2. Shallow-clones `https://github.com/OSGeo/gdal.git` at tag `v3.13.3`.
3. Runs `docker buildx build` on GDAL's `docker/ubuntu-full/Dockerfile` with
   the build context at the checkout root (the Dockerfile does
   `COPY --link . gdal/`), passing only build args the upstream file already
   defines:

   ```bash
   docker buildx build \
     --platform linux/amd64 \
     --file docker/ubuntu-full/Dockerfile \
     --build-arg BASE_IMAGE=dataforcanada/gdal-builder-base:26.04 \
     --build-arg GDAL_VERSION=v3.13.3 \
     --build-arg GDAL_BUILD_IS_RELEASE=YES \
     --build-arg PROJ_VERSION=9.8.1 \
     --build-arg WITH_ECW=yes \
     --build-arg WITH_MRSID=yes \
     --build-arg WITH_DEBUG_SYMBOLS=no \
     --build-arg WITH_CCACHE=1 \
     --tag dataforcanada/gdal-ecw-mrsid:3.13.3 \
     --load .
   ```

4. Asserts the result: `gdal-config --version` must equal `3.13.3` and
   `gdalinfo --formats` must list `ECW` and `MrSID`. A failed assertion exits
   non-zero — do not use an image that failed here.

Environment knobs: `GDAL_VERSION` (default `3.13.3`, no leading `v`),
`PROJ_VERSION` (`9.8.1`), `IMAGE`, `TAG`, `WITH_CCACHE` (default `1`; set to
empty to disable), `GDAL_SRC_DIR`. For a scrollable log:
`BUILDKIT_PROGRESS=plain docker/gdal/build.sh 2>&1 | tee stage1.log`.

### What to expect

The builder stage compiles kealib, mongo-c-driver, mongocxx, TileDB,
libOpenDRIVE, libqb3, libjxl, arrow-adbc (Go), PROJ twice (once only to run
`projsync`, which downloads every PROJ grid) and finally GDAL with LTO.
Measured on this machine (16 cores, 30 GB RAM, NVMe): **17.8 min** end to end
from a cold cache, of which GDAL itself is ~4 min, adbc ~3 min, the grid
download ~3 min, TileDB ~2 min. With a warm ccache but *every* layer
invalidated (base image changed) it was 8.5 min. A 4-core laptop should plan
for 1–2 hours cold. The final image is 3.56 GB (the PROJ grids are most of
it). The Go module downloads in the adbc step have no retry logic upstream; if
that step fails with a `proxy.golang.org … read` error, just run the script
again — everything before it is a layer-cache hit.

### Rebuilds, `WITH_CCACHE` and `RSYNC_REMOTE`

Docker's layer cache does most of the work and needs nothing from you. Build
args are declared in order in the upstream Dockerfile, so a rebuild re-runs
only the layers from the first changed arg onward:

- change `GDAL_VERSION` only → only the GDAL compile re-runs; PROJ, TileDB,
  libjxl, adbc… are layer-cache hits;
- change `PROJ_VERSION` → PROJ and GDAL re-run;
- change `WITH_ECW`/`WITH_MRSID`/`WITH_CCACHE` → everything from the SDK
  download step onward re-runs (TileDB and friends are earlier and stay cached);
- change `BASE_IMAGE` → the whole builder stage re-runs.

`WITH_CCACHE=1` (on by default here) runs every compile through `ccache`,
with the cache kept in BuildKit cache mounts (`--mount=type=cache,id=ubuntu-full-*`)
that persist on this machine until `docker builder prune`. It is worth
keeping on: when the builder base changed during setup and *every* layer was
invalidated, TileDB still rebuilt in 2.5 s instead of 104 s and libjxl in
22 s instead of 50 s. For a patch-level GDAL bump most translation units are
unchanged, so the GDAL step drops to a few minutes (only the LTO link is not
cacheable). Note upstream caps the third-party caches at 100 MB and GDAL's at
1 GB.

`RSYNC_REMOTE` is **not** worth it on a single workstation. It rsyncs those
ccache directories to/from an rsync daemon (OSGeo's `build.sh` runs one in a
container on `--network host`) so the cache survives builder prunes and can be
shared across machines or CI. BuildKit cache mounts already give the same
benefit locally with zero setup.

PROJ grids: OSGeo passes `PROJ_DATUMGRID_LATEST_LAST_MODIFIED` (the
`Last-Modified` header of cdn.proj.org) purely to bust that layer's cache when
new grids are published. This script doesn't, so the grid set is frozen until
something above that layer changes — fine for reproducibility; pass
`--build-arg PROJ_DATUMGRID_LATEST_LAST_MODIFIED="$(date)"` yourself if you
want fresh grids.

### Why a builder base image

GDAL's `docker/ubuntu-full/bh-gdal.sh` only passes `-DECW_ROOT` /
`-DMRSID_ROOT` to CMake when `uname -p` prints `x86_64`. Ubuntu 26.04's
default coreutils are uutils (Rust), whose `uname -p` prints `unknown`, so on
stock `ubuntu:26.04` both SDKs are downloaded and then silently ignored: the
build "succeeds" and the image has no ECW/MrSID driver (this is how the first
attempt here failed; OSGeo's CI never enables the proprietary SDKs, so nothing
upstream catches it).

Switching the system to GNU coreutils (`coreutils-from-gnu`) does not help:
`build-essential` on 26.04 hard-depends on `coreutils-from-uutils` and is the
first thing the upstream Dockerfile installs, which flips `uname` straight
back. Ubuntu does ship GNU coreutils alongside as `gnu-coreutils`
(`/usr/bin/gnuuname` etc.), and apt never touches `/usr/local`, so
`gdal/builder-base.Dockerfile` is just `ubuntu:26.04` plus
`ln -s /usr/bin/gnuuname /usr/local/bin/uname` — GNU `uname` wins PATH lookup
for the rest of the build. It is passed as the upstream `BASE_IMAGE` arg, i.e.
it only affects the builder stage; the runtime image (`TARGET_BASE_IMAGE`) is
stock `ubuntu:26.04` and the GDAL checkout is never modified. Drop it once
upstream changes that test to `uname -m` (still `uname -p` on `master` as of
2026-09).

## Stage 2 — `docker/python/build.sh`

Builds [`python/Dockerfile`](python/Dockerfile) `FROM dataforcanada/gdal-ecw-mrsid:${GDAL_VERSION}`
and then re-runs the assertions against the finished image as the runtime
user. Environment knobs: `GDAL_VERSION`, `GDAL_IMAGE`, `IMAGE`, `TAG`,
`USER_UID`/`USER_GID` (default 1000/1000).

Key points, all enforced inside the Dockerfile so the image cannot be built
with them violated:

- **rasterio is compiled from source** with `uv pip install --no-binary rasterio`.
  rasterio's PyPI wheels bundle their own libgdal (the 1.5.1 wheel ships GDAL
  3.12.4, without ECW/MrSID) that would shadow the image's GDAL; the sdist
  build links against it via `gdal-config` instead. Flag spelling matters:
  `uv pip install` takes pip-style `--no-binary <pkg>`, while
  `--no-binary-package <pkg>` belongs to `uv sync`/`uv add`. The image also
  installs [`python/uv.toml`](python/uv.toml) as `/etc/uv/uv.toml`, listing
  `rasterio fiona pyogrio gdal` for *both* interfaces, so anything you install
  later inside the container is forced from source too (fiona/pyogrio wheels
  bundle GDAL as well). Note `UV_NO_BINARY_PACKAGE` is not used: it only
  affects `uv sync`/`uv add`, not `uv pip install` (verified on uv 0.12.13).
- **No `libgdal-dev` from apt.** The base image already ships `gdal-config`,
  the headers and `libgdal.so` for the pinned GDAL; Ubuntu's `libgdal-dev`
  would add a second, driver-less GDAL next to it — exactly the shadowing this
  image exists to prevent (GDAL's own `docker/README.md` warns against it).
  Only `build-essential` and `python3-dev` are added, and the build refuses to
  continue if any `libgdal*` apt package is installed.
- Packages are pinned in [`python/requirements.txt`](python/requirements.txt);
  the venv uses the system Python 3.14 (`UV_PYTHON_DOWNLOADS=never`).
- The last build step runs `verify-gdal-drivers`
  ([`python/verify_gdal_drivers.py`](python/verify_gdal_drivers.py)), which
  asserts:
  1. `gdal-config --version` == the pinned GDAL;
  2. `gdalinfo --formats` lists ECW and MrSID;
  3. `rasterio.__gdal_version__` == the pinned GDAL;
  4. `rasterio.Env().drivers()` includes ECW and MrSID;
  5. exactly one `libgdal` is mapped into the Python process and it is the
     system one (no wheel-bundled copy);
  6. rioxarray round-trips an in-memory GeoTIFF.

  `verify-gdal-drivers` is on `PATH` in the image; run it any time (the dev
  container runs it as `postCreateCommand`).

## Using it in the dev container

`.devcontainer/devcontainer.json` points at `dataforcanada/gdal-ecw-mrsid-python:3.13.3`
directly — no build on the VS Code side. `remoteUser` is `d4c`; VS Code remaps
its UID/GID to yours on first start so files in the bind-mounted workspace keep
sane ownership. The venv at `/opt/venv` is owned by that user, so
`uv pip install <pkg>` works inside the container without root (and honours
the no-binary rule above).

Headless check with the Dev Containers CLI:

```bash
npx --yes @devcontainers/cli@latest up   --workspace-folder .
npx --yes @devcontainers/cli@latest exec --workspace-folder . verify-gdal-drivers
```

## Bumping GDAL

1. `GDAL_VERSION=3.13.4 docker/gdal/build.sh` (also bump `PROJ_VERSION` if a
   new PROJ is out).
2. `GDAL_VERSION=3.13.4 docker/python/build.sh`.
3. Change the tag in `.devcontainer/devcontainer.json` (two places) and
   the `GDAL_VERSION` defaults in the two scripts and `python/Dockerfile`.
4. Rebuild the dev container.

## Troubleshooting

- **`ECW driver missing from 'gdalinfo --formats'` after stage 1** — the
  GDAL configure step ran with uutils `uname`. Make sure the script built and
  passed `dataforcanada/gdal-builder-base:26.04` as `BASE_IMAGE` (see above),
  and in the build log look for `-DECW_ROOT=/opt/libecwj2-3.3
  -DMRSID_ROOT=/opt/Raster_DSDK` on the `GDAL_CMAKE_EXTRA_OPTS` echo line
  and `Found ECW` / `Found MRSID` from CMake.
- **`rasterio.__gdal_version__` mismatch in stage 2** (e.g. it reports 3.12.4)
  — a rasterio wheel got installed. Check that `--no-binary rasterio` and
  `/etc/uv/uv.toml` are in effect (`uv pip install --dry-run -v rasterio`
  should log `Selecting: rasterio==… (rasterio-….tar.gz)`) and that no
  `libgdal*` apt package is present.
- **"this image is linux/amd64 only"** — you are building on a non-x86_64
  daemon; see Prerequisites.
- **Stale grids / wrong PROJ** — see the PROJ notes under stage 1.
- **Free space** — `docker builder prune` clears the BuildKit cache
  (including ccache); `docker image rm dataforcanada/gdal-ecw-mrsid:3.13.3`
  etc. removes images.

#!/opt/venv/bin/python
"""Assert that GDAL + rasterio in this environment are the ones we built.

Every check is an assertion: the first failure exits non-zero with a message
naming what was expected and what was found. Nothing is merely printed for a
human to eyeball. Used as a `RUN` step in docker/python/Dockerfile (so the
image build fails), as the dev container's postCreateCommand, and runnable by
hand at any time: `verify-gdal-drivers [--expect-gdal X.Y.Z]`.

Checks
  1. `gdal-config --version` == expected GDAL version (the base image is the
     pinned one, and gdal-config is the one rasterio was compiled against).
  2. `gdalinfo --formats` lists ECW and MrSID.
  3. `rasterio.__gdal_version__` == expected GDAL version.
  4. `rasterio.Env().drivers()` includes ECW and MrSID.
  5. The libgdal mapped into this Python process is the system one, and there
     is exactly one — i.e. no wheel-bundled libgdal shadowing it.
  6. rioxarray can open a raster through that stack (in-memory GeoTIFF only;
     no ECW/MrSID files are touched).

The expected version comes from --expect-gdal, else $D4C_GDAL_VERSION (baked
into the image from the GDAL_VERSION build arg), else `gdal-config --version`.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys

REQUIRED_DRIVERS = ("ECW", "MrSID")


def fail(msg: str) -> None:
    print(f"FAIL: {msg}", file=sys.stderr)
    sys.exit(1)


def ok(msg: str) -> None:
    print(f"ok: {msg}")


def run(*cmd: str) -> str:
    try:
        return subprocess.check_output(cmd, text=True, stderr=subprocess.STDOUT).strip()
    except (OSError, subprocess.CalledProcessError) as exc:
        fail(f"{' '.join(cmd)}: {exc}")
        raise  # unreachable; keeps type checkers happy


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n", 1)[0])
    parser.add_argument("--expect-gdal", metavar="X.Y.Z", help="expected GDAL version")
    args = parser.parse_args()

    gdal_config = os.environ.get("GDAL_CONFIG", "gdal-config")
    config_version = run(gdal_config, "--version")
    expected = args.expect_gdal or os.environ.get("D4C_GDAL_VERSION") or config_version
    if not re.fullmatch(r"\d+\.\d+\.\d+", expected):
        fail(f"expected GDAL version {expected!r} is not of the form X.Y.Z")

    # 1. gdal-config is the pinned GDAL
    if config_version != expected:
        fail(f"{gdal_config} --version is {config_version!r}, expected {expected!r}")
    ok(f"gdal-config --version == {expected}")

    # 2. gdalinfo --formats lists both proprietary drivers
    formats = run("gdalinfo", "--formats")
    for drv in REQUIRED_DRIVERS:
        if not re.search(rf"^\s+{re.escape(drv)} -raster-", formats, re.MULTILINE):
            fail(f"{drv} missing from 'gdalinfo --formats'")
    ok("gdalinfo --formats lists ECW and MrSID")

    # 3. rasterio links against the pinned GDAL
    try:
        import rasterio
    except ImportError as exc:
        fail(f"cannot import rasterio: {exc}")
    if rasterio.__gdal_version__ != expected:
        fail(
            f"rasterio.__gdal_version__ is {rasterio.__gdal_version__!r}, expected "
            f"{expected!r} — rasterio is not using the image's GDAL "
            "(was a PyPI wheel with bundled libgdal installed?)"
        )
    ok(f"rasterio {rasterio.__version__} reports GDAL {rasterio.__gdal_version__}")

    # 4. rasterio sees the drivers (drivers() needs an *entered* Env)
    with rasterio.Env() as env:
        drivers = env.drivers()
    for drv in REQUIRED_DRIVERS:
        if drv not in drivers:
            fail(f"{drv} missing from rasterio.Env().drivers() ({len(drivers)} drivers registered)")
    ok("rasterio.Env().drivers() includes ECW and MrSID")

    # 5. exactly one libgdal in this process, and it is the system one
    with open("/proc/self/maps") as maps:
        libgdal = sorted(
            {line.split()[-1] for line in maps if "/libgdal" in line and line.split()[-1].startswith("/")}
        )
    if len(libgdal) != 1:
        fail(f"expected exactly one libgdal mapped into the process, found {libgdal}")
    if not libgdal[0].startswith("/usr/lib/") or "site-packages" in libgdal[0]:
        fail(f"libgdal is loaded from {libgdal[0]}, not from the system GDAL under /usr/lib/")
    ok(f"single system libgdal in process: {libgdal[0]}")

    # 6. rioxarray works end-to-end on an in-memory GeoTIFF
    try:
        import numpy as np
        import rioxarray
        from rasterio.transform import from_origin
    except ImportError as exc:
        fail(f"cannot import the raster stack: {exc}")
    path = "/vsimem/verify.tif"
    with rasterio.Env():
        data = np.arange(16, dtype="uint8").reshape(1, 4, 4)
        with rasterio.open(
            path, "w", driver="GTiff", width=4, height=4, count=1, dtype="uint8",
            crs="EPSG:3857", transform=from_origin(0, 4, 1, 1),
        ) as dst:
            dst.write(data)
        # Context manager: an open dataset left to the garbage collector gets
        # finalized during interpreter teardown and prints a spurious
        # "Error in sys.excepthook" at exit.
        with rioxarray.open_rasterio(path) as src:
            da = src.load()
            if da.shape != (1, 4, 4) or int(da.sum()) != int(data.sum()) or da.rio.crs.to_epsg() != 3857:
                fail(f"rioxarray round-trip mismatch: shape={da.shape} crs={da.rio.crs}")
    ok(f"rioxarray {rioxarray.__version__} round-trips an in-memory raster")

    print(f"OK: GDAL {expected} with ECW + MrSID, rasterio {rasterio.__version__} linked against it")


if __name__ == "__main__":
    main()

# syntax=docker/dockerfile:1
#
# Builder base for docker/gdal/build.sh: ubuntu:26.04 with GNU `uname` first
# on PATH.
#
# Why this exists: GDAL's docker/ubuntu-full/bh-gdal.sh only passes
# -DECW_ROOT / -DMRSID_ROOT to CMake when `uname -p` prints "x86_64". The
# Dockerfile's own SDK-download steps test `uname -m` (fine), but Ubuntu 26.04's
# default coreutils are uutils (Rust), whose `uname -p` prints "unknown". So on
# stock ubuntu:26.04 both SDKs are downloaded and then silently ignored by the
# GDAL configure step (OSGeo's CI never enables the proprietary SDKs, so
# nothing upstream catches it).
#
# Switching the whole system to GNU coreutils (coreutils-from-gnu) does not
# survive the upstream build: build-essential on 26.04 hard-depends on
# coreutils-from-uutils and is the first thing the upstream Dockerfile
# installs. Ubuntu does ship GNU coreutils alongside, as gnu-coreutils with
# gnu-prefixed binaries (/usr/bin/gnuuname), and apt never touches /usr/local,
# so a symlink there wins PATH lookup for the rest of the build.
#
# This image is passed as the upstream Dockerfile's BASE_IMAGE build arg, i.e.
# it is only the *builder* stage. TARGET_BASE_IMAGE (the runtime image) stays
# stock ubuntu:26.04. Nothing in the GDAL checkout is modified.
#
# Drop this once upstream changes that test to `uname -m`
# (docker/ubuntu-full/bh-gdal.sh, still `uname -p` on master as of 2026-09).

ARG UBUNTU_IMAGE=ubuntu:26.04
FROM ${UBUNTU_IMAGE}

RUN test -x /usr/bin/gnuuname \
    && ln -s /usr/bin/gnuuname /usr/local/bin/uname \
    && test "$(uname -p)" = "x86_64"

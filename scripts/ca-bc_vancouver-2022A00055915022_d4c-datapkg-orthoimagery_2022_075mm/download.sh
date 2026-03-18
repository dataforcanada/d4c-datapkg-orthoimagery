#!/bin/bash
#
# download.sh — Download Vancouver 2022 orthoimagery index file
#
# This script:
#   1. Downloads the dataset index as a Parquet file from Vancouver Open Data.
#   2. Extracts image URLs from the Parquet file using DuckDB.
#
# Usage:
#   cd scripts/ca-bc_vancouver-2022A00055915022_d4c-datapkg-orthoimagery_2022_075mm
#   bash download.sh
#

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATASET_ID="ca-bc_vancouver-2022A00055915022_d4c-datapkg-orthoimagery_2022_075mm"
INDEX_BASE="ca-bc_vancouver-2022A00055915022_d4c-datapkg-orthoimagery_index_2022_075mm_2026-03-09"
PARQUET_FILE="${SCRIPT_DIR}/${INDEX_BASE}.parquet"
URL_FILE="${SCRIPT_DIR}/${INDEX_BASE}.txt"
DATA_INPUT_DIR="${SCRIPT_DIR}/../../data/input/${DATASET_ID}"

PARQUET_URL="https://opendata.vancouver.ca/api/explore/v2.1/catalog/datasets/orthophoto-imagery-2022/exports/parquet"

# ---------------------------------------------------------------------------
# Step 1 — Download the Parquet index file
# ---------------------------------------------------------------------------
echo "==> Step 1: Downloading Parquet index file..."
aria2c \
  "${PARQUET_URL}" \
  -d "${SCRIPT_DIR}" \
  -o "${INDEX_BASE}.parquet"

echo "    Saved to: ${PARQUET_FILE}"

# ---------------------------------------------------------------------------
# Step 2 — Extract image URLs from the Parquet file using DuckDB
# ---------------------------------------------------------------------------
echo "==> Step 2: Extracting image URLs with DuckDB..."
duckdb -noheader -csv -c \
  "SELECT mrsid_url FROM '${PARQUET_FILE}';" \
  | tr -d '"' \
  > "${URL_FILE}"

echo "    URL list written to: ${URL_FILE}"
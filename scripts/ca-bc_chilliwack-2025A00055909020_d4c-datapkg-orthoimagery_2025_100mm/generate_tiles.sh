#!/bin/bash

PROJECT_DIR="~/Documents/Personal/Projects/dataforcanada/d4c-datapkg-orthoimagery"
DATA_DIR="${PROJECT_DIR}/data"
DATA_OUTPUT_DIR="${DATA_DIR}/output/"
DATASET_ID="ca-bc_chilliwack-2025A00055909020_d4c-datapkg-orthoimagery_2025_100mm"

INPUT_DIR="${DATA_DIR}/input/${DATASET_ID}"
MBTILES_OUTPUT_FILE="${DATA_OUTPUT_DIR}/${DATASET_ID}.mbtiles"
PMTILES_OUTPUT_FILE="${DATA_OUTPUT_DIR}/${DATASET_ID}.pmtiles"

# Define arguments in an array
ARGS=(
  -progress
  -name "City of Chilliwack Orthoimagery for 2025 / Ortho-imagerie de la Ville de Chilliwack de 2025"
  -description "Orthoimagery 10cm resolution. / Ortho-imagerie à résolution de 10 cm."
  -attribution "Source: www.chilliwack.com / Source: www.chilliwack.com"
  -srs_epsg
  -mbtiles_compatible
  -wo "NUM_THREADS=ALL_CPUS"
  -wo "USE_OPENCL=TRUE"
  -sparse
  -work_dir ~/tmp/maptiler_engine
  -f webp32
  -o "${MBTILES_OUTPUT_FILE}"
  $INPUT_DIR/*.tif
)

ulimit -n 65536

# Run the command with the array
maptiler-engine "${ARGS[@]}"

pmtiles convert --tmpdir=~/tmp/pmtiles ${MBTILES_OUTPUT_FILE} ${PMTILES_OUTPUT_FILE}
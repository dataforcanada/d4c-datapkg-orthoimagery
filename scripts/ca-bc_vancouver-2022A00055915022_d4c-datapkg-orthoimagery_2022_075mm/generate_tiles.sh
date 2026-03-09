#!/bin/bash

# TODO: Update paths in this script
PROJECT_DIR="~/Documents/Personal/Projects/dataforcanada/process-orthoimagery-dev"
DATA_DIR="${PROJECT_DIR}/data"
DATA_INPUT_DIR="${DATA_DIR}/input/maptiler_engine_experiments"
DATA_OUTPUT_DIR="${DATA_DIR}/output/maptiler_engine_experiments"

INPUT_DIR="${PROJECT_DIR}/data/input/gine_experiments/winnipeg/original/2024"
MBTILES_OUTPUT_FILE="${DATA_OUTPUT_DIR}/ca-mb_winnipeg-2024A00054611040_orthoimagery_2024_075mm.mbtiles"
PMTILES_OUTPUT_FILE="${DATA_OUTPUT_DIR}/ca-mb_winnipeg-2024A00054611040_orthoimagery_2024_075mm.pmtiles"

# Define arguments in an array
ARGS=(
  -progress
  -name "City of Vancouver Orthoimagery for 2022 / Ortho-imagerie de la Ville de Vancouver de 2022"
  -description "Orthoimagery 7.5cm resolution. / Ortho-imagerie à résolution de 7,5 cm."
  -attribution "Source: opendata.vancouver.ca / Source: opendata.vancouver.ca"
  -srs_epsg
  -mbtiles_compatible
  -wo "NUM_THREADS=ALL_CPUS"
  -wo "USE_OPENCL=TRUE"
  -sparse
  -scale 2.000000
  -work_dir ~/tmp/maptiler_engine
  -f webp32
  -webp_quality 85
  -webp_lossy
  -webp_preset photo
  -resampling cubic
  -overviews_resampling average
  -o "${MBTILES_OUTPUT_FILE}"
  $INPUT_DIR/*.ecw
)

# Run the command with the array
maptiler-engine "${ARGS[@]}"

pmtiles convert --tmpdir=~/tmp/pmtiles ${MBTILES_OUTPUT_FILE} ${PMTILES_OUTPUT_FILE}

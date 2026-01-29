#!/bin/bash

PROJECT_DIR="/home/ripd/Documents/Personal/Projects/tiles_experiments"
DATA_DIR="${PROJECT_DIR}/data"
DATA_INPUT_DIR="${DATA_DIR}/input/maptiler_engine_experiments"
DATA_OUTPUT_DIR="${DATA_DIR}/output/maptiler_engine_experiments"

INPUT_DIR="${PROJECT_DIR}/data/input/maptiler_engine_experiments/winnipeg/original/2024"
MBTILES_OUTPUT_FILE="${DATA_OUTPUT_DIR}/ca-mb_winnipeg-2024A00054611040_orthoimagery_2024_075mm.mbtiles"
PMTILES_OUTPUT_FILE="${DATA_OUTPUT_DIR}/ca-mb_winnipeg-2024A00054611040_orthoimagery_2024_075mm.pmtiles"

echo "Output file: $OUTPUT_FILE"
echo "Input file: ${DATA_INPUT_DIR}/*.ecw"

# Define arguments in an array
ARGS=(
  -progress
  -name "City of Winnipeg Orthoimagery for 2024 / Ortho-imagerie de la Ville de Winnipeg de 2024"
  -description "Orthoimagery 7.5cm resolution. / Ortho-imagerie à résolution de 7,5 cm."
  -attribution "Source: data.winnipeg.ca / Source: data.winnipeg.ca"
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

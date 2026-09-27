#!/bin/bash

PROJECT_DIR="~/Documents/Personal/Projects/dataforcanada/d4c-datapkg-orthoimagery"
DATA_DIR="${PROJECT_DIR}/data"
DATA_OUTPUT_DIR="${DATA_DIR}/output/"
DATASET_ID="ca-mb_winnipeg-2012A00054611040_d4c-datapkg-orthoimagery_2012_100mm"

INPUT_DIR="${DATA_DIR}/input/${DATASET_ID}"
MBTILES_OUTPUT_FILE="${DATA_OUTPUT_DIR}/${DATASET_ID}.mbtiles"
PMTILES_OUTPUT_FILE="${DATA_OUTPUT_DIR}/${DATASET_ID}.pmtiles"

# Define arguments in an array
ARGS=(
  -progress
  -name "City of Winnipeg Orthoimagery for 2012 / Ortho-imagerie de la Ville de Winnipeg de 2012"
  -description "Orthoimagery 10cm resolution. / Ortho-imagerie à résolution de 10 cm."
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
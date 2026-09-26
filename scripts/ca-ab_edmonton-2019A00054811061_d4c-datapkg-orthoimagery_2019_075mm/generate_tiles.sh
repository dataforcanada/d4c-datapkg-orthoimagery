#!/bin/bash

PROJECT_DIR="~/Documents/Personal/Projects/dataforcanada/d4c-datapkg-orthoimagery"
DATA_DIR="${PROJECT_DIR}/data"
DATA_OUTPUT_DIR="${DATA_DIR}/output/"
DATASET_ID="ca-ab_edmonton-2019A00054811061_d4c-datapkg-orthoimagery_2019_075mm"

INPUT_DIR="${DATA_DIR}/input/${DATASET_ID}"
MBTILES_OUTPUT_FILE="${DATA_OUTPUT_DIR}/${DATASET_ID}.mbtiles"
PMTILES_OUTPUT_FILE="${DATA_OUTPUT_DIR}/${DATASET_ID}.pmtiles"

# Define arguments in an array
ARGS=(
  -progress
  -name "City of Edmonton Orthoimagery for 2019 / Ortho-imagerie de la Ville de Edmonton de 2019"
  -description "Orthoimagery 7.5cm resolution. / Ortho-imagerie à résolution de 7,5 cm."
  -attribution "Source: data.edmonton.ca / Source: data.edmonton.ca"
  -srs_epsg
  -mbtiles_compatible
  -wo "NUM_THREADS=ALL_CPUS"
  -wo "USE_OPENCL=TRUE"
  -sparse
  -work_dir ~/tmp/maptiler_engine
  -f webp32
  -nodata 255 255 255
  -srs EPSG:3776
  -o "${MBTILES_OUTPUT_FILE}"
  $INPUT_DIR/*.sid
)

#  -overviews_resampling average
#  -webp_quality 85
#  -webp_lossy
#  -webp_preset photo
#  -resampling cubic
#  -scale 2.000000

ulimit -n 65536

# Run the command with the array
maptiler-engine "${ARGS[@]}"

pmtiles convert --tmpdir=~/tmp/pmtiles ${MBTILES_OUTPUT_FILE} ${PMTILES_OUTPUT_FILE}
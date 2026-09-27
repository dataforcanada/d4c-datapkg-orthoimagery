#!/bin/bash

PROJECT_DIR="~/Documents/Personal/Projects/dataforcanada/d4c-datapkg-orthoimagery"
DATA_DIR="${PROJECT_DIR}/data"
DATA_OUTPUT_DIR="${DATA_DIR}/output/"

INPUT_DIR="${DATA_DIR}/input/ca-bc_vancouver-2013A00055915022_d4c-datapkg-orthoimagery_2013_075mm"
MBTILES_OUTPUT_FILE="${DATA_OUTPUT_DIR}/ca-bc_vancouver-2013A00055915022_d4c-datapkg-orthoimagery_2013_075mm.mbtiles"
PMTILES_OUTPUT_FILE="${DATA_OUTPUT_DIR}/ca-bc_vancouver-2013A00055915022_d4c-datapkg-orthoimagery_2013_075mm.pmtiles"

# Define arguments in an array
ARGS=(
  -progress
  -name "City of Vancouver Orthoimagery for 2013 / Ortho-imagerie de la Ville de Vancouver de 2013"
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
  $INPUT_DIR/*.ECW
)


# Run the command with the array
maptiler-engine "${ARGS[@]}"

pmtiles convert --tmpdir=~/tmp/pmtiles ${MBTILES_OUTPUT_FILE} ${PMTILES_OUTPUT_FILE}

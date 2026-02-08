# Data for Canada - Orthoimagery Process Labs
Look through our [process-orthoimagery-labs](https://github.com/dataforcanada/process-orthoimagery-labs) repo for the datasets processed and datasets currently being acquired. There is still lots of work to do to make it ready for systems. While the data processing workflow is still under development, you can [preview sample datasets](#download-and-preview) below.

## Development Environment

Although we prioritize open-source tools, we currently use [MapTiler Engine Pro](https://www.maptiler.com/engine/pricing) because it outperforms available open-source alternatives for this specific workflow.

## Specifications of Tile Packages

The specifications for the tile packages are defined in this code.

```bash
#!/bin/bash
PROJECT_DIR="~/Documents/Personal/Projects/dataforcanada/process-orthoimagery-labs"
DATASET_ID="ca-mb_winnipeg-2024A00054611040_orthoimagery_2024_075mm"
DATA_DIR="${PROJECT_DIR}/data"
DATA_INPUT_DIR="${DATA_DIR}/input/${DATASET_ID}"
DATA_OUTPUT_DIR="${DATA_DIR}/output/${DATASET_ID}"

MBTILES_OUTPUT_FILE="${DATA_OUTPUT_DIR}/${DATASET_ID}.mbtiles"
PMTILES_OUTPUT_FILE="${DATA_OUTPUT_DIR}/${DATASET_ID}.pmtiles"

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
  $DATA_INPUT_DIR/*.ecw
)

# Run the command with the array
maptiler-engine "${ARGS[@]}"

pmtiles convert --tmpdir=~/tmp/pmtiles ${MBTILES_OUTPUT_FILE} ${PMTILES_OUTPUT_FILE}
```

## Download and Preview

Here is a table of some of the datasets created from the current process.

| Place      | ISO   | Year | Provider   | Dataset ID & Preview                                                                                                                                                                                      | PMTiles                                                                                                                         | TileJSON                                                                                                                      | PMTiles Torrent                                                                                                                      |
| ---------- | ----- | ---- | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| Canada     | CA    | 2025 | Versatiles | [ca_versatiles_satellite_2025-08-10](https://pmtiles.io/#url=https://data-01.labs.dataforcanada.org/processed/ca_versatiles_satellite_2025-08-10.pmtiles)                                                 | [Download](https://data-01.labs.dataforcanada.org/processed/ca_versatiles_satellite_2025-08-10.pmtiles)                         | [TileJSON](https://tiles-01.labs.dataforcanada.org/processed/ca_versatiles_satellite_2025-08-10.json)                         |                                                                                                                                      |
| Canada     | CA    | 2020 | NRCan      | [ca_nrcan_land_cover_2020_30m](https://pmtiles.io/#url=https://data-01.labs.dataforcanada.org/processed/ca_nrcan_land_cover_2020_30m.pmtiles)                                                             | [Download](https://data-01.labs.dataforcanada.org/processed/ca_nrcan_land_cover_2020_30m.pmtiles)                               | [TileJSON](https://tiles-01.labs.dataforcanada.org/processed/ca_nrcan_land_cover_2020_30m.json)                               |                                                                                                                                      |
| Edmonton   | CA-AB | 2023 | Edmonton   | [ca-ab_edmonton-2023A00054811061_orthoimagery_2023_075mm](https://pmtiles.io/#url=https://data-01.labs.dataforcanada.org/processed/ca-ab_edmonton-2023A00054811061_orthoimagery_2023_075mm.pmtiles)       | [Download](https://data-01.labs.dataforcanada.org/processed/ca-ab_edmonton-2023A00054811061_orthoimagery_2023_075mm.pmtiles)    | [TileJSON](https://tiles-01.labs.dataforcanada.org/processed/ca-ab_edmonton-2023A00054811061_orthoimagery_2023_075mm.json)    | [Download](https://data-01.labs.dataforcanada.org/processed/ca-ab_edmonton-2023A00054811061_orthoimagery_2023_075mm.pmtiles.torrent) |
| Red Deer   | CA-AB | 2024 | Red Deer   | [ca-ab_red_deer-2024A00054808011_orthoimagery_2024_075mm](https://pmtiles.io/#url=https://data-01.labs.dataforcanada.org/processed/ca-ab_red_deer-2024A00054808011_orthoimagery_2024_075mm.pmtiles)       | [Download](https://data-01.labs.dataforcanada.org/processed/ca-ab_red_deer-2024A00054808011_orthoimagery_2024_075mm.pmtiles)    | [TileJSON](https://tiles-01.labs.dataforcanada.org/processed/ca-ab_red_deer-2024A00054808011_orthoimagery_2024_075mm.json)    |                                                                                                                                      |
| Red Deer   | CA-AB | 2025 | Red Deer   | [ca-ab_red_deer-2025A00054808011_orthoimagery_2025_075mm](https://pmtiles.io/#url=https://data-01.labs.dataforcanada.org/processed/ca-ab_red_deer-2025A00054808011_orthoimagery_2025_075mm.pmtiles)       | [Download](https://data-01.labs.dataforcanada.org/processed/ca-ab_red_deer-2025A00054808011_orthoimagery_2025_075mm.pmtiles)    | [TileJSON](https://tiles-01.labs.dataforcanada.org/processed/ca-ab_red_deer-2025A00054808011_orthoimagery_2025_075mm.json)    |                                                                                                                                      |
| Burnaby    | CA-BC | 2020 | Burnaby    | [ca-bc_burnaby-2020A00055915025_orthoimagery_2020_075mm](https://pmtiles.io/#url=https://data-01.labs.dataforcanada.org/processed/ca-bc_burnaby-2020A00055915025_orthoimagery_2020_075mm.pmtiles)         | [Download](https://data-01.labs.dataforcanada.org/processed/ca-bc_burnaby-2020A00055915025_orthoimagery_2020_075mm.pmtiles)     | [TileJSON](https://tiles-01.labs.dataforcanada.org/processed/ca-bc_burnaby-2020A00055915025_orthoimagery_2020_075mm.json)     |                                                                                                                                      |
| Vancouver  | CA-BC | 2022 | Vancouver  | [ca-bc_vancouver-2022A00055915022_orthoimagery_2022_075mm](https://pmtiles.io/#url=https://data-01.labs.dataforcanada.org/processed/ca-bc_vancouver-2022A00055915022_orthoimagery_2022_075mm.pmtiles)     | [Download](https://data-01.labs.dataforcanada.org/processed/ca-bc_vancouver-2022A00055915022_orthoimagery_2022_075mm.pmtiles)   | [TileJSON](https://tiles-01.labs.dataforcanada.org/processed/ca-bc_vancouver-2022A00055915022_orthoimagery_2022_075mm.json)   |                                                                                                                                      |
| Winnipeg   | CA-MB | 2024 | Winnipeg   | [ca-mb_winnipeg-2024A00054611040_orthoimagery_2024_075mm](https://pmtiles.io/#url=https://data-01.labs.dataforcanada.org/processed/ca-mb_winnipeg-2024A00054611040_orthoimagery_2024_075mm.pmtiles)       | [Download](https://data-01.labs.dataforcanada.org/processed/ca-mb_winnipeg-2024A00054611040_orthoimagery_2024_075mm.pmtiles)    | [TileJSON](https://tiles-01.labs.dataforcanada.org/processed/ca-mb_winnipeg-2024A00054611040_orthoimagery_2024_075mm.json)    |                                                                                                                                      |
| Whitehorse | CA-YT | 2019 | Whitehorse | [ca-yt_whitehorse-2019A000556001009_orthoimagery_2019_200mm](https://pmtiles.io/#url=https://data-01.labs.dataforcanada.org/processed/ca-yt_whitehorse-2019A000556001009_orthoimagery_2019_200mm.pmtiles) | [Download](https://data-01.labs.dataforcanada.org/processed/ca-yt_whitehorse-2019A000556001009_orthoimagery_2019_200mm.pmtiles) | [TileJSON](https://tiles-01.labs.dataforcanada.org/processed/ca-yt_whitehorse-2019A000556001009_orthoimagery_2019_200mm.json) |                                                                                                                                      |

## The Plan

The objective is to standardize the source datasets used by Data for Canada processes. For instance, Vancouver’s orthoimagery is currently distributed in proprietary formats (MrSID and ECW) that require specialized drivers. We are currently evaluating open alternatives, such as [Cloud Optimized GeoTIFFs](https://cogeo.org/), while ensuring that the conversion process preserves full visual fidelity. Future iterations will also explore the integration of multispectral data.

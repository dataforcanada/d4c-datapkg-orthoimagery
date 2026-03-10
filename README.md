# d4c-datapkg-orthoimagery

Look through our [d4c-datapkg-orthoimagery](https://github.com/dataforcanada/d4c-datapkg-orthoimagery) repo for the datasets that are currently being processed and datasets being acquired.

## Development Environment

Although we prioritize open-source tools, we currently use [MapTiler Engine Pro](https://www.maptiler.com/engine/pricing) because it outperforms available open-source alternatives for this specific workflow.

## Specifications of Tile Packages

The specifications for the tile packages are defined in this code.

```bash
#!/bin/bash
PROJECT_DIR="~/Documents/Personal/Projects/dataforcanada/d4c-datapkg-orthoimagery"
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

| Place | ISO | Year | Provider | Dataset ID & Preview | PMTiles |
| --- | --- | --- | --- | --- | --- |
| Canada | CA | 2025 | Versatiles | [ca_versatiles-2021A000011124_d4c-datapkg-orthoimagery_2025-08-10](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca_versatiles-2021A000011124_d4c-datapkg-orthoimagery_2025-08-10.pmtiles) | [Download](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca_versatiles-2021A000011124_d4c-datapkg-orthoimagery_2025-08-10.pmtiles) |
| Canada | CA | 2020 | NRCan | [ca_nrcan-2021A000011124_d4c-datapkg-orthoimagery_2020_30m_v0.1.0-beta](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca_nrcan-2021A000011124_d4c-datapkg-orthoimagery_2020_30m_v0.1.0-beta.pmtiles) | [Download](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca_nrcan-2021A000011124_d4c-datapkg-orthoimagery_2020_30m_v0.1.0-beta.pmtiles) |
| Edmonton | CA-AB | 2023 | Edmonton | [ca-ab_edmonton-2023A00054811061_d4c-datapkg-orthoimagery_2023_075mm_v0.1.0-beta](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-ab_edmonton-2023A00054811061_d4c-datapkg-orthoimagery_2023_075mm_v0.1.0-beta.pmtiles) | [Download](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-ab_edmonton-2023A00054811061_d4c-datapkg-orthoimagery_2023_075mm_v0.1.0-beta.pmtiles) |
| Red Deer | CA-AB | 2024 | Red Deer | [ca-ab_red-deer-2024A00054808011_d4c-datapkg-orthoimagery_2024_075mm_v0.1.0-beta](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-ab_red-deer-2024A00054808011_d4c-datapkg-orthoimagery_2024_075mm_v0.1.0-beta.pmtiles) | [Download](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-ab_red-deer-2024A00054808011_d4c-datapkg-orthoimagery_2024_075mm_v0.1.0-beta.pmtiles) |
| Red Deer | CA-AB | 2025 | Red Deer | [ca-ab_red-deer-2025A00054808011_d4c-datapkg-orthoimagery_2025_075mm_v0.1.0-beta](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-ab_red-deer-2025A00054808011_d4c-datapkg-orthoimagery_2025_075mm_v0.1.0-beta.pmtiles) | [Download](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-ab_red-deer-2025A00054808011_d4c-datapkg-orthoimagery_2025_075mm_v0.1.0-beta.pmtiles) |
| Burnaby | CA-BC | 2020 | Burnaby | [ca-bc_burnaby-2020A00055915025_d4c-datapkg-orthoimagery_2020_075mm_v0.1.0-beta](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-bc_burnaby-2020A00055915025_d4c-datapkg-orthoimagery_2020_075mm_v0.1.0-beta.pmtiles) | [Download](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-bc_burnaby-2020A00055915025_d4c-datapkg-orthoimagery_2020_075mm_v0.1.0-beta.pmtiles) |
| Vancouver | CA-BC | 2022 | Vancouver | [ca-bc_vancouver-2022A00055915022_d4c-datapkg-orthoimagery_2022_075mm_v0.1.0-beta](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-bc_vancouver-2022A00055915022_d4c-datapkg-orthoimagery_2022_075mm_v0.1.0-beta.pmtiles) | [Download](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-bc_vancouver-2022A00055915022_d4c-datapkg-orthoimagery_2022_075mm_v0.1.0-beta.pmtiles) |
| Winnipeg | CA-MB | 2024 | Winnipeg | [ca-mb_winnipeg-2024A00054611040_d4c-datapkg-orthoimagery_2024_075mm_v0.1.0-beta](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-mb_winnipeg-2024A00054611040_d4c-datapkg-orthoimagery_2024_075mm_v0.1.0-beta.pmtiles) | [Download](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-mb_winnipeg-2024A00054611040_d4c-datapkg-orthoimagery_2024_075mm_v0.1.0-beta.pmtiles) |
| Whitehorse | CA-YT | 2019 | Whitehorse | [ca-yt_whitehorse-2019A000556001009_d4c-datapkg-orthoimagery_2019_200mm_v0.1.0-beta](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-yt_whitehorse-2019A000556001009_d4c-datapkg-orthoimagery_2019_200mm_v0.1.0-beta.pmtiles) | [Download](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-yt_whitehorse-2019A000556001009_d4c-datapkg-orthoimagery_2019_200mm_v0.1.0-beta.pmtiles) |
| Ontario | CA-ON | 2024 | Province of Ontario | [ca-on_province_of_ontario-2024A000235_drape_eastern_ontario_orthoimagery_2024_16cm_v0.1.0-beta](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-on_province_of_ontario-2024A000235_drape_eastern_ontario_orthoimagery_2024_16cm_v0.1.0-beta.pmtiles) | [Download](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/processed/ca-on_province_of_ontario-2024A000235_drape_eastern_ontario_orthoimagery_2024_16cm_v0.1.0-beta.pmtiles) |
| Quebec | CA-QC | Multiple Years | Government and Municipalities of Quebec | [ca-qc_government_and_municipalities_of_quebec-2026A000224_d4c-datapkg-orthoimagery_orthorectified_imagery_from_quebec](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/archive/ca-qc_government_and_municipalities_of_quebec-2026A000224_d4c-datapkg-orthoimagery_orthorectified_imagery_from_quebec) | [Coming Soon](https://source.coop/dataforcanada/d4c-datapkg-orthoimagery/archive/ca-qc_government_and_municipalities_of_quebec-2026A000224_d4c-datapkg-orthoimagery_orthorectified_imagery_from_quebec) |

## The Plan

The objective is to standardize the source datasets used by Data for Canada processes. For instance, Vancouver’s orthoimagery is currently distributed in proprietary formats (MrSID and ECW) that require specialized drivers. We are currently evaluating open alternatives, such as [Cloud Optimized GeoTIFFs](https://cogeo.org/), while ensuring that the conversion process preserves full visual fidelity. Future iterations will also explore the integration of multispectral data.

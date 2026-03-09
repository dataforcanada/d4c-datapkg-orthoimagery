# Vancouver 2022 Orthoimagery — Download Script

This directory contains the automation script for acquiring the **City of Vancouver 2022 Orthophoto Imagery** dataset (7.5 cm resolution) from [Vancouver Open Data](https://opendata.vancouver.ca/explore/dataset/orthophoto-imagery-2022/).

## What the Script Does

`download.sh` performs four sequential steps:

1. **Download Index** — Uses `aria2c` to fetch the dataset catalogue as a Parquet file from the Vancouver Open Data API.
2. **Extract URLs** — Queries the Parquet file with `duckdb` to extract all MrSID image URLs into a plain-text file suitable for batch downloading.
3. **Create Output Directory** — Ensures the data input directory exists at `../../data/input/ca-bc_vancouver-2022A00055915022_d4c-datapkg-orthoimagery_2022_075mm/` (relative to this script).
4. **Download Images** — Uses `aria2c` to download all images in parallel (12 concurrent connections, 4 connections per server) into the data input directory.

## Dependencies

The following command-line tools must be installed and available on your `PATH`:

| Tool | Purpose | Install |
|---|---|---|
| [aria2c](https://aria2.github.io/) | High-speed parallel downloads | `sudo apt install aria2` |
| [duckdb](https://duckdb.org/) | Query Parquet files from the CLI | [Install guide](https://duckdb.org/docs/installation/) |

## Usage

```bash
cd scripts/ca-bc_vancouver-2022A00055915022_d4c-datapkg-orthoimagery_2022_075mm
bash download.sh
```

The script will print progress for each step. Once complete, the downloaded MrSID image files will be located in:

```
data/input/ca-bc_vancouver-2022A00055915022_d4c-datapkg-orthoimagery_2022_075mm/
```

rclone copy googledrive:"Orthophoto Repository 2023" \
    sourcecoop:us-west-2.opendata.source.coop/dataforcanada/d4c-datapkg-orthoimagery/archive/ca-ab_edmonton-2023A00054811061_orthoimagery_2023_075mm \
    --include "*.tif" --include "*.tfw" --include "*.tif.aux.xml" \
    --drive-shared-with-me --progress \
    --transfers 16 --checkers 16
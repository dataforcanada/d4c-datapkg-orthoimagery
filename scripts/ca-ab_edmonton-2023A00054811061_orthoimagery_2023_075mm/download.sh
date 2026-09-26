rclone copy googledrive:"Orthophoto Repository 2023" \
    . \
    --include "*.tif" --include "*.tfw" --include "*.tif.aux.xml" \
    --drive-shared-with-me --progress \
    --transfers 16 --checkers 16
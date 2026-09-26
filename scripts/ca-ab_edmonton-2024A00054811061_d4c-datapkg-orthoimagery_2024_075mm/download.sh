rclone copy googledrive:"Orthophoto Repository 2024" \
    . \
    --include "*.tif" --include "*.tfw" --include "*.tif.aux.xml" \
    --drive-shared-with-me --progress \
    --transfers 24 --checkers 48
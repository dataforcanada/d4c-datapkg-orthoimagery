rclone copy googledrive:"Orthophoto Repository 2021" \
    . \
    --include "*.tif" --include "*.tfw" --include "*.xml" \
    --drive-shared-with-me --progress \
    --transfers 16 --checkers 16
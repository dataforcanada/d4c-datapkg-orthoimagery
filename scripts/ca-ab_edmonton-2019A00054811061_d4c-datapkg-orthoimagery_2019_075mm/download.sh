rclone copy googledrive:"MrSID 2019" \
    . \
    --include "*.sid" --include "*.sdw" --include "*.xml" \
    --drive-shared-with-me --progress \
    --transfers 16 --checkers 16
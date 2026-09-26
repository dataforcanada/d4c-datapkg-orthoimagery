rclone copy googledrive:"MrSID 2017" \
    . \
    --include "*.sid" --include "*.sdw" --include "*.txt" \
    --drive-shared-with-me --progress \
    --transfers 16 --checkers 16

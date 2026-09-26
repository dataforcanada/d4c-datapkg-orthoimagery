# You need to setup Google Drive via rclone at https://rclone.org/drive/
# Click on the "ORTHOPHOTO REPOSITORY" button on the Edmonton data portal and it will become available on your Google Drive
rclone copy googledrive:"MrSID 2015" \
    . \
    --include "*.sid" --include "*.sdw" --include "*.txt" \
    --drive-shared-with-me --progress \
    --transfers 16 --checkers 16
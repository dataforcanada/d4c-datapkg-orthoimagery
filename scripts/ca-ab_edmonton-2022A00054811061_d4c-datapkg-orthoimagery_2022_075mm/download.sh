rclone copy googledrive:"Orthophoto Repository 2022" \
    . \
    --drive-shared-with-me --progress \
    --filter "+ /*.{tif,tfw,xml}" \
    --filter "- *" \
    --transfers 32 --checkers 64
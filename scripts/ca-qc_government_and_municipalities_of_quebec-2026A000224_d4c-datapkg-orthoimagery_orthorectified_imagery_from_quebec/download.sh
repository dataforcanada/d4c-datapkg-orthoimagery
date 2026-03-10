DATASET_ID="ca-qc_government_and_municipalities_of_quebec-2026A000224_d4c-datapkg-orthoimagery_orthorectified_imagery_from_quebec"

# Download tile index of data
#aria2c https://diffusion.mern.gouv.qc.ca/diffusion/RGQ/Imagerie/Orthomosaique/_Index/Index_Imagerie_orthorectifiee_GPKG.zip
## Extract ZIP file
#unzip Index_Imagerie_orthorectifiee_GPKG.zip
#
#mv Index_Imagerie_orthorectifiee.gpkg "${DATASET_ID}_2026-03-10.gpkg"

# Convert the GeoPackage to urls.txt
ogr2ogr -f CSV /vsistdout/ "${DATASET_ID}_2026-03-10.gpkg" \
  -sql "SELECT TELECHARGEMENT_FICHIER FROM Index_Orthomosaique
        UNION ALL
        SELECT TELECHARGEMENT_FICHIER FROM Index_Orthophotographie" \
  | tail -n +2 > "${DATASET_ID}_2026-03-10.txt"

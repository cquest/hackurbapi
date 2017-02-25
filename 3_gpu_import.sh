dropdb gpu
createdb gpu
export SHAPE_ENCODING=ISO8859-1

cd gpu_data

for f in HABILLAGE_LIN HABILLAGE_PCT HABILLAGE_SURF HABILLAGE_TXT INFO_LIN INFO_SURF PRESCRIPTION_LIN PRESCRIPTION_PCT  PRESCRIPTION_SURF ZONE_URBA ; do
for s in */*/*$f*.tab; do
   ogr2ogr temp.shp $s
   ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" temp.shp -nln "gpu_$f" -update -append
   rm -f temp.*
done
for s in */*/*$f*.TAB; do
   ogr2ogr temp.shp $s
   ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" temp.shp -nln "gpu_$f" -update -append
   rm -f temp.*
done
done


# import des PLU
for f in HABILLAGE_LIN HABILLAGE_PCT HABILLAGE_SURF HABILLAGE_TXT INFO_LIN INFO_SURF info_surf Info_surf PRESCRIPTION_LIN prescription_lin Prescription_LIN PRESCRIPTION_PCT prescription_pct Prescription_PCT PRESCRIPTION_SURF prescription_surf Prescription_SURF SECTEUR_CC ZONE_URBA Zone_urba zone_urba ; do
for s in */*/*$f*.shp; do
   ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" $s -nln "gpu_$f" -update -append
done
for s in */*/*$f*.SHP; do
   ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" $s -nln "gpu_$f" -update -append
done
done

for s in */*/*INFORMATION_LIN*.shp; do
   ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" $s -nln "gpu_info_lin" -update -append
done
for s in */*/*INFORMATION_SURF*.shp; do
   ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" $s -nln "gpu_info_surf" -update -append
done
for s in */*/*PRESCRIPTION_POINT*.shp; do
   ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" $s -nln "gpu_prescription_pct" -update -append
done

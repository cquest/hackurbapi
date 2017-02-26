#! /bin/bash

dropdb gpu
createdb gpu
psql gpu -c "CREATE EXTENSION postgis;"

export SHAPE_ENCODING=ISO8859-1
pgoptions=" -nlt geometry -t_srs EPSG:4326"
shopt -s nocaseglob

cd gpu_data

for f in HABILLAGE_LIN HABILLAGE_PCT HABILLAGE_SURF HABILLAGE_TXT INFO_LIN INFO_SURF PRESCRIPTION_LIN PRESCRIPTION_PCT  PRESCRIPTION_SURF ZONE_URBA ; do
t=$(echo $f |sed 's!_LIN!!;s!_PCT!!;s!_SURF!!')
for s in */*/*$f*.tab; do
   ogr2ogr temp.shp $s
   ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" temp.shp -nln "gpu_$t" -update -append $pgoptions
   rm -f temp.*
done
done


# import des PLU
for f in HABILLAGE_LIN HABILLAGE_PCT HABILLAGE_SURF HABILLAGE_TXT INFO_LIN INFO_SURF PRESCRIPTION_LIN PRESCRIPTION_PCT PRESCRIPTION_SURF SECTEUR_CC ZONE_URBA ; do
t=$(echo $f |sed 's!_LIN!!;s!_PCT!!;s!_SURF!!')
for s in */*/*$f*.shp; do
   ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" $s -nln "gpu_$t" -update -append $pgoptions
done
done

for s in */*/*INFORMATION_LIN*.shp; do
   ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" $s -nln "gpu_info" -update -append $pgoptions
done
for s in */*/*INFORMATION_SURF*.shp; do
   ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" $s -nln "gpu_info" -update -append $pgoptions
done
for s in */*/*PRESCRIPTION_POINT*.shp; do
   ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" $s -nln "gpu_prescription" -update -append $pgoptions
done

#! /bin/bash

dropdb gpu
createdb gpu
psql gpu -c "
CREATE EXTENSION postgis;
SET default_tablespace = ssd;
"

unset SHAPE_ENCODING
pgoptions=" -nlt geometry -t_srs EPSG:4326"
shopt -s nocaseglob

cd gpu_data

# import des shapefile
for f in HABILLAGE_LIN HABILLAGE_PCT HABILLAGE_SURF HABILLAGE_TXT INFO_LIN INFO_SURF PRESCRIPTION_LIN PRESCRIPTION_PCT PRESCRIPTION_SURF SECTEUR_CC ZONE_URBA ; do
t=$(echo $f |sed 's!_LIN!!;s!_PCT!!;s!_SURF!!')
for s in */*/*$f*.shp; do
  ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" $s -nln "gpu_$t" -update -append $pgoptions
  if [[ $? -ne 0 ]]
  then
    echo $s
    export SHAPE_ENCODING=ISO8859-1
    ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" $s -nln "gpu_$t" -update -append $pgoptions
    unset SHAPE_ENCODING
  fi
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

# import des fichier MapInfo
for f in HABILLAGE_LIN HABILLAGE_PCT HABILLAGE_SURF HABILLAGE_TXT INFO_LIN INFO_SURF PRESCRIPTION_LIN PRESCRIPTION_PCT  PRESCRIPTION_SURF ZONE_URBA ; do
t=$(echo $f |sed 's!_LIN!!;s!_PCT!!;s!_SURF!!')
for s in */*/*$f*.tab; do
   echo $s
   ogr2ogr temp.shp $s
   ogr2ogr -f "PostgreSQL" PG:"dbname=gpu" temp.shp -nln "gpu_$t" -update -append $pgoptions
   if [[ $? -ne 0 ]]
   then
     echo $s
   fi
   rm -f temp.*
done
done


# création des vues pour simplification de l'API
psql gpu -c "
create or replace view gpu_prescription_json as select json_build_object('type','Feature','properties',json_build_object('layer','prescription','libelle',libelle,'txt',txt,'typepsc',typepsc,'nomfic',nomfic,'urlfic',urlfic,'insee',insee,'datappro',datappro,'datvalid',datvalid),'geometry',st_asgeojson(wkb_geometry,6)::json)::text as geojson ,*, 'prescription'::text as layer from gpu_prescription ;

create or replace view gpu_zone_urba_json as select json_build_object('type','Feature','properties',json_build_object('layer','zone_urba','libelle',libelle,'libelon',libelong,'typezone',typezone,'destdomi',destdomi,'nomfic',nomfic,'urlfic',urlfic,'insee',insee,'datappro',datappro,'datvalid',datvalid),'geometry',st_asgeojson(wkb_geometry,6)::json)::text as geojson ,*,'zone_urba'::text as layer from gpu_zone_urba ;

create or replace view gpu_info_json as select json_build_object('type','Feature','properties',json_build_object('layer','info','libelle',libelle,'txt',txt,'typeinf',typeinf,'nomfic',nomfic,'urlfic',urlfic,'insee',insee),'geometry',st_asgeojson(wkb_geometry,6)::json)::text as geojson ,*, 'info'::text as layer from gpu_info ;

create or replace view gpu_secteur_cc_json as select json_build_object('type','Feature','properties',json_build_object('layer','secteur_cc','idurba',idurba,'libelle',libelle,'typesect',typesect,'fermreco',fermreco,'destdomi',destdomi,'nomfic',nomfic,'urlfic',urlfic,'insee',insee,'datappro',datappro,'datvalid',datvalid,'libelong',libelong),'geometry',st_asgeojson(wkb_geometry,6)::json)::text as geojson ,*,'secteur_cc'::text as layer from gpu_secteur_cc ;

create view gpu_all as select layer,insee,wkb_geometry,geojson from gpu_prescription_json union select layer,insee,wkb_geometry,geojson from gpu_info_json union select layer,insee,wkb_geometry,geojson from gpu_zone_urba_json union select layer,insee,wkb_geometry,geojson from gpu_secteur_cc_json ;
"

# création des index pour recherche sur code INSEE
psql gpu -c "
create index gpu_info_insee on gpu_info (insee);
create index gpu_prescription_insee on gpu_prescription (insee);
create index gpu_secteur_cc_insee on gpu_secteur_cc (insee);
create index gpu_zone_urba_insee on gpu_zone_urba (insee);
"

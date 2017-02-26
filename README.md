# HackUrbAPI

## Scripts de récupération des données

3 scripts permettent de récupérer les données:
- 1_gpu_scrap.sh : permet d'obtenir la liste des communes ayant un PLU/POS/CC
- 2_gpu_download.sh : télécharge les fichiers ZIP en ne conservant que les données géographiques
- 3_gpu_import.sh : importe et agrège les données géographiques dans une base Postgresql/postgis

A la fin de l'import postgresql, 5 vues sont créées pour simplifier l'accès par l'API.
4 vues servent à générer une version geojson des données, une cinquième regroupe ces 4 vues pour une interrogation globale.

## API légère

Il s'agit d'un petit script python utilisant falcon pour implémenter l'API.

Un seul endpoint est disponible pour obtenir l'ensemble des objets à proximité d'un position lat/lon donnée.

**GET /gpu**
- **lat** : latitude en WGS84
- **lon**: longitude en WGS84
- **dist** (optionnel): distance en mètres pour la proximité (100m par défaut)

Retourne une Featurecollection geojson.

Les champs initiaux sont retournés pour chaque objet, ainsi qu'un champ "layer" contenant le type de couche (info, prescription, secteur_cc ou zone_urba)

## API de démo

Une version démo est disponible pour test sur: http://urbapi.cquest.ogr2ogr

Exemple: http://urbapi.cquest.org/gpu?lon=6.2131&lat=45.8836

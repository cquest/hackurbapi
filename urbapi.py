#! /usr/bin/python3
import falcon
import psycopg2
import requests
import json

class GpuResource(object):
    def getGpu(self, req, resp):
        db = psycopg2.connect("dbname=gpu")
        cur = db.cursor()

        adresse = req.params.get('adresse',None)
        if adresse is not None:
            r = requests.get('http://api-adresse.data.gouv.fr/search', params={"q":adresse, "autocomplete":0, "limit":1})
            geo = json.loads(r.text)
            lon = geo['features'][0]['geometry']['coordinates'][0]
            lat = geo['features'][0]['geometry']['coordinates'][1]
        else:
            lat = float(req.params.get('lat',45.8836))
            lon = float(req.params.get('lon',6.2131))
        dist = float(req.params.get('dist',100))
        insee = req.params.get('insee',None)
        layer = req.params.get('layer',None)

        where = ''
        if insee is not None:
            where = cur.mogrify(' AND insee=%s',(insee,))
        else:
            where = cur.mogrify(' AND ST_Intersects(wkb_geometry, ST_Buffer(ST_MakePoint(%s,%s)::geography, %s)::geometry)',(lon,lat,dist))
        if layer is not None:
            where = where + cur.mogrify(' AND layer=%s ',(layer,))

        query = """SELECT json_build_object('type','FeatureCollection','features',array_agg(geojson::json))::text
            FROM gpu_all
            WHERE true """+where.decode('utf8')
        cur.execute(query)

        gpu = cur.fetchone()

        resp.status = falcon.HTTP_200
        resp.set_header('X-Powered-By', 'HackUrbAPI')
        resp.set_header('Access-Control-Allow-Origin', '*')
        resp.set_header("Access-Control-Expose-Headers","Access-Control-Allow-Origin")
        resp.set_header('Access-Control-Allow-Headers','Origin, X-Requested-With, Content-Type, Accept')
        resp.body = (gpu[0])
        db.close()

    def on_get(self, req, resp):
        self.getGpu(req, resp);

# falcon.API instances are callable WSGI apps
app = falcon.API()

# Resources are represented by long-lived class instances
gpu = GpuResource()
# things will handle all requests to the matching URL path
app.add_route('/gpu', gpu)

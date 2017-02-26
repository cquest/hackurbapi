#! /usr/bin/python3
import falcon
import psycopg2

class GpuResource(object):
    def getGpu(self, req, resp):
        db = psycopg2.connect("dbname=gpu")
        cur = db.cursor()

        insee = req.params.get('insee',None)
        lat = float(req.params.get('lat',45.8836))
        lon = float(req.params.get('lon',6.2131))
        dist = float(req.params.get('dist',100))

        where = ''
        if insee is not None:
            where = cur.mogrify(' AND insee=%s',(insee,))
        else:
            where = cur.mogrify(' AND ST_Intersects(wkb_geometry, ST_Buffer(ST_MakePoint(%s,%s)::geography, %s)::geometry)',(lon,lat,dist))

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

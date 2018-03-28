---
title: Calculating distances between swedish municipalities
date: '2013-09-24 16:15:37 +0200'
mt_id: 2171
categories:
- projects
- technology
---
I was recently tasked with creating a table of the shortest physical distances between all municipalities in Sweden. While I do live in Scandinavia, I must admit my knowledge about swedish geography fails me here.

So I - naturally - turned to programming.


<!--more-->


## Stand back, I'm using PostGIS!

For this exercise, I used:

* PostgreSQL 9.1.9
* PostGIS 1.5.8
* Data from [OpenStreetMap](http://www.openstreetmap.org)

Check out my [instructions for getting PostGIS running on OS X](https://mentalized.net/journal/2013/04/05/how-to-install-postgis-on-mountain-lion/).

## OpenStreetMap

Lucky for us, OpenStreetMap has an [impressive collection of geographical data on Sweden](http://wiki.openstreetmap.org/wiki/WikiProject_Sweden).

Even better; it is available as [easily downloadable, always updated packages](http://download.geofabrik.de/europe/sweden.html), courtesy of [GeoFabrik](http://geofabrik.de).

I recommend grabbing the [latest PBF-formatted file](http://download.geofabrik.de/europe/sweden-latest.osm.pbf), which we can then import into PostgreSQL.

## Import into PostgreSQL

Importing an OSM PBF file into PostGIS is remarkably easy - once you know how to do it.

I've chosen to use [Osmosis](http://wiki.openstreetmap.org/wiki/Osmosis) and after [installing it](http://wiki.openstreetmap.org/wiki/Osmosis/Installation), the entire process looks roughly like (creating a database named osm):

``` console
# Setting up the geo-spatial database
createdb osm
createlang plpgsql osm
psql -d osm -c "CREATE EXTENSION hstore;"
psql -d osm -f $POSTGRES_PATH/contrib/postgis-1.5/postgis.sql
psql -d osm -f $POSTGRES_PATH/contrib/postgis-1.5/spatial_ref_sys.sql
psql -d osm -f $OSMOSIS_PATH/script/pgsnapshot_schema_0.6.sql
psql -d osm -f $OSMOSIS_PATH/script/pgsnapshot_load_0.6.sql
psql -d osm -f $OSMOSIS_PATH/script/pgsnapshot_schema_0.6_action.sql
psql -d osm -f $OSMOSIS_PATH/script/pgsnapshot_schema_0.6_bbox.sql
psql -d osm -f $OSMOSIS_PATH/script/pgsnapshot_schema_0.6_linestring.sql
```

(I can't help but think there must be some easy-to-use, prepackaged script for this, but I didn't find one).

All of that, so we can actually import the data:

``` console
osmosis --read-pbf file=sweden-latest.osm.pbf --write-pgsql database=osm
```

Now, go grab a cup of coffee. And drink it. And go brew another cup. Actually, go buy a new coffee machine. And perhaps start a coffee farm. In other words, it takes a while.

## Getting the municipalities

Now the import of the raw data is done and you've made a solid career as a coffee-farmer, let's verify that we actually got the data we expected.

OpenStreetMap saves the municipalities as administrative relations with names ending with " kommun":

``` sql
osm=# select count(*) from relations where tags->'boundary'='administrative' AND tags->'name' LIKE '% kommun';
 count
-------
   290
(1 row)
```

Luckily, 290 is exactly how many municipalities [Wikipedia claims Sweden has](http://en.wikipedia.org/wiki/Municipalities_of_Sweden). Bingo.

## The distance between two municipalities

To calculate the shortest distance between two polygons, PostGIS comes with the aptly named [`ST_Distance`](http://postgis.refractions.net/docs/ST_Distance.html) function (and a bunch of others, that a geo-noob like me doesn't understand).

The problem now is `ST_Distance` needs a full polygon for this. In OpenStreetMap each municipality is a "relation" and each "relation" has a bunch of lines called "ways" making up its outer polygon.

We need to merge all those lines into a polygon we can use.

## Enter ST_Union

Using [`ST_Union`](http://postgis.refractions.net/documentation/manual-2.0/ST_Union.html) we can merge line strings together. For example, combining all the lines making up Ale municipality:

``` sql
SELECT ST_Union(linestring)
FROM relations, relation_members, ways
WHERE relations.tags->'name' = 'Ale kommun'
  AND relations.id=relation_id
  AND member_id=ways.id
GROUP BY relation_id;
```

We can use all of the above to create a table with the geometries for every municipality in Sweden:

``` sql
SELECT relations.tags->'name' AS name, ST_Union(linestring) AS polygon
INTO municipalities
FROM relations, relation_members, ways
WHERE relations.id=relation_id
  AND member_id=ways.id
  AND relations.tags->'boundary'='administrative'
  AND relations.tags->'name' LIKE '% kommun'
GROUP BY relations.tags->'name';
```

## Once again, the distance between two municipalities

With that in place, we can find the distance between two municipalities:

``` sql
SELECT ST_Distance(
  (SELECT polygon FROM municipalities WHERE name='Jönköpings kommun'),
  (SELECT polygon FROM municipalities WHERE name='Halmstads kommun'),
  true);
   st_distance
------------------
 81165.4329007982
```

That last `true` is important as it makes `ST_Distance` give us the result in understandable meters. In other words, there is roughly 81 km between Ale and Jönköping municipalities. Now I know that.

## Cartesian product FTW

Phew, finally, the last piece of the puzzle: Actually building the resulting table of all the distances.

Time to make one of those cartesian products queries that your DBAs always scolds you for:

``` sql
SELECT source.name source_name,
       destination.name destination_name,
       ST_Distance(source.polygon, destination.polygon, true)
FROM municipalities source,
     municipalities destination;
```

This could clearly be optimized (it calculates the distance between each municipality twice (one for each direction)), but you could just run it and make sure to store the output somewhere (perhaps [in CSV format](https://mentalized.net/journal/2011/11/07/how-to-export-csv-data-from-postgresql/).

Oh, and that coffee-farm of yours; I'd get right back to that if I was you. The above takes a long time to run.

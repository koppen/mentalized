---
title: Import GPX data to PostGIS
date: '2013-04-07 14:45:46 +0200'
mt_id: 2163
categories:
- technology
- software
---
Here's how I imported geo data from a bunch of files containing GPS traces in [GPX format](http://en.wikipedia.org/wiki/GPS_eXchange_Format) into a [PostGIS](http://postgis.net/) database for further analysis.

<!--more-->

## Assumptions

* OS X Mountain Lion
* MacPorts
* PostgreSQL 9.1

## Install PostGIS

Golly, I recently wrote [a tutorial how to install PostGIS](http://mentalized.net/journal/2013/04/05/how_to_install_postgis_on_mountain_lion/) - what a coincidence.

## Install GDAL

[GDAL](http://www.gdal.org/) is a <q>"translator library for raster geospatial data formats"</q>.  The important part is that it comes with a commandline tool to convert from one format to another, named [ogr2ogr](http://www.gdal.org/ogr2ogr.html). We want that:

    $ sudo port install gdal +postgresql91

Check that it works:

    $ ogr2ogr --long-usage | grep PostgreSQL
    -f "PostgreSQL"

## Import data to PostgreSQL

Importing a single file using ogr2ogr is simple (and doesn't require the `+postgresql` variant above):

    $ ogr2ogr -append -f PGDump /vsistdout/ gpx.jsp\?relation\=1076755 | psql DATABASE_NAME

Using find we can easily do it for multiple GPX files:

    $ find . -name \*.gpx -exec ogr2ogr -append -f PostgreSQL "PG:dbname=DATABASE_NAME" {} \;

## See if it worked

The following should return the number of files you've imported (I think - at least in my case it fit):

    $ psql -d geo -c "SELECT COUNT(*) FROM routes"
     count
    -------
       289
    (1 row)

Happy geo-analysis!

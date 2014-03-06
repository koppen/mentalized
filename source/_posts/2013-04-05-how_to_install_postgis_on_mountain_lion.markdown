---
layout: post
title: How to install PostGIS on Mountain Lion
date: '2013-04-05 10:14:44 +0200'
mt_id: 2162
categories:
- software
- technology
---
I recently needed to run some geographical analysis and [PostGIS](http://postgis.refractions.net/) seemed like a perfect fit for this. So off I went to install it, here's how.

<!--more-->

## Assumptions

* OS X Mountain Lion
* PostgreSQL 9 installed via MacPorts

## Step 0: Install PostgreSQL

If you don't have [PostgreSQL](http://www.postgresql.org) already installed, it should be a simple matter of getting it via [MacPorts](http://www.macports.org/):

    $ port install postgresql91 postgresql91-server

Also, I am sure there are tons of tutorials out there to help with this, so I won't cover that here.

## Install PostGIS 1.5

Simple enough:

    $ port install postgis

Note that there is a PostGIS 2.0 out there, but it requires PostgreSQL 9.2 and I wasn't ready for upgrading just yet.

## Setup a geospatially enabled database

This part had me a bit stumped, and digging up the right file paths for this to work took a while:

    $ createdb geo
    $ createlang plpgsql geo
    $ psql -d geo -f /opt/local/share/postgresql91/contrib/postgis-1.5/postgis.sql
    $ psql -d geo -f /opt/local/share/postgresql91/contrib/postgis-1.5/spatial_ref_sys.sql

If you figure you need to routinely setup new databases like this, it might be an idea to create a database template to use in the future.

## Test that it worked

The following should output a ton (400+) of functions:

    $ psql geo -c "\df" | grep st_

If it did, you're good to go. If it didn't, good luck.

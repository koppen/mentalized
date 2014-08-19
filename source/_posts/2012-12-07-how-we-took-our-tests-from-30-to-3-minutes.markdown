---
title: How we took our tests from 30 to 3 minutes
date: '2012-12-07 07:59:35 +0100'
mt_id: 2155
categories:
- technology
- projects
- programming
---
One of my client projects have grown a fairly large test suite over the last years and it has become way unwieldy. Our original CI server took more than 30 painstakingly slow minutes to complete a test run.

While we are currently writing most our new tests in the [fast test style](http://www.confreaks.com/videos/641-gogaruco2011-fast-rails-tests), rewriting 20.000 lines of slow tests isn't something that'll be done in the near future.

So we needed to do something differently that would work here and now.

## TL;DR

* An irresponsible database and more hardware

<!--more-->

## Throw hardware at it

For starters, we rented a dedicated server. Yes, not a cloud thingy, but geniune physical hardware that we could call our own. Surely, 2 quadcore CPUs, 7200 RPM disks, and 16GB of RAM is going to make our test suite scream, right?

Wrong.

Running the test suite on the new server proved only a few minutes quicker than on the tired, old VPS of yore. Disappointing.

## Parallelize

The mediocre result seemed to suggest that we were CPU bound. Luckily, with 8 cores in the server, that would be easy to solve.

Enter the [parallel](https://github.com/grosser/parallel) gem and with almost no other changes our specs would run on all cores on the machine shaving almost 50% off the run time.

Better, but still disappointing. I expected going from 1 to 8 cores to prove more than a 100% performance increase. Next up, tuning the database.

## PostgreSQL, I'm looking at you

PostgreSQL is a great database. Fast, reliable, always making sure your data is correct and consistent. All great features of a database running in production.

However, for testing, we don't care about our data - it's throwaway junk generated from fixtures and factories anyways.

Luckily PostgreSQL allows us to configure some of it's [durability](http://www.postgresql.org/docs/9.2/static/non-durability.html) away. We changed our postgresql.conf to include the following settings:

    checkpoint_segments = '9'
    checkpoint_timeout = '30min'
    fsync = 'off'
    full_page_writes = 'off'
    synchronous_commit = 'off'

Basically this disables/delays a bunch of safeguards that PostgreSQL has in place to ensure your data doesn't get corrupted in case of system crashes.

This was like putting Magic Boots of Blinding Speed on our test suite: 2 minutes and 49 seconds! Good riddance.

## What more could be done?

A couple of things I haven't gotten around to, but that could be interesting to see the results of:

* Running the server on a SSD. I seem to recall this having a huge effect on running the test suite locally, I'd expect it to at least do something on the server.
* Running PostgreSQL from a RAM disk. While my initial tests of this seemed to make no difference whatsoever, I am inclined to chalk that up to me doing something wrong.

Next up, making Jenkins build pull requests and notify us on Github.

---
title: Announcing Capistrano-Remote
layout: post
categories:
- programming
- projects
- technology
---

Ever needed to run some maintenance task in your production environment? For me
this usually triggers a bunch of questions: What's that hostname again? What
user should I log in as? And where did we deploy the application? Is RVM loaded
correctly? Do I need to bundle exec or whatever?

So [we](http://substancelab.com) built a [Capistrano
extension](https://rubygems.org/gems/capistrano-remote) to answer those
questions and ease the pain.

<!--more-->

With [Capistrano-Remote](https://rubygems.org/gems/capistrano-remote) launching
a Rails console in your production environment is as simple as

    $ cap production remote:console
    Loading production environment (Rails 4.2.4)
    irb(main):001:0>

There is even a

    $ cap production remote:dbconsole
    psql (9.3.5)
    SSL connection (cipher: DHE-RSA-AES256-SHA, bits: 256)
    Type "help" for help.

    example_production=>

## Getting started

Just follow the fairly simple installation and usage instructions at [substancelab/capistrano-remote](https://github.com/substancelab/capistrano-remote). Basically:

1. Add it to your `Gemfile`: `gem "capistrano-remote", :require => false`
2. `bundle install`
3. Add to your `Capfile`: `require "capistrano/remote"`

You should now be able to see both tasks in all their glory:

    $ cap -T remote
    cap remote:console    # Run and attach to a remote Rails console
    cap remote:dbconsole  # Run and attach to a remote Rails database console

## Backstory

If you need to work in your production environment for whatever reason, on the
surface the process isn't hard:

1. SSH to a server (which server? which user? And on AWS, this gets even more confusing, as we don't really know the actual hostnames)
2. cd to the deployment directory (what directory again?)
3. fire up `rails console production` (or was that `bundle exec`? How about rbenv?)

However, those steps (establishing an SSH connection and setting up the
environment to run Rails commands) are pretty much exactly what
[Capistrano](http://capistranorb.com/) excels at, so why not use that?

Think of it as `heroku run rails console` for those of us stuck on selfmanaged
nodes and Capistrano and grab it from [RubyGems](https://rubygems.org/gems/capistrano-remote).

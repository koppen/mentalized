---
title: Redmine plugins should be gems
categories:
- projects
---

[Redmine](http://www.redmine.org/) has a pretty good plugin mechanism. This has resulted in a [ton of plugins](https://www.redmine.org/plugins), most of which are still distributed like in the good old days:

1. Get the source from somewhere
2. Copy it to the plugins directory

Distributing your plugins as gems is a vastly better solution.

<!--more-->

## Simple installation

Two steps, which should be fairly familiar to anybody installing Redmine:

1. Add to `Gemfile.local`: `gem "gem-name"`
2. `bundle`

That’s it.

## Better versioning

With gems your plugins version becomes a first-class citizen. While versioning can be handled using branches/tags or specific downloaded packages in the old way of doing things, tracking master directly from the repository is the most common way.

## Dependency tracking

If your gem has dependencies on other libraries/gems, the gem spec is the perfect way to specify these. Properly configured, this will allow [Bundler](http://bundler.io/)/[RubyGems](https://rubygems.org/) to fetch the necessary dependencies when installing, making the installation even easier.

## Installation from source is still possible

Thanks to Bundler, you can still grab the plugin from the git source repository:

    gem "gem-name", :git => "git@github.com:koppen/redmine_github_hook.git"

… or a tag or a branch or any of the other [git options from Bundler](http://bundler.io/git.html).

## Just do it

So what are you waiting for? Go forth and distribute your Redmine plugins as gems.

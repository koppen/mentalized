---
layout: post
title: "SMACSS-style selectors in Sass"
date: '2015-05-15 09:05:32 +0100'
categories:
- programming
- technology
published: true
---
If you - like me - are a fan of keeping your stylesheets readable with [Sass](http://sass-lang.com) and structuring them following the guidelines from [SMACSS](http://smacss.com/), you should totally know about this little syntax gem:

<!--more-->

Sass compiles

    .foo
      &-bar
        color: red

to

    .foo-bar {
      color: red; }

SMACSS suggests that we favor single class-name selectors over the nested child selectors that are oh so easy to create using Sass. Using this ampersand-syntax we get selectors that are almost as easy to write - and especially to maintain.

## A bit about Rails compatibility

This was added to Sass at version [3.3.0](http://sass-lang.com/documentation/file.SASS_CHANGELOG.html#330_7_march_2014). Unfortunately the current version of [sass-rails](http://rubygems.org/gems/sass-rails) depends on Sass 3.2.x, so you won't get this out of the box on Rails.

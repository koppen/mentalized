---
title: "Ember on Rails: Relationships"
date: '2014-07-24 11:15:57 +0100'
categories:
- programming
- technology
published: false
series: "Ember on Rails"
---


<!--more-->

Books have authors.

$ rails generate resource Author name
$ rake db:migrate

This creates pretty much everything we need (Rails controller, model, routes, and migration and Ember model) and some things we don't.



We'll take a simplistic view and assume a book only ever has one author.




{% include ember_on_rails.html %}


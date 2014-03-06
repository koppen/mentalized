---
layout: post
title: Digging into Objective-C (again)
date: '2011-09-08 09:03:00 +0200'
mt_id: 2123
categories:
- programming
---
While the concept of writing native Mac apps in Ruby definitely appeals to me, I must say the experience isn't quite as easy as I was looking for.

After writing [my last post](http://mentalized.net/journal/2011/08/15/running_macruby_and_hotcocoa_on_snow_leopard/) I realized that what I had thought to be the path of least resistance, wasn't. And while I knew I'd run into resistance with XCode and Objective-C as well, at least I'd be doing things the "proper" way and learning new stuff.

So I fired up XCode once again and set out to write a Mac application. The following is a bunch of notes and stray thoughts I scribbled down during those first hours - my first (well, fourth) impressions of developing iApps coming from Ruby.


<!--more-->

## XCode

* Oh dear God, so many windows. I can see why Mac/iOS developers like to have multiple 30 inch screens.
* Inline error messages are kind of awesome.

## The language

* Oh yeah, I remember why I've tried figuring this out on more than one occasion.
* Oh no, semicolons.
* Is there something like [TryRuby](http://tryruby.org/) for Objective-C? I think it would be easier getting started not having to worry about XCode and Interface Builder and outlets and other blah.

## Interface Builder

* Not sure if I should hate it or love it.
* When I rename a file via Interface Builder why doesn't it change the import statements or other references. I thought this was what an IDE should be doing.
* Finding good, up to date introductory articles is hard, and it seems Interface Builder changes quite a bit between versions making it hard to transfer instructions from another version.

## Files and structure

* I miss something like Rails to force a structure on me. Where to I put this or that file? What's my main application file called? ApplicationDelegate? AppController? Where do I put other things, what should I name them? Arg, best practice me, please!
* Seriously, do all files simply go in the same directory?
* Using git with XCode isn't exactly a joy. Closing all files because git has changed them is annoying to say the least.

## Debugging output

* I miss a consistent, robust way to log debug output. `Object.to_s` and `.inspect` of Ruby are awesome. `NSLog()` isn't quite flexible enough, ie `NSLog(@"%@")` fails for certain types (integers).
* A visual debugger is nice, I remember that from my Delphi days.

## Installing frameworks

* Download, run something, then copy something into a project, then add build phases, then import it. Damn, I miss [gems](http://rubygems.org).

I am sure I'll laugh at the above as I get more experience. But this serves a nice reminder that starting anything new is a fragile situation and we should make sure newbies are welcomed and aided into our communities.

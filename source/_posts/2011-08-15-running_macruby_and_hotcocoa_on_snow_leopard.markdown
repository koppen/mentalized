---
title: Running MacRuby and HotCocoa on Snow Leopard
date: '2011-08-15 09:03:10 +0200'
mt_id: 2121
categories:
- technology
- programming
---
I spent some time over the weekend playing around with [MacRuby](http://macruby.org) and [HotCocoa](http://www.macruby.org/trac/wiki/HotCocoa), trying to put together a simple Mac application.

Getting MacRuby and HotCocoa running on Snow Leopard wasn't entirely as easy as it should have been, though. Here are some of the hoops I jumped through.


<!--more-->

## MacRuby via RVM

I like [RVM](http://rvm.beginrescueend.com) (go [Wayne](https://twitter.com/#!/wayneeseguin)!) so I installed MacRuby that way. Fortunately - for me - that was only a matter of

    rvm install macruby


## BridgeSupport via downloaded installer

Supposedly this is only necessary if you're still on Snow Leopard, but you need [BridgeSupport](http://bridgesupport.macosforge.org/trac/wiki).

You can grab it from [the MacRuby site](http://www.macruby.org/files/) - at the time of writing Preview 3 is the most recent version. After downloading it, unzip it and run the installer.


## HotCocoa via Bundler

[HotCocoa](http://www.macruby.org/trac/wiki/HotCocoa) is a Ruby-style interface to Cocoa, basically a way to create your user interface. Unfortunately, it seems the project is in a state of limbo and the official gem isn't the one you want.

There is an active fork on [GitHub](https://github.com/ferrous26/hotcocoa) that supports 64 bit architectures and actually works, so we want that.

After messing about with this for a while, struggling with making sure I got it installed as part of RVMs gems, not the system gems, and usable via `rake`, instead of `macrake` and what have you, I ended up using [Bundler](http://gembundler.com/) for bringing in the forked gem.

    # Gemfile
    gem 'rake'
    gem 'hotcocoa', :git => 'https://github.com/ferrous26/hotcocoa.git'

Note that rake is also added to the Gemfile. Without it I was getting a bunch of seemingly unrelated errors, but this worked in the end. Just remember to do

    bundle exec rake run

to run your application. Without it, you'll be running RVMs macrake and you didn't install the HotCocoa fork under that.

## App away

With the above out of the way, I was able to happily code my way to a working Mac app using Ruby. That is pretty sweet.

I've not been able to really get along with Objective-C yet, so I'm hoping MacRuby can be a gateway drug for me.

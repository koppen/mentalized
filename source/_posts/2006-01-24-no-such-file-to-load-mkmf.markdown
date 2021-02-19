---
layout: post
title: no such file to load -- mkmf
date: '2006-01-24 16:09:15 +0100'
mt_id: 1516
categories:
- programming
description: "If gem install fails for you on Debian with 'no such file to load -- mkmf (LoadError)' this could be the solution"
---
While checking out [Scott Baron](http://lunchroom.lunchboxsoftware.com/)'s coverage-tool for Ruby, [insurance](http://rubyforge.org/projects/insurance/), I ran into a minor issue on my - by now - fairly beat up Debian installation.

``` console
jcop@mental:~$ sudo gem install insurance
Attempting local installation of 'insurance'
Local gem file not found: insurance*.gem
Attempting remote installation of 'insurance'
Updating Gem source index for: http://gems.rubyforge.org
Building native extensions.  This could take a while...
extconf.rb:1:in `require': no such file to load -- mkmf (LoadError)
        from extconf.rb:1
```

Thankfully, Google led me to [the answer on RubyForge](http://rubyforge.org/forum/forum.php?thread_id=4161&forum_id=4050). For some reason, mkmf.rb is part of the ruby1.8-dev package, and initially I hadn't installed that since it is described as

> Header files for compiling extension modules for the Ruby 1.8

Ah well. A quick

``` console
sudo apt-get install ruby1.8-dev
```

and everything trotted along happily after that.

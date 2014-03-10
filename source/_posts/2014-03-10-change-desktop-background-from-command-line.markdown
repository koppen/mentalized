---
layout: post
title: "How to change desktop background from OS X command line"
date: '2014-03-10 11:11:49 +0100'
categories:
- programming
- technology
---

I have 2 displays and it annoys me that I have to change the desktop background of each display individually. I always want the same wallpaper image on both screens.

So I wrote a small Ruby script to set the same desktop background image on all connected displays.

<!-- more -->

## Usage

1. Place the script in your path somewhere.
2. Give it execution permissions: `chmod o+x [PATH TO SCRIPT]`
3. Make sure your default Ruby installation has the [rb-appscript gem](http://rubygems.org/gems/rb-appscript) installed: `gem install rb-appscript` (potentially prefix with `sudo`).

You should now be able to run the script. Simply give it a path to an image file - or the path to a folder, in which case the script picks a random image file from inside that:

{% highlight console %}
$ set_desktop ~/Pictures/DesktopImages
{% endhighlight %}

## Plays well with Desktoppr

I have set it up to set a random wallpaper image from my [Desktoppr](https://www.desktoppr.co/) folder when I arrive at work. This keeps my desktop background fresh and inspiring (nevermind the fact that I rarely actually see it).

## The script

{% highlight ruby %}
#!/usr/bin/env ruby
abort "Usage: #{__FILE__} [image]" if ARGV.empty?

require "appscript"

def desktops
  system_events.desktops
end

def get_wallpaper(path)
  if Dir.exists?(path)
    files = Dir.glob(File.join(path, "*.{png,jpg}"))
    files.sample
  else
    path
  end
end

def set_wallpaper(wallpaper_path)
  desktops.picture.set(wallpaper_path)
end

def system_events
  Appscript.app("System Events")
end

wallpaper_path = File.expand_path(ARGV.first)
wallpaper_path = get_wallpaper(wallpaper_path)
set_wallpaper(wallpaper_path)
{% endhighlight %}

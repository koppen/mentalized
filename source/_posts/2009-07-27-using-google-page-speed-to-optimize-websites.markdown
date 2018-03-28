---
title: Using Google Page Speed to optimize websites
date: '2009-07-27 11:02:44 +0200'
mt_id: 2002
categories:
- programming
- webdesign
- usability
- software
- projects
- browsers
---
Back when Yahoo! released their YSlow add-on for Firebug, [I took it for a spin](http://mentalized.net/journal/2007/07/26/using-yslow-to-optimize-websites/) and optimized [biq.dk](http://biq.dk) using it. 

Google recently released their variant of YSlow called [Page Speed](http://code.google.com/speed/page-speed/). Like YSlow, it's an add-on for Firebug and it provides a bunch of recommendations for optimizing the clientside performance of your websites. This time, I'll let it loose on the homepage of [Lokalebasen](http://www.lokalebasen.dk).

<!--more-->

## Significant performance improvements

### Leverage browser caching

> The following resources are missing a cache expiration. Resources that do not specify an expiration may not be cached by browsers. Specify an expiration at least one month in the future for resources that should be cached, and an expiration in the past for resources that should not be cached

Having browsers request static content on every page view is pretty pointless. A lot of content, like images, Javascripts and stylesheets, rarely change and can be cached for a long time.

Rails uses a nifty little trick, that makes clientside caching fairly safe. It puts the timestamp of each files last modification at the end of each asset request (that's why images in Rails applications are usually addressed as /images/foo.png?74734234). This means that the asset will get a new URL when it's changed, so we can cache it under the old URL for a long'ish time.

Using Apache and mod_expires we can simply add the following to our site configuration:

    <Directory /var/www/lokalebasen/production/current/public>
      ExpiresActive On
      ExpiresDefault "access plus 1 month"
    </Directory>

The public directory contains only cacheable contents, so we can set a blanket rule for the entire directory, and we'll just let the browser cache those assets for a full month.

> The following cacheable resources have a short freshness lifetime. Specify an expiration at least one month in the future for the following resources: http://www.google-analytics.com/ga.js

Google aint eating their own dogfood, it seems ;)


### Combine external JavaScript

> There are 8 JavaScript files served from www.lokalebasen.dk. They should be combined into as few files as possible.

We use jQuery with a bunch of plugins. The plugin architecture of jQuery works great, unfortunately, it makes for a lot of extra small JavaScript files, which in return makes for extra HTTP requests.

In most cases all those files can easily be combined into a single JavaScript so the browser only has to make one HTTP connection. Lokalebasen is a Rails application, and Rails has had this functionality built in since v2.0, it's a pretty easy fix. We just add :cache => true to our [javascript_include_tag](http://apidock.com/rails/ActionView/Helpers/AssetTagHelper/javascript_include_tag) and Rails handles the rest for us:

    <%= javascript_include_tag :defaults, 'jquery.patches', 'jquery.timers', 'jquery.scrollto', 'jquery.elastic', :cache => true %>

In production mode the files specified will be combined and cached into a single file, all.js:

    <script src="/javascripts/all.js?1243929207" type="text/javascript"></script>


### Parallelize downloads across hostnames

> This page makes 28 parallelizable requests to www.lokalebasen.dk. Increase download parallelization by distributing these requests across multiple hostnames:

By default, many browsers won't download more than two files at the same time from the same server, presumably to prevent users from overloading servers. In this day and age, however, bandwidth and server power is abundant enough that most sites can handle more than that.

One way of letting browsers establish more connections is to serve static content from one or more hostnames. Those hostnames may or may not point to different servers or a CDN, the browser doesn't know (or care).

We can configure Rails to use asset hosts in the production.rb configuration file:

    config.action_controller.asset_host = "http://assets%d.lokalebasen.dk"

The above tells rails to assets0-3.lokalebasen.dk for our assets. If we want to configure more detailed asset host usage, we can pass a Proc to asset_host, like so:

    config.action_controller.asset_host = Proc.new { |source|
      "http://assets#{rand(2) + 1}.lokalebasen.dk"
    }

This tells Rails to use 2 asset hosts (assets1 and assets2) which in turn means 4 parallel requests from the browser rather than 2 - in addition to the two connections that might be fetching data from the application.

Now, all we have to do is to setup the hostnames as CNAMEs for www.lokalebasen.dk and we've increased "download parallelization" (and the load on our server, but that should be minimal with the caching changes that's implemented above).


## Moderate performance improvements

The following are reported by Google Page Speed as "moderate performance improvements". I am not going to implement any of these for the time being, but I'll go through them and comment a bit on each.


### Minify JavaScript

> There is 288kB worth of JavaScript. Minifying could save 37.5kB (13% reduction).

We're now getting to an area where Google Page Speed really shines. Not only does it tell me to go ahead and minify my JavaScript, it even goes ahead and minifies the files for me to add to the project.

However, in this concrete case I am dubious of the actual benefits of minifying. Sure, saving 37.5kB of data from going over the wire sounds great, but the biggest saving comes from the combined JavaScript file we generated above when we combined external Javascript files. That file takes up 250kB and minifying it saves 37.3kB.

However, we've also enabled compression for all our text-based asset files, including the combined JavaScript file. Examining the actual responses coming from the server reveals that the file is compressed to 67kB before being sent over the wire, a reduction of 183kB (73%).

On top of that, the file will be cached for the majority of requests, so the actual gain in page speed by minifying is likely negligible.


### Optimize images

> There are 63kB worth of images. Optimizing them could save ~15.9kB (25.3% reduction).

Just like with the JavaScript above, Google Page Speed not only tells us that we can compress our images a bit better, it even goes ahead and does it for us. Do note, though, that it turns GIF images into PNG images, which might or might not be desirable.

Another nice touch is that it notifies you of images that has a larger size than you're actually showing them at. Resizing images to their proper size is a good way to save on the bytes.


### Remove unused CSS

> 75.9% of CSS (estimated 27.1kB of 35.7kB) is not used by the current page.

While removing unused CSS is obviously great advice, the plugin has no way of knowing what is actually being used and what isn't - and in my experience, neither has members of the team.

The plugin can only analyze the current page, and removing styles based on a single page is probably not a good idea. Does anyone know of an application that goes through all pages on a domain, analyzing what CSS is used?

<ins>Update: [Krijn Hoetmer](http://krijnhoetmer.nl/) mentioned [Dust-Me Selectors](https://addons.mozilla.org/en-US/firefox/addon/5392) in the comments - a Firefox plugin that does just that.</ins>


### Serve static content from a cookieless domain

> Serve the following static resources from a domain that doesn't set cookies:
> ...
> 8.6kB of cookies were sent with the requests for these resources.

This is one piece of advice I haven't stumbled on before. Generally, all responses from the server includes the cookie header, which is definitely not necessary in the cases of static images, JavaScript files, and stylesheets. 

I will have to look into how to do this, but I imagine very few lines of Apache-fu is required in order to turn off cookies on our asset servers.


### Use efficient CSS selectors

> /stylesheets/all.css?1248691631 has 63 very inefficient and 95 inefficient rules of 411 total rules.

This is another first for me. I'll have to admit, I had never considered the fact that some CSS selectors are more or less efficient than others. It does makes sense, but unfortunately we're getting into black magic territory now. 


It would be cool to see a tool that could measure the actual efficiency of given CSS selectors so we had a chance of evaluating what changes are worth making. My gut feeling is that this advice is only for squeezing out those last milliseconds or if you have a very complex stylesheet - I would love to see actual numbers, though.


## The result

Implementing the above significant improvements required only changes to 3 files and 11 lines of configuration/code, and took less than an hour - time well invested, if you ask me.

[Google Page Speed](http://code.google.com/speed/page-speed/) is a great tool for any web developer caring about the performance of their pages, even if you're already using YSlow. Use it and make my surfing more efficient, pretty please.

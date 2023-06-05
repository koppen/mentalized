---
title: "Debugging Encoding::InvalidByteSequenceError on Digital Ocean"
categories:
- software
- technology
description: "Classlist is a Ruby implementation of DOMTokenList for easier manipulation of CSS classnames in Ruby"
---

I recently ran into a weird error trying to deploy a [Bridgetown](https://www.bridgetownrb.com/) [site](https://www.frontlobby.dk) to [Digital Ocean](https://www.digitalocean.com)s app platform: `Encoding::InvalidByteSequenceError` while converting `ERBTemplates`. Here's what I did to fix it.

<!--more-->

## TLDR

Add an environment variable `LC_ALL=en_US.UTF-8`.

## The long story

After adding a new Digital Ocean app with a static site, the builds kept failing with

```
  Conversion error: Bridgetown::Converters::ERBTemplates encountered an error while converting `404.html'
  Exception raised: Encoding::InvalidByteSequenceError
/workspace/src/_partials/_head.erb is not valid US-ASCII
                 1: /layers/heroku_ruby/gems/vendor/bundle/ruby/3.2.0/gems/tilt-2.1.0/lib/tilt/template.rb:95:in `initialize'
                 2: /layers/heroku_ruby/gems/vendor/bundle/ruby/3.2.0/gems/bridgetown-core-1.2.0/lib/bridgetown-core/converters/erb_templates.rb:92:in `new'
                 3: /layers/heroku_ruby/gems/vendor/bundle/ruby/3.2.0/gems/bridgetown-core-1.2.0/lib/bridgetown-core/converters/erb_templates.rb:92:in `_render_partial'
                 4: /layers/heroku_ruby/gems/vendor/bundle/ruby/3.2.0/gems/bridgetown-core-1.2.0/lib/bridgetown-core/converters/erb_templates.rb:87:in `partial'
                 5: /layers/heroku_ruby/gems/vendor/bundle/ruby/3.2.0/gems/bridgetown-core-1.2.0/lib/bridgetown-core/ruby_template_view.rb:38:in `render'
         Backtrace: Use the --trace option for complete information.
building: exit status 1
ERROR: failed to build: exit
```

Curiously, I didn’t get that error running `bridgetown deploy` locally, nor could I figure out how to reproduce it locally. So I had to some detective work...

## Encodings, sigh....

The file in question, `src/_partials/_head.erb` does contain some non-ASCII characters, being in danish - a non US-ASCII-based language:

```html
<title>Mødelokale booking og reservering</title>
```

It should work perfectly fine, though, as it does locally.

But at least for now, my thesis was that something was off with that little `ø`. To verify this is I removed it, and lo and behold, deployment went through.

Now this is obviously not a long-term solution (after all, [Front Lobby](https://www.frontlobby.dk) does not allow you to book "fashion rooms", but "meeting rooms"), but it is indicative of the problem.

## Time to google!

Some sleuthing on the internet lead me to a bunch of issues setting `default_encoding` on [tilt](https://github.com/rtomayko/tilt) to fix similar errors:

* [Set default tilt encoding to UTF-8](https://github.com/slim-template/slim/pull/800)
* [Template file is not valid US-ASCII (Encoding::InvalidByteSequenceError)](https://github.com/hanami/view/issues/76)
* [Fix error: Template file is not valid US-ASCII](https://github.com/dry-rb/dry-view/pull/5)

Given that tilt is included in the stack trace above, we could be on the right path here. Looking at [tilts documentation about encodings](https://github.com/rtomayko/tilt#encodings) we find

> Tilt needs to know the encoding of the template in order to work properly:
>
> Tilt will use `Encoding.default_external` as the encoding when reading external
> files.

On my local machine that configuration returns UTF-8:

```
$ ruby -e "puts Encoding.default_external"
UTF-8
```

whereas on Digital Oceans platform it returns

```
$ ruby -e "puts Encoding.default_external"
US-ASCII
```

which indicates that this is indeed what we want to change.

## Fixing the problem without code changes

As far as I can tell, I can't readily add Ruby code to change that configuration during the build, so changing it in code is not an option. However, it shouldn't have to be the option either, as the code that we deploy is the same as we're running locally, where it works.

One of the links mentioned that behaviour would differ dependent on the locale being set. That sounds like something that could differ between my local installation and the deployment on Digital Ocean.

We can verify this by investigating the `LC_*` ENV environment variables on the system. Locally:

```bash
$ export | grep LC
LC_ALL=en_US.UTF-8
LC_CTYPE=UTF-8
```

On Digital Ocean I added the same command to the build command and got the following in the build logs:

```bash
Running custom build command: export | grep LC
yarn install
BRIDGETOWN_ENV=production bridgetown deploy
declare -x BUILD_COMMAND="export | grep LC
yarn install v1.22.19
```

There doesn’t appear to be any output from the `export | grep` line, which I suspect means no `LC_` variables are configured. I think that could be root cause, trigger Tilt to default to `US-ASCII`.

## And they lived happily ever after

So in the end I added an app-level environment variable via Digital Oceans editor for it with `LC_ALL=en_US.UTF-8` and triggered a rebuild.

And this time, the build passed and my site was deployed! Success!

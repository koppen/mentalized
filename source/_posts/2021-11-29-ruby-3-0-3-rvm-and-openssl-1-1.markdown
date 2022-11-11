---
title: "How to install Ruby 3.0.3 with OpenSSL using MacPorts and RVM"
categories:
- technology
description: "Ruby 3 and OpenSSL 3 does not go well together. Follow these steps to get Ruby working without getting 'Could not load OpenSSL'"
---

Recently a security patch for [Ruby](https://www.ruby-lang.org/)
([3.0.3](https://www.ruby-lang.org/en/news/2021/11/24/ruby-3-0-3-released/)) was
released and like a good code maintainer I went to install it. Everything seemed
to work fine, alas when I tried to install my gems on the new version I got...

> Could not load OpenSSL.
> You must recompile Ruby with OpenSSL support or change the sources in your
> Gemfile from 'https' to 'http'. Instructions for compiling with OpenSSL using
> RVM are available at rvm.io/packages/openssl.

<!--more-->

It seems `rvm requirements`/`autolibs` gives us
[OpenSSL](https://www.openssl.org/) 3, but Ruby apparently does not work with
OpenSSL 3, so it silently ignores it resulting in a Ruby installation compiled
with no OpenSSL support. That's suboptimal.

We need to use a compatible OpenSSL version when installing it would seem. Luckily we can configure [RVM](https://rvm.io/) to use specific, already installed, OpenSSL
versions when compiling using a combination of
`PKG_CONFIG` and `--with-` directives. We've [seen this previously installing Ruby
2.3](/journal/2019/09/13/ruby-2-3-rvm-and-openssl-1-0/), albeit with an even older OpenSSL version.

## The fix

Taking a wild guess at what OpenSSL version we could use, I got Ruby 3.0.3
installed using the following command:

    PKG_CONFIG_PATH=/opt/local/lib/openssl-1.1/pkgconfig rvm reinstall 3.0.3 --with-openssl-lib=/opt/local/lib/openssl-1.1 --with-openssl-include=/opt/local/include/openssl-1.1

And with that in place you should have Ruby 3.0.3 installed with OpenSSL 1.1 support using RVM and [Macports](https://www.macports.org/).

## Relevant software versions

* RVM 1.29.12
* Ruby 3.0.3
* Macports
* macOS Montery

---
title: "How to fix Ruby 2.3 with OpenSSL on Mojave using MacPorts and RVM"
categories:
- technology
---

I updated my [MacPorts](https://www.macports.org/) and broke all my old [Ruby](https://www.ruby-lang.org) installations. What I did next might shock you.

<!--more-->

Recently I had the distinct pleasure of having to (re)install Ruby 2.3 on my Mac using MacPorts after upgrading my installed ports. Turns out, upgrading OpenSSL broke my old Rubies.

Usually this is no problem. I use [RVM](https://rvm.io) so a rebuilt Ruby is usually just a `rvm reinstall` away. Not this time though:

```
$ rvm --verbose reinstall ruby-2.3.1
ruby-2.3.1 - #removing src/ruby-2.3.1 - please wait
Searching for binary rubies, this might take some time.
No binary rubies available for: osx/10.14/x86_64/ruby-2.3.1.
Continuing with compilation. Please read 'rvm help mount' to get more information on binary rubies.
Checking requirements for osx.
Installing requirements for osx.
Updating system - please wait
Installing required packages: openssl - please wait
Certificates bundle '/opt/local/etc/openssl/cert.pem' is already up to date.
Requirements installation successful.
Installing Ruby from source to: /Users/jakob/.rvm/rubies/ruby-2.3.1, this may take a while depending on your cpu(s)...
ruby-2.3.1 - #downloading ruby-2.3.1, this may take a while depending on your connection...
ruby-2.3.1 - #extracting ruby-2.3.1 to /Users/jakob/.rvm/src/ruby-2.3.1 - please wait
ruby-2.3.1 - #applying patch /Users/jakob/.rvm/patches/ruby/ruby_2_3_gcc7.patch - please wait
ruby-2.3.1 - #applying patch /Users/jakob/.rvm/patches/ruby/2.3.1/random_c_using_NR_prefix.patch - please wait
ruby-2.3.1 - #configuring - please wait
ruby-2.3.1 - #post-configuration - please wait
ruby-2.3.1 - #compiling - please wait
Error running '__rvm_make -j8',
please read /Users/jakob/.rvm/log/1568281034_ruby-2.3.1/make.log

There has been an error while running make. Halting the installation.
```

It turns out, [OpenSSL 1.1 isn't compatible with Ruby 2.3.x](https://github.com/rvm/rvm/issues/3862), and I probably just accidentally installed 1.1 instead of 1.0. Turns out, this has been - and is - [a problem for tons of people](https://github.com/rvm/rvm/issues?utf8=%E2%9C%93&q=is%3Aissue+install+2.3+openssl+mac+).

So here's how I ended up fixing it.

1. Install a compatible version of openssl via ports
2. Instruct RVM to use that compatible version instead of the default when reinstalling.

## 1. Install a compatible version of OpenSSL via ports

This is fairly easily done, there's a package for exactly this situation:

```bash
$ sudo port install openssl10
```

This install OpenSSL 1.0.something in /opt/local/, now we just need to use that package.

[rvm autolibs](http://rvm.io/rvm/autolibs) can't help us here, as it installs [the newest version of OpenSSL](https://ports.macports.org/port/openssl/summary), which is incompatible.

## 2. Configure RVM

The magic incantation we want here (which worked for me) is

```bash
$ PKG_CONFIG_PATH=/opt/local/lib/openssl-1.0/pkgconfig rvm reinstall 2.3.7 --with-openssl-lib=/opt/local/lib/openssl-1.0 --with-openssl-include=/opt/local/include/openssl-1.0
```

That line took me at least a day and a metric-ton of Ruby reinstalls to figure out. Please, use it to save your day and feel free to stop reading here.

Alternatively, let's unpack that to the best of my understanding:

### `PKG_CONFIG_PATH=/opt/local/lib/openssl-1.0/pkgconfig`

[pkg-config](https://people.freedesktop.org/~dbn/pkg-config-guide.html) is a utility that can be used to figure out where on your machine different packages are installed. This is pretty clever actually, and probably saves a ton of time for pacakge maintainers etc.

I'd never heard of it before, but it seems it's used by Ruby, thanks a lot to [Olle](http://ollehost.dk) for [pointing me in the right direction](http://ollehost.dk/blog/2013/06/25/install-ruby-2-0-0-p195-using-ruby-build-and-pkg-config/).

Without changes, if I ask where the openssl libraries are installed, I'd get something like:

```bash
$ pkg-config --libs openssl
-L/opt/local/lib -lssl -lcrypto
```

which is fine for most cases, but not what we need here and now. We've installed OpenSSL 1.0 in `/opt/local/lib/openssl-1.0`, which isn't going to be picked up by the above. But we can configure `pkg-config` so it looks in the new path using the `PKG_CONFIG_PATH` environment variable.

```
PKG_CONFIG_PATH=/opt/local/lib/openssl-1.0/pkgconfig
```

With that in place, we get a result from our old openssl:

```
$ PKG_CONFIG_PATH=/opt/local/lib/openssl-1.0/pkgconfig pkg-config --libs openssl
-L/opt/local/lib/openssl-1.0 -lssl -lcrypto
```

### `--with-openssl-lib` and `--with-openssl-include`

RVM (or probably Ruby, really) can be configured to look in specific paths for picking up packages when compiling. The generic option for this is `--with-openssl-dir`, but that's not enough for our use, as that expect a directory with `lib`, `include` etc inside it, which MacPorts doesn't give us. So we have to split it up.

`--with-openssl-lib` points at the library path, which in our case is at `/opt/local/lib/openssl-1.0`, and `--with-openssl-include` points at the include path, which following the trend is at `/opt/local/include/openssl-1.0`.

## Mental note to self

Upgrading applications still on Ruby 2.3 should probably be a high priority nowadays...

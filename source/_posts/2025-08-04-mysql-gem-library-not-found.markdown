---
title: "How to fix <code>ld: library not found for -lzstd</code> installing mysql2"
categories:
- technology
description: "If you get an 'ld: library not found for -lzstd' message when installing the mysql2 gem, this might just be the fix."

---

I have a history of problems with installing the mysql2 gem, and this is just another chapter in [that tale](https://mentalized.net/journal/2020/08/06/mysql2-gem-with-mysql-56/). If you receive a `ld: library not found for -lzstd` error when running bundler or otherwise attempt to install the mysql2 gem, this might be the solution.

<!--more -->

## What I experienced

I am using [MacPorts](https://www.macports.org/) and trying to install the [mysql2 gem](https://rubygems.org/gems/mysql2) gave me the following error

    $ gem install mysql2 -v 0.5.6
    ...
    ld: library not found for -lzstd
    clang: error: linker command failed with exit code 1 (use -v to see invocation)
    make: *** [mysql2.bundle] Error 1

    make failed, exit code 2
    ...

## TLDR; the solution

What worked for me was telling `ld` that it can find the libzstd files in the MacPorts lib directory at `/opt/local/lib`:

```
$ gem install mysql2 -v 0.5.6 -- --with-ldflags="-L/opt/local/lib"
```

## More details

The relevant part of the error message above is

> ld: library not found for -lzstd

This happens when `ld` wants to include some library, given after `-l` (in this case `libzstd`), but can't. However the library _is_ installed as part of my MacPort installation:

```
$ ls -1 /opt/local/lib/libzstd*
/opt/local/lib/libzstd.1.5.7.dylib
/opt/local/lib/libzstd.1.dylib
/opt/local/lib/libzstd.a
/opt/local/lib/libzstd.dylib
```

Seeing that `ld` can't an installed library probably means that `ld` is looking the wrong place - or at the very least, not looking in the right place. So let's tell it to.

Investigating [`man ld`](https://www.man7.org/linux/man-pages/man1/ld.1.html) leads us to the `-L`/`--library-path=` command line argument:

> -Ldir: Add dir to the list of directories in which to search for libraries. Directories specified with -L are searched in the order they appear on the command line and before the default search path. In Xcode4 and later, there can be a space between the -L and directory.

So maybe telling `ld` where to find the libraries can help. However, we are not calling `ld` directly ourselves, but rather [RubyGems](https://rubygems.org/) is calling it for us as part of the installation process.

Luckily, we can forward arguments to the installation process:

```
$ gem install mysql2 -v 0.5.6 -- --with-ldflags="-L/opt/local/lib"
Building native extensions with: '--with-ldflags=-L/opt/local/lib'
This could take a while...
Successfully installed mysql2-0.5.6
1 gem installed
```

So basically, we're telling `gem` to tell `make` to tell `ld` to use `/opt/local/lib` as the `-L` argument.

## Extra credits

Unfortunately this is a one-time thing. The next time you have to install mysql2, it'll fail again - there's no persistence here.

We can, however, take advantage of [bundler](https://bundler.io/) here. If you do

    $ bundle config --local build.mysql2 "--with-ldflags=-L/opt/local/lib"

you tell `bundler` to tell `gem` to tell `make` to tell `ld` to use `/opt/local/lib` in all future installations of the `mysql2` gem.

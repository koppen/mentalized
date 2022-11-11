---
title: "How to fix a mysql2 gem install problem"
categories:
- development
description: "If you get an 'unknown option '--include' message when installing the mysql2, this might just be the fix."
---

This is one of those posts that's written as my extended memory. I ran into an
issue trying to install the [mysql2 gem](https://rubygems.org/gems/mysql2) on a
client project today running [MySQL](https://www.mysql.com/) 5.6 (yeah yeah, I
know). The root issue wasn't immediately obvious, but I managed to find a
workaround.

<!--more-->

## What I experienced

The gist of the issue is this behaviour (I've included the full error output
down below):

    $ gem install mysql2 -v 0.5.3
    ...
    /opt/local/bin/mysql_config: unknown option '--include'
    ...
    *** extconf.rb failed ***

It seems the relevant error message here is:

    /opt/local/bin/mysql_config: unknown option '--include'

which matches what happens when I try it manually:

    $ /opt/local/bin/mysql_config --version
    /opt/local/bin/mysql_config Ver 1.0 Distrib 5.6.45, for osx10.14 on x86_64

    $ /opt/local/bin/mysql_config --include
    /opt/local/bin/mysql_config: unknown option '--include'

Installing the gem with MySQL 5.7 activated works just fine, because:

    $ /opt/local/bin/mysql_config --include
    -I/opt/local/include/mysql57/mysql

Now, this is weird because `mysql_config` most definitely should have an
`--include` option according to the [man
page](https://linux.die.net/man/1/mysql_config):

    o   --include

        Compiler options to find MySQL include files.

🤔

## Root cause

It seems the `mysql_config` binary gets linked incorrectly when doing `port select
mysql`. The symlink is now pointing to something unexpected:

    ls -l /opt/local/bin/mysql_config
    lrwxr-xr-x  1 root  wheel  46 Aug  6 11:50 /opt/local/bin/mysql_config -> /opt/local/lib/mysql56/bin/mysql_config_editor

That link probably shouldn't go to `mysql_config_editor`, but to
`/opt/local/lib/mysql56/bin/mysql_config`. Luckily the workaround isn't
problematic now we know the root cause:

## Fix

To work around the issue describe above, we can instruct mysql2 where to find
our `mysql_config` binary:

    $ gem install mysql2 -v "0.5.3" -- --with-mysql-config=/opt/local/lib/mysql56/bin/mysql_config
    Fetching mysql2-0.5.3.gem
    Building native extensions with: '--with-mysql-config=/opt/local/lib/mysql56/bin/mysql_config'
    This could take a while...
    Successfully installed mysql2-0.5.3
    1 gem installed

🥳

Let this be a reminder to always verify your assumptions. I assumed, quite
logically I might add, that the `mysql_config` binary in my PATH was the binary
I was looking for. It wasn't.

## System details

- macOS Mojave 10.14.6
- Macports 2.6.3
- MySQL 5.6
- RVM 1.29.10

## Full error log

```
$ gem install mysql2 -v "0.5.3"
Building native extensions. This could take a while...
ERROR:  Error installing mysql2:
	ERROR: Failed to build gem native extension.

    current directory: ~/.rvm/gems/ruby-2.5.7@bornibyen/gems/mysql2-0.5.3/ext/mysql2
~/.rvm/rubies/ruby-2.5.7/bin/ruby -I ~/.rvm/rubies/ruby-2.5.7/lib/ruby/site_ruby/2.5.0 -r ./siteconf20200806-40171-1ce1iq5.rb extconf.rb
checking for rb_absint_size()... yes
checking for rb_absint_singlebit_p()... yes
checking for rb_wait_for_single_fd()... yes
-----
Using mysql_config at /opt/local/bin/mysql_config
-----
/opt/local/bin/mysql_config: unknown option '--include'
*** extconf.rb failed ***
Could not create Makefile due to some reason, probably lack of necessary
libraries and/or headers.  Check the mkmf.log file for more details.  You may
need configuration options.

Provided configuration options:
	--with-opt-dir
	--with-opt-include
	--without-opt-include=${opt-dir}/include
	--with-opt-lib
	--without-opt-lib=${opt-dir}/lib
	--with-make-prog
	--without-make-prog
	--srcdir=.
	--curdir
	--ruby=~/.rvm/rubies/ruby-2.5.7/bin/$(RUBY_BASE_NAME)
	--with-mysql-dir
	--without-mysql-dir
	--with-mysql-include
	--without-mysql-include=${mysql-dir}/include
	--with-mysql-lib
	--without-mysql-lib=${mysql-dir}/lib
	--with-mysql-config
	--without-mysql-config

To see why this extension failed to compile, please check the mkmf.log which can be found here:

  ~/.rvm/gems/ruby-2.5.7/extensions/x86_64-darwin-18/2.5.0/mysql2-0.5.3/mkmf.log

extconf failed, exit code 1

Gem files will remain installed in ~/.rvm/gems/ruby-2.5.7/gems/mysql2-0.5.3 for inspection.
Results logged to ~/.rvm/gems/ruby-2.5.7/extensions/x86_64-darwin-18/2.5.0/mysql2-0.5.3/gem_make.out
```

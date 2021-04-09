---
title: "How to use a different database for each branch in Rails"
categories:
- development
- technology
description: "With a Rails app, how do you manage switching between a bunch of different branches that have different DB schemas/migration states?"
---

[Nate Berkopec](https://twitter.com/nateberkopec) [asked on Twitter](https://twitter.com/nateberkopec/status/1377348675291111426):

> With a Rails app, how do you manage switching between a bunch of different branches that have different DB schemas/migration states? Blowing away the whole DB every time gets old fast.

I agree, it does get old fast, but luckily Ruby and Rails has the building blocks necessary to help us out.

<!--more-->

## TLDR

Put this in your `config/database.yml`:

```yaml
development:
  database: my_application_<%= `git branch --show-current`.strip %>
```

## Details

Our goal here is to have a database for each branch so we can be sure that our database changes don't persist when we switch branches. For this to work we need...

1. The name of the current branch.
2. A way to tell Rails (well, ActiveRecord) what database name to use.
3. A database for each branch.

## How to get the name of each branch

If you are using git version 2.22 or later, you've got `git branch --show-current` to return the name of the current branch:

```shell
$ git branch --show-current
another
```

If you're on an older version of git you should be able to get there using a bit of command-line-fu:

```shell
$ git branch | grep "*" | cut -d " " -f 2
another
```

I haven't verified this, though.

## How to tell ActiveRecord what database name to use

We usually configure the database connections in `config/database.yml`. That file is parsed as YAML, but it also supports ERB. This is already used in the [default generated database.yml](https://github.com/rails/rails/blob/main/railties/lib/rails/generators/rails/app/templates/config/databases/postgresql.yml.tt), which contains

```
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

All we need to do is configure our database name in the same manner, so something like:

```
  database: <%= insert_my_database_name_here %>
```

We already know how to get the current branch name from git, so we can [shell out](/journal/2010/03/08/5-ways-to-run-commands-from-ruby/) and run the git command for that:

```
  database: your_app_name_<%= `git branch --show-current`.strip %>
```

With the above in place in config/database.yml, [ActiveRecord](https://api.rubyonrails.org/classes/ActiveRecord.html) will see your database name as `your_app_name_main` when the current branch is `main` and `your_app_name_break_things` if the branch is `break_things` - and that's what we want.

## How to have a database for each branch

Unfortunately the magic stops here. You still have to create (and drop) the databases you need, and run migrations and seeds and whatnot.

Thankfully, with [Rails' Actionable Errors](https://github.com/rails/rails/pull/34788) this has become less cumbersome.

## Caveats

If you like using weird characters in your branch names, like having branches called `bug/1234-fix` or whatever, your DBMS needs to support those characters in database names. As it turns out, [PostgreSQL](https://www.postgresql.org/) is perfectly fine having a database named `your_app_name_bug-1234-fix` - I haven't verified on other systems.

If this is a problem for you, you might be able to do something like this to remove unwanted characters:

```yaml
  database: your_app_name_<%= `git branch --show-current`.gsub(/\W/, "") %>
```

## Further ideas

If you are using PostgreSQL, you might be able to configure [`schema_search_path`](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/PostgreSQLAdapter.html) in roughly the same manner to have just the one development database. I have not investigated this, though 🤔

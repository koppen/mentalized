---
title: "One-off scripts on Heroku with Rails"
categories:
- Rails
- technology
description: "Running one-off maintenance scripts in your Rails application hosted on Heroku is easy, Jakob guides you here."
---

Every so often you have a small script that needs to be run on your staging or production server, but committing and deploying the script on its own is just too much of a hassle. Luckily [Rails](https://rubyonrails.org/) and [Heroku](https://www.heroku.com/) has a great solution for this.

<!--more-->

## rails runner

If you have a script in your application that needs to run in the context of your Rails application, you can run it via [`rails runner`](https://guides.rubyonrails.org/command_line.html#bin-rails-runner).

For example, let’s say we have this very important script:

```ruby
puts Rails.env
```

Running this with just `ruby` gives an error:

```ruby
$ ruby hi.rb
hi.rb:1:in `<main>': uninitialized constant Rails (NameError)

puts Rails.env
     ^^^^^
```

This makes sense, since `Rails` isn’t loaded. That’s where `rails runner` steps up and ensures the full Rails environment is loaded:

```ruby
$ rails runner hi.rb
development
```

Pretty helpful!

`rails runner` doesn’t only run scripts from disk, it also has a few other tricks up its sleeve. For example, you could pass the code directly:

```ruby
$ rails runner "puts Rails.env"
development
```

or you can pipe the Ruby code to `rails runner` - note the little `-` at the end of the command there, that means read the script from stdin.

```ruby
$ cat hi.rb | rails runner
development
```

## heroku run

[Heroku's CLI](https://devcenter.heroku.com/articles/heroku-cli) has a function similar to `rails runner`, namely `heroku run`.

```ruby
Usage: heroku run COMMAND

Example: heroku run bash
```

That allows you to run a one-off process inside a Heroku dyno. Say, if we needed to run migrations on Heroku we could do

```ruby
$ heroku run rails db:migrate
```

Also pretty helpful!

## heroku run rails runner

Let’s combine those! `heroku run` runs any process, what if that process was `rails runner`?

```ruby
$ heroku run 'rails runner "puts Rails.env"'
```

We do have to be fairly vigilant about placing our quotation marks so the correct things are run by the correct processes. In the above everything in `'` is run by `heroku run`, which in turn runs everything in `"` using `rails runner`.

## heroku run rails runner with a pipe

But can we pipe a script to `rails runner` and have `heroku run` run it in a dyno? I am so glad you asked! Yes, we can. `heroku run` forwards stdin to the process being run, so we can do

```ruby
$ echo "puts Rails.env" | heroku run "rails runner -"
Running rails runner - on ⬢ some-app... up, run.7413
puts Rails.env
production
```

Note how the script/stdin is echoed back to us, which gets annoying for longer scripts. To avoid this we could use the `--no-tty` flag:

```ruby
$ echo "puts Rails.env" | heroku run --no-tty "rails runner -"
Running rails runner - on ⬢ some-app... up, run.9354
production
```

## How to run one-off Rails application scripts on Heroku

This leads us to the natural conclusion of all the above. In order to run a one-off script in a Heroku dyno with your Rails application environment loaded without having to add it to git and deploy, you can run it like so:

```ruby
$ cat hi.rb | heroku run --no-tty "rails runner -"
Running rails runner - on ⬢ some-app... up, run.1846
production
```

Very helpful indeed!

## Styr might help you

If you find the above relevant or helpful, you might be interested in checking out [styr](/journal/2026/01/24/styr/) instead, which makes the above even easier.

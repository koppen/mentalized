---
title: "Active Record STI and eager loading"
categories:
- Rails
- technology
---

This week has been ... interesting. Not because of obvious geopolitical events, but because a [client application](https://eventzonen.dk) started throwing weird errors; background processes failed in ways that weren't possible and otherwise reliable cronjobs just didn't do what they were supposed to; no failures or anything, they just didn't process the records they were meant to.

<!--more-->

This particular application uses [Single Table Inheritance (STI)](https://api.rubyonrails.org/classes/ActiveRecord/Inheritance.html) for one of the tables and we introduced a new super class into the hierarchy at the beginning of the week. Everything worked great in development and in testing, but in production things started being off.

Turns out, STI was to blame - or rather, [us](https://substancelab.dk) not reading the manual...

## Let me tell you a tale...

The application has an `Event` model, which has a few subclasses; `ArtistEvent` inherits from `Event`, while `BookingEvent` and `OfferEvent` inherits from `ArtistEvent`.

We need to send an email every so often for specific `BookingEvent`s so we have a cron job set up for that, running a rake task that runs some method in a class. And for some reason, those mails didn't go out.

### Blame the code!

Looking at the code, everything appears fine. The relevant events are loaded from the database using something similar to `ArtistEvent.ready_for_reminders` and each model is then processed.

### Blame the data!

Running the code in a `rails console` on the production server made it clear that there were indeed events ready for reminders, yet when the cron job ran it found exacly 0 events.

### Blame the cron job!

The cron job in question uses a rake task to trigger the code, and after a bunch of debugging we concluded that things did not work when running the code via a rake task, but it did work when running the same code via `rails runner`. Wut?!

### Blame rake!

One sneaky difference between using `rake` (even when loading the rails environment) and using `rails runner` is how they load your application: [By default, in production environments Rake tasks do not eager load the application](https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#eager-loading).

### Blame eager loading!

Armed with this knowledge (which I didn't know until now, and I have a fair amount of Rails experience, I'd say 👴🏻) we started looking closer at how [Rails](https://rubyonrails.org/) eager loads.

Lo and behold, we could reproduce the problem in development when setting `config.eager_load = true`:

### With `eager_load=false`

```ruby
ArtistEvent.limit(1).to_sql
#=> "SELECT \"events\".* FROM \"events\" WHERE \"events\".\"type\" IN ('ArtistEvent') LIMIT 1"
```

### With `eager_load=true`

```ruby
ArtistEvent.limit(1).to_sql
#=> "SELECT \"events\".* FROM \"events\" WHERE \"events\".\"type\" IN ('ArtistEvent', 'OfferEvent', 'BookingEvent') LIMIT 1"
```

In other words, when `eager_load` is set to `false`, our query exclusively loads models of type `ArtistEvent`, ie none. We want the subclasses of `ArtistEvent` to be loaded, which is what happens with `eager_load = true`.

## RTFM

Apparently, [Single Table Inheritance doesn't play well with lazy loading classes](https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#single-table-inheritance): Active Record has to be aware of STI hierarchies to work correctly, but when lazy loading, classes are precisely loaded only on demand.

This means that when we do `ArtistEvent.subclasses` with `eager_load = false` the subclasses has yet to be loaded and therefore doesn't exist yet!

```ruby
> ArtistEvent.subclasses.map(&:name) # With eager_load=false
#=> []
```

"Thankfully" 🙄 this is a known and documented problem and I guess we should have read the manual on [Autoloading and reloading constants](https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#option-2-preload-a-collapsed-directory), but we didn't and the application has been running just fine for years...

Luckily a bunch of solutions are also well documented in the above guide, so if you ever run into problems with ActiveRecord STI not including all subclasses in `type` queries there is a way forward.

---
title: "<code>update_attribute</code> considered harmful"
categories:
- Rails
- programming
- projects
- technology
---

Yesterday, we banned usage of
[`ActiveRecord#update_attribute`](http://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-update_attribute)
on the Rails team at [GoMore](http://gomore.com).

We stumbled across a gotcha in `ActiveRecord#update_attribute` which has some
surprising - and potentially dangerous - behaviour.

<!--more-->

## Show me the gotcha!

Consider the following code (assuming `User` has an [email validation](https://github.com/substancelab/activemodel-email_address_validator)):

```ruby
user = User.find(1)
user.email = "notvalid"
user.valid? #=> false
user.update_attribute(:first_name, "Bob")
```

I'd expect User 1 to have their name changed to "Bob", while the email address is
unchanged, however...

```ruby
persisted_user = user.reload
persisted_user.email #=> "invalid"
persisted_user.name #=> "Bob"
persisted_user.valid? #=> false
```

ActiveRecord has happily saved an invalid `User` object, because
`update_attribute` bypasses validations. Nevermind the fact that
`update_attribute` is named with a singular `attribute`; it can still update
multiple attributes.

## RTFM

However, going back and reading the effing manual, this is actually the
[documented behaviour of `update_attribute`](http://api.rubyonrails.org/clas
ses/ActiveRecord/Persistence.html#method-i-update_attribute):

> Updates a single attribute and saves the record.

So all this time I have read the above to mean that it updates a single
attribute and saves that change and nothing else to the database, I've been
wrong. It actually meant that it updates a single attribute and saves the
entire record, including all other changed attributes.

But hey, that's documented as well:

> Updates all the attributes that are dirty in this object.

I was surprised, the team at GoMore was surprised, and [other people are as
well](https://github.com/rails/rails/issues/14357), but yeah, sure, I guess it's
true what the say about assuming.

## The tumultuous life of `update_attribute`

This has been [discussed on Rails
Core](https://groups.google.com/forum/#!searchin/rubyonrails-core/update_attribute/rubyonrails-core/mIF41axi5s4/6lTwUZwu5rIJ),
and the current attitude is, that this isn't going to get fixed. The method is too
widely used to just remove, it seems, and the behaviour has become documented.

`update_attribute` is no stranger to controversy. It was actually [removed from Rails entirely](https://github.com/rails/rails/commit/a7f4b0a1231bf3c65db2ad4066da78c3da5ffb01)
at one point, but it was also brought back again, due to popular demand(?).

## What to do instead

Fret not, there are still tons of ways to set attributes in `ActiveRecord`. A
few notable alternatives to `update_attribute`:

* If you just want to update one attribute and save the entire record, assuming
  the entire record is valid, use [`update(attribute: value)`](http://apidock.com/rails/ActiveRecord/Persistence/update) - the method
  formerly known as `update_attributes`.

* If you want to change a value regardless of the record being valid or not, use
  [`update_colum(column_name, value)`](http://apidock.com/rails/v4.2.1/ActiveRecord/Persistence/update_column)
  which is lower level, doesn't run validations, and only updates what it's been told to.

And do check out David Verhasselts excellent overview of [different ways to set
attributes in ActiveRecord](http://www.davidverhasselt.com/set-attributes-in-activerecord/).

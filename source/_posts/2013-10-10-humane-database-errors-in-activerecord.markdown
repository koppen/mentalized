---
title: Humane database errors in ActiveRecord
date: '2013-10-10 13:48:23 +0200'
mt_id: 2172
categories:
- programming
---
[`ActiveRecord`](http://api.rubyonrails.org/classes/ActiveRecord/Base.html) doesn't really play well with database constraints and other builtin data consistency mechanisms.

It comes with its own mechanisms for ensuring consistency, but it can be coerced into using the mechanisms from the database as well.


<!--more-->

## Ensuring unique names in a users table

Imagine you've implemented an [`ActiveRecord`](http://api.rubyonrails.org/classes/ActiveRecord/Base.html) model named `User`, with the following schema:

``` ruby
create_table "users", force: true do |t|
  t.string "name"
end
```

Names need to be unique across users, so you've also added a unique constrain on the `name` column:

``` ruby
add_index "users", ["name"], unique: true
```

This way we know we'll never get two rows with the same name value in the database:

``` ruby
>> User.create!(:name => "Bob")
=> #<User id: 1, name: "Bob">
>> User.create!(:name => "Bob")
ActiveRecord::RecordNotUnique: PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "index_users_on_name"
DETAIL:  Key (name)=(Bob) already exists.
: INSERT INTO "users" ("name") VALUES ($1) RETURNING "id"
```

Not the cleanest of results but pretty much as expected: We hit the unique constraint, the database refuses to store the data, and ActiveRecord raises an exception.

If this were to happen in a running Rails app, the end user would get a HTTP 500 error page, which is not the most user friendly of things.

![Screenshot of server error in development mode](/files/journal/humane_database_errors/default_error.png)

## Validations

One way to work around this is to add a uniqueness validation of the `name` attribute: `validates :name, :uniqueness => true`. This is fine, gives the users readable (and localizable) error messages and work in by far the majority of cases.

If you can, by all means use the validation.

## Rescuing database errors

But how do we handle those cases where the validation won't suffice and we don't want to show HTTP 500 error pages to our users?

If we create our `save` method, we can actually catch the database error before it bubbles up to the user interface and - hopefully - do something better with it:

``` ruby
class User < ActiveRecord::Base
  def save(*args)
    super
  rescue ActiveRecord::RecordNotUnique => error
    errors[:base] << error.message
    false
  end
end
```

Now, at least the user gets a clue as to what has happened, but perhaps not in the most user friendly fashion:

![Screenshot of database error rendered as a validation error](/files/journal/humane_database_errors/database_error_as_validation_error.png)

You could naturally place any other message into the errors object if you so desire - for example one that makes more sense to normal people.

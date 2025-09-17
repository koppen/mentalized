---
title: "Ember on Rails: Validations"
date: '2014-06-16 11:15:57 +0100'
description: "Follow along as we learn to integrate Ember.js with Rails, creating an Ember app backed by a Rails JSON API."
categories:
- programming
- Rails
- technology
description: "Part 4 of my Ember on Rails tutorial shows how to manage validations in an Ember frontend using Rails as for the backend."
published: true
series: "Ember on Rails"
---

In the [previous episodes](/journal/2014/06/10/ember-on-rails-03/) we've built a working [Ember.js](http://emberjs.com) application to manage our growing collection of Books. It lives inside a [Rails](http://rubyonrails.org) application which it uses for its backend.

We're able to list all the books in our vast library, and also add new books to our collection. However, if we try to add a book without giving it a title, the backend gladly accepts it and saves it, which is probably not the optimal behavior.

It is time to add validations to our application.

<!--more-->

## ActiveRecord validations

On the server side, preventing a `Book` from being saved when it doesn't have a title is straightforward. Change `app/models/book.rb` to look like:

```ruby
class Book < ActiveRecord::Base
  validates :title, :presence => true
end
```

Now, if you attempt to create a `Book` without a title, ActiveRecord should complain:

```ruby
> Book.create!
ActiveRecord::RecordInvalid: Validation failed: Title can't be blank
```

Nice and effective.

## The client side is oblivious

However, things are looking a bit different on the client side. Ember has no knowledge of this validation. Neither does it have any real idea what to do when saving fails.

If we click the "Save" button in [the "Add a book" form](http://0.0.0.0:3000/#/books/new) without entering a title, we get an error in the Javascript console:

> Uncaught Error: Assertion Failed: Error: The backend rejected the commit because it was invalid: {title: can't be blank}

Not the worlds most user friendly error - especially not hidden away in the Javascript console - but it hints at a possible improvement; The error message from `ActiveRecord` is actually present in the client side error: "`{title: can't be blank}`".

As it turns out, using [active\_model\_serializers](https://github.com/rails-api/active_model_serializers) Rails responds with a JSON structure containing the validation error messages when saving fails:

```bash
$ curl -d 'book[author_name]="J.R.R. Tolkien"' http://0.0.0.0:3000/books
{"errors":{"title":["can't be blank"]}}
```

Wouldn't it be nice if we could somehow show those nice messages to our users?


## Showing errors in the UI

And of course we can do just that - even without adding all that much code.

But first things first, we need somewhere to actually show the errors to our users. In `app/assets/javascripts/templates/books/new.handlebars` add:

```html
{% raw %}{{#each error in errors.title}}{% endraw %}
  <p>{% raw %}{{error.message}}{% endraw %}</p>
{% raw %}{{/each}}{% endraw %}
```

where you want the errors for the title attribute to appear. I prefer right below the title input element, but it's entirely up to you.


## Promises

Now things are going to stray from what we're used to in Ruby-land. In the `create` action in `BooksNewRoute` we try to save our book using `book.save()`. The [`save`](http://emberjs.com/api/data/classes/DS.Model.html#method_save) method of Ember models returns a [`Promise`](http://emberjs.com/api/classes/Ember.RSVP.Promise.html).

Promises isn't something we Rubyists are used to dealing with. Simplified they are objects with a fulfillment-callback and a rejections-callback. In our specific case, the promise returned by `save()` triggers its fulfillmint-callback when we get a success response from the API. Likewise the rejection callback is triggered when we get a failure response.

Codified this looks like:

```javascript
newBook.save().then(
  function() {
    // Success
  },
  function() {
    // Failure
  }
);
```

## It really does work

The above is a fairly good sketch for the code we need, so we can update our `create` action to use it.

When saving is successful we want to transition to our list of books like previously. And when saving fails we want to stay on the form, showing the error message we receive.

In reality this means we don't really want to do anything when the save is rejected; we just need to give the promise something to do so the error doesn't bubble all the way to the user interface. Ember-data handles the rest for us.

The above behavior is accomplished by making the `create` action in `app/assets/javascripts/routes/books_new_route.js` look like:

```javascript
create: function() {
  var newBook = this.get('currentModel');
  var self = this;
  newBook.save().then(
    function() { self.transitionTo('books') },
    function() { }
  );
}
```

The `var self = this` trick ensures we have access to the `transitionTo` method inside our success function (damn Javascript and your ever-changing `this`).

The first parameter to `then` is the success handler where we transition to the list of books, and the second parameter is our failure handler: A function that does nothing.

## Users, consider yourself informed

Now, if you try to add a book without a title you'll get an actual error message in the user interface. Success!

![Serverside validation error rendered inline](/files/journal/ember/validation_error.png)

And if you add a title and click "Save" the book is saved on the backend and you're shown the list of books. Success x 2!

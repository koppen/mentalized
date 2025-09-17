---
title: "Ember on Rails: Reading data from the backend"
date: '2014-06-01 22:06:36 +0200'
description: "Follow along as we learn to integrate Ember.js with Rails, creating an Ember app backed by a Rails JSON API."
categories:
- programming
- Rails
- technology
published: true
series: "Ember on Rails"
---

When we left our [Ember application in part 1](https://mentalized.net/journal/2014/06/01/ember-on-rails-01/), it was functional but only capable of showing hardcoded dummy data. It is time to remedy that.

In this part 2 of my learning [Ember](http://emberjs.com) in public, we'll hook our Ember frontend to our [Rails](http://rubyonrails.org) backend.

<!--more-->

## Rails backend

First step is getting the Rails backend set up. We'll keep it fairly simple: Just a single resource, Book, exposed to the world via a JSON API.

This should be fairly simple and we won't even have to write a line of code. In your terminal run:

```bash
$ rails generate resource Book title author_name
$ rake db:migrate
```

After this, we should be able to create a `Book` in the Rails console:

```
$ rails console
Loading development environment (Rails 4.1.0)
> Book.create(:title => "Moby Dick", :author_name => "Charles Melville")
=> #<Book id: 1, title: "Moby Dick", author_name: "Charles Melville", created_at: "2014-06-05 19:02:22", updated_at: "2014-06-05 19:02:22">
```

### JSON API

Now we have a book in our database, it is time to expose the `Book` resource as `JSON`. Open `app/controllers/books_controller.rb` in your favorite editor and change it to look like:

```ruby
class BooksController < ApplicationController
  respond_to :json

  def index
    respond_with Book.all
  end
end
```

We should now be able to get a list of all our one book. First, start a Rails server:

    $ rails server

then in another shell:

    $ curl http://0.0.0.0:3000/books.json

... and you should get a response:

```json
{"books":[{"id":1,"title":"Moby Dick","author_name":"Charles Melville"}]}
```

So far, so simple. We now have a basic read-only API.

### Wait, what happened there?

You might have noticed a few steps missing here that are usually needed when you create APIs in Rails.

This is [ember-rails](http://rubygems.org/gems/ember-rails) secretly helping us out by adding the [active\_model\_serializer gem](https://rubygems.org/gems/active_model_serializers) gem to our project, and by hooking into the resource generator.

Therefore, when we generated the book resource above, a serializer was automatically generated for us in `app/serializers/book_serializer.rb`:

```ruby
class BookSerializer < ActiveModel::Serializer
  attributes :id, :title, :author_name
end
```

This tells Rails how we want to represent our books when the Ember frontend comes looking for them. Perhaps not surprisingly, this representation plays really well with Ember - let's see how well.

## Taking it clientside

Back in Ember-land, open up `app/assets/javascripts/routes/books_route.js` and replace the dummy data so the file looks the following:

```javascript
Library.BooksRoute = Ember.Route.extend({
  model: function() {
    return this.get('store').find('book');
  }
});
```

Instead of just returning some dummy data, we're now asking our data store to find us books.

Since we've stuck with the defaults and ember-rails has configured our Ember application to read from our backend using [ActiveModelAdapter](http://emberjs.com/api/data/classes/DS.ActiveModelAdapter.html) (that knows how to handle data as serialized by our serializer) everything should work now.

And behold, if you go to [http://0.0.0.0:3000/#/books](http://0.0.0.0:3000/#/books) and refresh, you should see a list of your books coming straight from the Rails backend.

Success, we're done. Amazon, buy us, please! No? What's that? We need to be able to save books as well?

Oh, alright then, we'll take a look at that in [the next installment](/journal/2014/06/10/ember-on-rails-03/).

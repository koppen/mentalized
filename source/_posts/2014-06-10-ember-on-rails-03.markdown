---
title: "Ember on Rails: Writing data to the backend"
date: '2014-06-10 09:06:36 +0200'
categories:
- programming
- technology
published: true
series: "Ember on Rails"
---

Unfortunately, Amazon wasn't willing to buy the awesome Library Ember application we cooked up in [parts 1](/journal/2014/06/01/ember-on-rails-01/) [and 2](/journal/2014/06/01/ember-on-rails-02/).

I guess we'll have to hunker down, disrupt some synergies, and leverage the network effect or whatever catchphrases are used in startups these days.

In other words, it is time to add persistence to our Ember application.

<!--more-->

## Rails backend

Like in [part 02](/journal/2014/06/01/ember-on-rails-02/), our Rails backend is going to need some work to do what we want it to.

In order for us to be able to send data to the backend and have it save it in the database, we need to add a `create` action to our `BooksController`:

```ruby
class BooksController < ApplicationController
  skip_before_filter :verify_authenticity_token

  [...]

  def create
    book = Book.new(book_params)
    if book.save
      respond_with book
    else
      respond_with book, :status => 422
    end
  end

  private

  def book_params
    params.require(:book).permit(:title, :author_name)
  end
end
```

The `create` action itself is straightforward; instantiate a `Book` with the allowed data, attempt to save it, and respond with a JSON representation of the book.

We're skipping the authenticity token verification to make it easier to debug here and now. In a real life production app that should definitely not be skipped.

Now you should be able to create a book from the command line:

```bash
$ curl -d "book[title]=The Great Gatsby" -d "book[author_name]=F. Scott Fitzgerald" http://0.0.0.0:3000/books
{"book":{"id":6,"title":"The Great Gatsby","author_name":"F. Scott Fitzgerald"}}
```

## Bringing it client-side

We're going to need some equivalent of the Rails create action on the Ember side of things. In Ember this is handily also called an action, but it lives inside the route to the view rather than a controller.

Create `app/assets/javascripts/routes/books_new_route.js`:

```javascript
Library.BooksNewRoute = Ember.Route.extend({
  model: function() {
    return this.get('store').createRecord('book');
  },
  actions: {
    create: function() {
      var newBook = this.get('currentModel');
      newBook.save();
      this.transitionTo('books');
    }
  }
});
```

There are two things happening here (and then some):

* First off all, we create a model definition for this route. In the `BooksRoute` the model returned all our books. For our `BooksNewRoute` the model returns a newly instantiated `Book`.
* And then there's the `actions` object. This defines the actions that we want to expose to the template - for this template we only need a `create` action.

The create action itself is fairly straightforward. It...

1. Grabs the current model object with all the changes that has been made to it via the two input fields
2. Saves the model to our datastore
3. Replaces the current view with the books view (`transitionTo` is pretty much like `redirect_to` from Rails).

Note the difference from Rails here. In Rails a generic `create` action receives a bunch of data from the client (via `params`), builds a model with that data, and then persists it. Because we're on the client side of things in Ember, we can just save the model- we don't have to receive data from the form or anywhere else, the actual values of the model object have already been set.

## Markup time

Time to create the actual markup we want displayed. Create a file at `app/assets/javascripts/templates/books/new.handlebars` (you probably need to create the directory first):

```html
<h1>Add a book</h1>
<form {% raw %}{{action "create" on="submit"}}{% endraw %}>
  <div>
    <label>
      Title<br>
      {% raw %}{{input type="text" value=title}}{% endraw %}
    </label>
  </div>
  <div>
    <label>
      Author name<br>
      {% raw %}{{input type="text" value=authorName}}{% endraw %}
    </label>
  </div>
  <button>Save</button>
</form>
```

We are using Embers [`{% raw %}{{input}}{% endraw %} helper`](http://emberjs.com/guides/templates/input-helpers/) to generate our input fields. This allows us to pass unquoted values to each attribute, which binds that attribute to the corresponding property in our current render context. This sounds a bit complex, so let's walk through it.

`value=title` tells Ember to populate the HTML elements `value` attribute by evaluating a `title` property. Ember then calls `title` on the current render context. The current template gets its context from the `model` function which we created in the `BooksNewRoute`.

In other words, `model` from `BooksNewRoute` asks our datastore to create a new instance of a `Book`. That book is returned to our template, who then calls `title()` on it to set the `value` of the input element.

### Data binding

In Ember terminology we have bound the `value` attribute to the `Book` models `title` property. Any changes we make to `book.title` will cause the input fields value to update - and conversely, any changes we make to the value of input field will update the title of the book.

## Link it up

Now we have a template (and an implicit view) we want to be able to navigate to it. Add the following link somewhere in your application - for example in `application.handlebars`:

```html
{% raw %}{{link-to 'Add a book' 'books.new'}}{% endraw %}
```

### Route to the new template

For that link to work we need to update the router at `app/assets/javascripts/router.js` rto map a URL to the screen that displays our "New Book" form:

```javascript
Library.Router.map(function() {
  this.resource('books', function() {
    this.route('new')
  });
});
```

### And a bit of cleanup

At some point during our work so far, Ember Rails has helpfully generated a few files in `app/assets/javascripts/views/` that we don't actually need - and that are now making things a bit harder for us. So let's expose those files to a bit of ruthless refactoring:

```bash
$ rm app/assets/javascripts/views/*
```

Also, the original books list template we have at `app/assets/javascripts/templates/books.handlebars` needs to be moved inside the new `books` directory that holds our `new` template:

```bash
$ mv app/assets/javascripts/templates/books.handlebars app/assets/javascripts/templates/books/index.handlebar
```

## Behold our UI

With all the above in place, you should be able to refresh your books list at [http://0.0.0.0:3000/#/books/](http://0.0.0.0:3000/#/books/) and see a link to "Add a book".

Clicking that link should show a fine looking form with two input fields and a "Save" button.

Clicking "Save" creates a new Book and persists it via the API.

Victory!

## Coming up

Let's recap: We now have a <del>fully</del> functional Ember application backend by a Rails backend. We can show data and add new data and have it persisted between sessions.

In the [coming episode](/journal/2014/06/16/ember-on-rails-04/) we'll look at how validations - in particular [serverside validations](/journal/2014/06/16/ember-on-rails-04/) - work.

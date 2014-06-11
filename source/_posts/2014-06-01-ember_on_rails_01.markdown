---
title: "Ember on Rails"
date: '2014-06-01 21:05:54 +0100'
categories:
- programming
- technology
published: true
series: "Ember on Rails"
---

I've been trying to get into [Ember.js](http://emberjs.com/) a few times by now, but I've always been dissuaded for various reasons.

This time around I'd like you all to learn with me - hopefully the act of me writing down what I do will make it stick better for me.

The plan here is to end up with an Ember application backed by a [Rails](http://rubyonrails.org) JSON API - we'll see if the future agrees with that goal.

<!--more-->

## Versions

This post has been written and tested on the following versions:

* Ruby 2.1
* Rails 4.1.0
* Ember.js 1.5.1

I make no guarantees that this will work on any other version, but I'd love to hear from you if stuff isn't working as I describe.

## Rails application

We'll set everything up inside a Rails application. This provides for a nice and safe base and we'll be using that Rails application as our JSON backend in the future:

    rails new library && cd library

We aren't going to use [Coffeescript](http://coffeescript.org/) nor [Turbolinks](https://github.com/rails/turbolinks) so remove those lines from your `Gemfile`:

```ruby
gem 'coffee-rails'
gem 'turbolinks'
```

## Ember.js

This is where the fun begins. We'll grab Ember via the [ember-rails](https://github.com/emberjs/ember-rails) gem, so add that to the `Gemfile`:

```ruby
gem "ember-rails", github: "emberjs/ember-rails"
```

Now running `bundle` gets us the latest and greatest(ish) of Embers. At the time of writing this is:

    $ bundle list | grep ember
      * ember-data-source (1.0.0.beta.7)
      * ember-rails (0.15.0 30fa5d2)
      * ember-source (1.5.1.1)

After bundling we can run

    rm -rf app/assets/javascripts
    rails generate ember:bootstrap

to actually setup Ember inside our Rails app. We start out by removing the existing Javascripts to make sure we're working on a reasonably blank slate here.

Now, let's set up a Rails controller/action that we can use to render the Ember application:

    rails generate controller ember index

and add to your `config/routes.rb`:

```ruby
root "ember#index"
```

To test this, restart your application server and access [http://0.0.0.0:3000](http://0.0.0.0:3000) in your browser. Your Javascript console should show some output from Ember:

    DEBUG: -------------------------------
    DEBUG: Ember      : 1.5.1
    DEBUG: Ember Data : 1.0.0-beta.7+canary.f482da04
    DEBUG: Handlebars : 1.3.0
    DEBUG: jQuery     : 1.11.0
    DEBUG: -------------------------------

Also, your browser should show the standard message from a newly generated Rails view:

> Ember#index
>
> Find me in app/views/ember/index.html.erb

All good? Great! Let's make it usable.

## UI

First, a little UI work. I promise, I'll keep it simple. Our views are handled by Ember, so we might as well get rid of what little HTML Rails have generated for us:

    $ echo > app/views/ember/index.html.erb

Now, let's give Ember something to show. First an application layout to show some navigation. Create `app/assets/javascripts/templates/application.handlebars`:

```html
{% raw %}
<nav>
  <ul>
    <li>{{link-to 'List books' 'books'}}</li>
  </ul>
</nav>

{{outlet}}
{% endraw %}
```

The contents above should be fairly self-explanatory, although you might want to dig more into the [Handlebars syntax](http://handlebarsjs.com/) to fully understand it.

One notable piece is `{% raw %}{{outlet}}{% endraw %}` which is similar to `<%= yield %>` like we know it from Rails ERB views; This is where output from other views will be displayed.

One of those other views is `app/assets/javascripts/templates/books.handlebars`, which you should create:

```html
{% raw %}
<h1>Books</h1>

<ul>
  {{#each}}
    <li>{{title}} by {{authorName}}</li>
  {{else}}
    <li>There are no books.</li>
  {{/each}}
</ul>
{% endraw %}
```

Again, fairly self-explanatory. Note the spiffy `each`...`else` construct.

## Routing

Now, if you visit [http://0.0.0.0:3000](http://0.0.0.0:3000) to see your masterpiece of a modern web application, you should get a big, fat Javascript error:

> Uncaught Error: Assertion Failed: The attempt to link-to route 'books' failed. The router did not find 'books' in its possible routes: 'loading', 'error', 'index', 'application'

This happens because we have yet to tell Ember what we mean by the `'books'` part of `{% raw %}{{link-to 'List books' 'books'}}{% endraw %}`.

This is done in the router, which ember-rails has handily placed in `app/assets/javascripts/router.js`. Change that file to look like

```javascript
Library.Router.map(function() {
  this.resource('books');
});
```

and the error goes away. Instead you get a nifty navigation link to "Books" at the top of the page.

Clicking that link gives us a new error:

> Uncaught Error: Assertion Failed: The value that #each loops over must be an Array. You passed (generated books controller)

Sigh, we just can't catch a break here.

## Connecting the final pieces

When we created a resource route above, we asked Ember to route requests for `'books'` to a `BooksController`. We never did write that controller, though, so Ember went ahead and generated one for us.

That's great, but for everything to work, we need some way of telling the controller what we want it to control, and subsequently the template to display.

### A route

We do that using a route. "Wait," you say, "didn't we already create routes?"

Why yes, we did create a *router*, but Ember has both the concept of a [router](http://emberjs.com/guides/concepts/core-concepts/#toc_router) and a [route](http://emberjs.com/guides/concepts/core-concepts/#toc_route). The router knows what templates to show given a specific URL, whereas a route

> "is an object that tells the template which model it should display"
> - http://emberjs.com/guides/concepts/core-concepts/#toc_route.

If you ask me, that's kind of confusing, but nevertheless, create `app/assets/javascripts/routes/books_route.js`:

```javascript
Library.BooksRoute = Ember.Route.extend({
  model: function() {
    return [{
      title: "Dummy data for dummies",
      authorName: "Me"
    }];
  }
});
```

This is our way of saying "when displaying data in the Books templates, please pretend this is the real data".

Eventually, we'll hook up a model and a data store and show some real data here, but for now we'll cope with dummy data.


## Look! No errors!

When you refresh the books page at [http://0.0.0.0:3000/#/books](http://0.0.0.0:3000/#/books) you should now see a list of your one book. More importantly; you should get no errors.


## Coming up

In the next parts of the series we'll look into showing actual data returned by the backend, and we'll add the ability to actually persist our Ember models on the backend.

[Continue to part 2: Reading data from the backend](/journal/2014/06/01/ember_on_rails_02/)

{% include ember_on_rails.html %}

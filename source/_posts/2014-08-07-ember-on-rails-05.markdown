---
title: "Ember on Rails: Nested views"
categories:
- programming
- technology
published: true
series: "Ember on Rails"
---

In todays instalment of [me trying to learn Ember in public](http://mentalized.net/journal/2014/06/01/ember_on_rails_01/) we'll look deeper into how Ember structures its views and what the connection is between routes, views, and templates.

This stuff definitely doesn't work like it does in Rails, so hang on.

<!--more-->

## I want an inline form

I'd like the "Add a new book" form to appear inline, directly above the list of books. There is no need to go to a whole new screen for a form as simple as that one.

A few, simple changes enables this (Bear with me, I'll explain later). First, we add an `{% raw %}{{outlet}}{% endraw %}` to the `books/index` template at app/assets/javascripts/templates/books/index.handlebars:

```handlebars
<h1>Books</h1>
{% raw %}{{outlet}}{% endraw %}
<ul>
  {% raw %}{{#each}}{% endraw %}
    <li>{% raw %}{{title}}{% endraw %} by {% raw %}{{authorName}}{% endraw %}</li>
  {% raw %}{{else}}{% endraw %}
    <li>There are no books.</li>
  {% raw %}{{/each}}{% endraw %}
</ul>
```

and then we move the modified `books/index` template to `books`:

```bash
$ mv app/assets/javascripts/templates/books/index.handlebars app/assets/javascripts/templates/books.handlebars
```

... and, well, that's it, really.

Now, if you go to your list of books, and click the "Add a book" link, the form pops up right where you placed the `{% raw %}{{outlet}}{% endraw %}`.

And it still works! You can enter stuff in the input fields and the new book is persisted when you click save (assuming [it is valid](http://mentalized.net/journal/2014/06/16/ember_on_rails_04/)). Magic!

## The magic is in the router

The secret to what's happening here (apart from magic, obviously) is found in the router. Our `router.js` looks like

```javascript
Library.Router.map(function() {
  this.resource('books', function() {
    this.route('new')
  });
});
```

This sets up the following routes for us:

* `application`
    * `books`
        * `books.index`
        * `books.new`

I have deliberately nested `books.index` and `books.new` inside the `books` namespace because that's how Ember sees them: They are siblings, nested under their parent route, `books`, which in turn is nested under `application`.

When Ember transitions between routes, it uses the view hierarchy above to figure out what goes where.

Generally speaking a route renders its template in the `outlet` of its parent template. Meaning that when you go from a parent template to a child template, the child will render inside the parent.

Likewise, when you transition between sibling templates, each replace the other as they are both rendered in the same outlet; i.e. that of the parent.


## So what really happened above?

We transformed the `book/index` template from a sibling of `books/new` to a parent.

When we renamed the template from `books/index` to `books`, we effectively moved the template up a level in the view hierarchy. This made `books/new` a child template, making it possible to render it in the `outlet` we added to `books`.


## It's views all the way down

One way of thinking about this is that it is simply taking the concept of outlets and extending it a bit further than we're used to from Rails.

In Rails we can include `yield` in our application layouts to insert the output from the current action/view. In Ember, we can include `outlet` in our application template to insert the output from the current view.

But where Rails stops at the action level, Ember doesn't. Ember views can be nested inside Ember views which are inside Ember views.

It really is views all the ways down.


{% include ember_on_rails.html %}

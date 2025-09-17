---
title: "Don't use instance variables in partials"
categories:
- programming
- Rails
description: "Instance variables have no place in Rails view partials. Unfortunately, they often end up there."
---

One of my favorite pet peeves is instance variables in partials. Unfortuntaly, I still encounter these in actual production code.

<!--more-->

I get it, it happens. You have a view template that needs cleaning up:

```ruby
# app/views/employees/show.html.erb
...
<% @meetings.each do |meeting| %>
  A bunch of code to render a meeting
<% end %>
...
```

Easy enough, just extract some parts of it into a [partial](https://guides.rubyonrails.org/layouts_and_rendering.html#using-partials):

```ruby
# app/views/employees/show.html.erb
...
<%= render("meetings") %>
...
```

```ruby
# app/views/employees/_meetings.html.erb
<% @meetings.each do |meeting| %>
  A bunch of code to render a meeting
<% end %>
```

Now you suddenly have an instance variable in the partial. No biggie, you think, it works perfectly fine and that instance variable is already defined.

## Why is this bad?

You’ve just coupled the partial to - not just the view - but the controller action, which is where the instance variable is defined.

If you ever need to use that partial in a different context it’ll break. If you remove the `@meetings` variable from the action (which isn’t unlikely because it’s obviously not being used in the view, so why even create it?) it’ll break. Boom, `NoMethodError: undefined method 'each' for nil`.

Instead, use locals. Even better, use [strict locals](https://masilotti.com/safer-rails-partials-with-strict-locals/). Or perhaps even better, [ViewComponents](https://www.viewcomponent.org), but that's out of scope for this article.

## Locals

If we instead rely on a local variable in the partial, the error would’ve been `undefined method or variable, meetings`, which is much more direct understandable:

```ruby
# app/views/employees/_meeting.html.erb
<% meetings.each do |meeting| %>
  A bunch of code to render a meeting
<% end %>
```

We can then use the partial like this:

```ruby
<% render("meetings", :meetings => @meetings) %>
```

While this is a bit more typing up front, it makes it painfully obvious what data the partial needs.

## Strict locals

To make it even more explicit what locals a partial needs, we can configure the partial to use strict locals. Effectively document the “method signature” for a partial:

```ruby
<%# locals (meetings:) %>
<% meetings.each do |meeting| %>
  A bunch of code to render a meeting
<% end %>
```

If we then try to render the partial without passing the `:meetings` local we’d get a `ArgumentError: missing local: :meetings` - again, much more explicit, understandable and actionable.

## Don't take my word for it

If you need more arguments against using instance variables in partials, just listen to [Andy Croll](https://andycroll.com/ruby/dont-use-instance-variables-in-partials/).

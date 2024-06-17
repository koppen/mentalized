---
title: "Introducing Classlist"
categories:
- software
- technology
description: "Classlist is a Ruby implementation of DOMTokenList for easier manipulation of CSS classnames in Ruby"
---

[We](https://substancelab.com) like [Tailwind CSS](https://tailwindcss.com/). And we like [ViewComponent](https://viewcomponent.org/). And we like using ViewComponent to encapsulate the long lists of CSS classnames you inevitably get using Tailwind CSS.

<!--more-->

So we made [Classlist](https://github.com/substancelab/classlist), a Ruby implementation of [`DOMTokenList`](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList), which is what [`Element.classlist` in the DOM](https://developer.mozilla.org/en-US/docs/Web/API/Element/classList) returns.

## What does it do?

[`Classlist`](https://gemdocs.org/gems/classlist/1.1.0/Classlist.html) allows us to create, manipulate and pass around lists of classnames like so:

```ruby
classes = Classlist.new
classes.add("rounded-full")
classes.add("w-24 h-24")
```

which we then can output in our components

```erb
<img class="<%= classes %>">
```

## That's not all

Classlist implements all the parts of the [`DOMTokenList API`](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList) (the parts that make sense in a server-side setting, at least). This allows us to both add, remove, replace, and toggle classnames in the list.

```ruby
classes = Classlist.new("text-lg") #=> "text-lg"
classes.add("font-medium") #=> "text-lg font-medium"
classes.remove("text-lg") #=> "font-medium"
classes.toggle("hidden") #=> "font-medium hidden"
classes.replace("font-medium", "font-bold") #=> "font-bold hidden"
```

## But wait, there's more

Ever so often you find that one exception to the rule, where the padding (or whatever) on a component needs to be different than everywhere else, and creating a whole new variant for this is too cumbersome.

Most our components now have a Classlist instance managing the class names on their outermost element. Something like

```erb
<div class="<%= classes %>">
  ... rest of the component goes here...
</div>
```

and they accept a list of CSS classnames when rendered:

```erb
<%= render(ButtonComponent.new(:classes => "bg-red")) %>
```

Using Classlist we can now manipulate the final set of class names on the component from the caller. If a button needs a different padding than the one already implemented, we can do

```erb
<%= render(ButtonComponent.new(:classes => Classlist::Remove.new("p-4") + Classlist::Add.new("px-3 py-2")) %>
```

This would remove a `p-4` class from the default list and add `px-3` and `py-2` without us having to implement and name an entirely new variant.

## Where can you get it?

Not only did we build Classlist, we've also open sourced it. We're already using this in a largish [Rails](https://rubyonrails.org/) + [Slim](https://github.com/slim-template/slim) + [View Component](https://viewcomponent.org) codebase, so if you've find yourself nodding at some of the above problems, do not hesitate giving it a run:

[https://github.com/substancelab/classlist/](https://github.com/substancelab/classlist/)

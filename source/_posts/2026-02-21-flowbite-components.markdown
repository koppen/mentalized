---
title: "Announcing Flowbite Components for Rails"
categories:
- programming
- projects
- technology
description: "Announcing our UI component library: A set of view components based on Flowbite."
date: 2026-02-21
---

[We](https://substancelab.dk)'re open sourcing our Flowbite component library, a set of view components, we're using in [Front Lobby](https://www.frontlobby.dk), [Skrift](https://www.skrift.eu), and a bunch of other projects, both internal and external.

<!--more-->

These days there's no shortage of UI kits for Rails. It seems [everybody](https://railsui.com/) [is building](https://railsdesigner.com/components/) [their own](https://railsblocks.com/) [design system](https://instrumental.dev/docs/ui-components) and selling a [component library](https://nitrokit.dev/) on top of it. We aren't that ambitious; we just want a gem we can include in all our projects and be off to the races, preferably open source so we don't have to bother with private gems.

Enter [flowbite-components](https://flowbite-components.substancelab.com): UI components for your [Rails](https://rubyonrails.org) application, built on [ViewComponent](https://viewcomponent.org/), [Tailwind](https://tailwindcss.com), and [Flowbite](https://flowbite.com), licensed under an MIT license, and ready to use today.

## Forms

A major driver for building [flowbite-components](https://flowbite-components.substancelab.com) was input fields.

A complete input field isn't just the input itself, but also its label, its error messages, and helper text. They have a bunch of states they can be in, like are there errors or is the control disabled, and they come in a multitude of types - all of which benefit from all of the above.

Rails' [form helpers](https://guides.rubyonrails.org/form_helpers.html) provide some building blocks for this, but we wanted a fully fledged experience we could bring along across projects, and still be sure that both the user experience is great, and the developer experience isn't restricted moving forward.

I think we've ended up on something that's both flexible and expressive:

```erb
<% form_with model: @user do |form| %>
  <%= render Flowbite::InputField::Text.new(attribute: :name, form: form) %>
  <%= render Flowbite::InputField::Email.new(attribute: :email, form: form) %>
  <%= render Flowbite::Button.new(type: :submit, content: "Save") %>
<% end %>
```

And of course, if you don't want to just use the defaults for a field, you have options for customizing each element of the [input field](https://flowbite-components.substancelab.com/docs/components/Flowbite::InputField):

```erb
  <%= render Flowbite::InputField::Text.new(
    attribute: :name,
    form: form,
    label: {content: "Full Name", class: "text-2xl"},
    hint: {content: "Enter your full name"}
  ) %>
```

## Getting started

Flowbite Components is available now on RubyGems and [GitHub](https://github.com/substancelab/flowbite-components/), and the documentation is [online](https://flowbite-components.substancelab.com/docs/components/Flowbite).

Do check out the [installation instructions](https://flowbite-components.substancelab.com/docs/getting_started), which unfortunately aren't as simple as I'd like them to, at this point.

## Why Flowbite?

There are many UI/design kits out there, so why Flowbite?

Flowbite has a bunch of things going for it.

- It's open source, MIT licensed, which means we can actually release this gem and not have it be a private gem just for us.
- It comes with both [dark and light mode](https://flowbite.com/docs/customize/dark-mode/), which pretty much is a must these days.
- It has a bunch of [premium pages and components](https://flowbite.com/blocks/), some of which are paid for, which makes me hopeful for its extensibility and longevity.
- Importantly, it has a comprehensive set of well designed [input components](https://flowbite.com/docs/forms/input-field/), with all the elements you need for a user-friendly CRUD interface.

Outside of that, I like the look and feel. Their [semantic classes](https://flowbite.com/docs/customize/variables/) and easy [themability](https://flowbite.com/docs/customize/theming/) just reinforces the choice.

## It's a work in progress

Today, we're officially releasing v0.2. Why not v1? We're still polishing and tweaking the API, so I am reluctant to commit to a v1 just yet.

Also, we're really far behind the [full set of components](https://flowbite.com/docs/components/accordion/). I mean, [we only have 9 so far](https://flowbite-components.substancelab.com/docs/components/Flowbite), which doesn't really warrant a v1.

## The future

Will we ever support all the components that Flowbite has designed? I honestly doubt it. For now we're extracting components from our existing application, and implementing new ones as we need them. If we never need a, say, [KBD](https://flowbite.com/docs/components/kbd/) component, we'll likely never see one.

That said, not all components need to live in a component library. [KBD](https://flowbite.com/docs/components/kbd/) is a good example of this; it's effectively a single `div` with a list of CSS class names. I am not sure exactly how much value is added by creating a `Flowbite::KBD` component for this.

Another thing I'd love to investigate is a form builder, perhaps similar to [Simple Form](https://github.com/heartcombo/simple_form). Being able to say

```erb
<% form_with model: @user, builder: Flowbite::Form do |f| %>
  <%= f.input :name %>
  <%= f.input :address %>
  <%= f.submit %>
<% end %>
```

and still get the full Flowbite experience would be pretty cool.

---
title: "Designing the API for a ViewComponent Input Group"
categories:
- technology
description: "Follow along as Jakob thinks out loud to come up with a sensible API for a set of customizable, general purpose form input components based on ViewComponent."

---

I've been working on a set of form input components based on the [ViewComponent](https://viewcomponent.org/) library. Unfortunately I've been having problems deciding on an API I like and this post is my attempt to think it through publicly.

<!--more-->

## The simple case

The simplest case for an input group is something like

```erb
<%= render(InputGroup.new(form, :name)) %>
```

which should render something like

```html
<label for="user_name">Name</label>
<input id="user_name" name="user[name]">
```

That's easy and straightforward to implement:

```ruby
class InputGroup < ViewComponent::Base
  erb_template <<-ERB
    <%= @form.label(@attribute) %>
    <%= @form.text_field(@attribute) %>
  ERB

  def initialize(form, attribute)
    @attribute = attribute
    @form = form
  end
end
```

## Specify the label text

Now, it's fairly common to change the text of the label to something other than the default, ie to get something like:

```html
<label for="user_name">Please enter your full name</label>
<input id="user_name" name="user[name]">
```

An API for this, which goes hand in hand with [what View Component already provides](https://viewcomponent.org/guide/slots.html#with_slot_name_content) is:

```erb
<%= render(InputGroup.new(form, :name).with_label_content("Please enter your full name)) %>
```

For this to work we need to implement a `LabelComponent` that uses the [`#content`](https://viewcomponent.org/api.html#content--string) accessor:

```ruby
class LabelComponent < ViewComponent::Base
  erb_template <<-ERB
    <%= @form.label(@attribute, content, **options) %>
  ERB

  def initialize(form, attribute, **options)
    @attribute = attribute
    @form = form
    @options = options
  end
end
```

and we need to use that component. Initially I thought I could use a [component slot](https://viewcomponent.org/guide/slots.html#component-slots) for this, but that doesn't work since we have to pass extra options (ie `@attribute` and `@form`) to the label. Well, we could make it work, but that'd require the consumer to pass those arguments for us:

```erb
<%= render InputGroup.new(form, :name) do |component| %>
  <% component.with_label(form, :name) { "Please enter your full name" } %>
<% end %>
```

and that's too repetitive and error prone. A better solution is to use a [lambda slot](https://viewcomponent.org/guide/slots.html#lambda-slots), which is intended to work as "wrappers for another ViewComponent with specific default values":

```ruby
class InputGroup
  ...
  renders_one :label, ->(**args, &block) do
    arguments = {
      attribute: @attribute,
      form: @form
    }.merge(args)

    LabelComponent.new(**arguments, &block)
  end
  ...
end
```

With that in place, we get the expected output:

```html
<label for="user_name">Please enter your full name</label>
<input id="user_name" name="user[name]">
```

So far, so good. However, while changing just the label text is a common usage case, it is also a simple case. There might be cases where the consumer wants to do crazy and do something entirely different for the label.

## Replacing the entire label

I want the consumers of my component to be able to do whatever they want for their labels. Perhaps they want to not have a label, or add more details to their labels, or otherwise go nuts, I'm not judging:

```html
<div>
  <label>Your username</label>
  <p>This will be used whenever you log in</p>
</div>
<input id="user_name" name="user[name]">
```

Using standard ViewComponent practices and slots that could look something like:

```erb
<%= render InputGroup.new do |component| %>
  <% component.with_label do %>
    <%= render(LabelWithDescription.new) %>
  <% end %>
<% end %>
```

Alas, this doesn't work as hoped. The return value of the block passed to `with_label` is used as the content for the `label` slot, which means we'll pass that content onto our `LabelComponent`, effectively rendering a `LabelComponent` with a `LabelWithDescription` inside it. That's not what we want.

(Aside: This begs the question; what is the actual difference between `with_label_content` and `with_label`? 🤔)

## Back to the drawing board...

The only way I know of where we can achieve that last part is by using a blank/anonymous slot definition:

```ruby
class InputGroup
  ...
  renders_one :label
  ...
end
```

However, this means we need to find a new way to handle the simple case, since

```erb
<%= render(InputGroup.new(form, :name).with_label_content("Please enter your full name)) %>
```

is now also going to just render whatever we pass to `#with_label_content`, ie without the wrapping `LabelComponent`. Thankfully, ViewComponent 4.0 introduces [`#default_SLOT_NAME`](https://viewcomponent.org/guide/slots.html#with_slot_name_content) methods, which is used to return whatever should be in a slot when content isn't provided.

This means we can do

```ruby
class InputGroup
  def default_label
    LabelComponent.new(@form, @attribute)
  end
end
```

to handle the simple case where no content is provided for the slot. We still need to find a way to specify custom text for the label, though. Instead of using `#with_label_content` we should be able to pass it as an argument, ie something like:

```erb
<%= render(InputGroup.new(form, :name, label: {content: "Please enter your full name"})) %>
```

To handle that we need to change our initializer:

```ruby
def initialize(form, attribute, label: {})
  @attribute = attribute
  @form = form
  @label = label
end
```

and our `default_label` method:

```ruby
def default_label
  label_options = @label.dup

  # Extract the content argument
  label_content = label_options.delete(:content)

  # Build a component with the remaining arguments
  component = LabelComponent.new(form, attribute, **label_options)
  if label_content
    # Pass the content argument as the content of the component if it exists
    component.with_content(label_content)
  else
    # ... otherwise just use the default
    component
  end
end
```

With the above in place, we're back in business. The following

```erb
<%= render(InputGroup.new(form, :name, label: {content: "Please enter your full name"})) %>
```

now renders

```html
<label for="user_name">Please enter your full name</label>
<input id="user_name" name="user[name]">
```

just like we want it to **and** we get the default behavior using

```erb
<%= render(InputGroup.new(form, :name)) %>
```

**and** we can replace the entire component with any content we desire:

```erb
<%= render InputGroup.new(form, :name) do |component| %>
  <% component.with_label do %>
    <h1>Who are you</h1>
    <%= form.label(:name, "What's your name?") %>
  <% end %>
<% end %>
```

## Bonus: Label attributes

The above way of doing things has a neat bonus; it makes it really easy for us to pass options to our label component. Say we want to add a CSS class to the label, this code

```erb
<%= render(InputGroup.new(form, :name, label: {class: "required"})) %>
```

should end up rendering

```html
<label for="user_name" class="required">User name</label>
<input id="user_name" name="user[name]">
```

Lo and behold, it already does. Since we pass everything in the `label` argument onto `LabelComponent` we've already implemented this. What a nice bonus.

## Conclusion

I think I am fairly happy with this API. It...

1. Gives us sensible defaults.
2. Allows us to easily override the most common default (ie label text).
3. Allows us to pass arguments to the label component to customize it.
4. Allows us to replace the label component entirely with something more fancy.
5. Paves a path forward where other slots can be customized in the same way, ie `render(InputGroup.new(form, :name, input: {class: "w-100"}))`.

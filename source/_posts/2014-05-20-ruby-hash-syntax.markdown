---
title: "Ruby Hash syntax"
categories:
- programming
- technology
published: true
---

Dear Ruby, I love you. But I just can't get used to that new-fangled Hash syntax of yours:

    h = {foo: :bar}

It smells of Javascript-envy, and it doesn't suit you.

<!--more-->

I know I am too late, I know I've had my chances at saying no, but I have to get this rant off my chest.

## It's confusing

When I come across the following, I get confused:

    h = {foo: :bar}

What the hell is that `foo`-thing? A method call `foo` followed by a colon? Or perhaps some sort of reversed symbol, `foo:`?

Surely, it must be something entirely different from `:bar`, which clearly looks entirely different.

There is no obvious way to reason about it, except knowing this special case rule that it's really a symbol, that looks like a method call.

And I'm [not the only](http://stackoverflow.com/questions/19443122/hash-declaration-syntax-error-in-irb) [one confused](http://stackoverflow.com/questions/19821748/new-ruby-syntax-doesnt-work-everytime) [by this](http://stackoverflow.com/questions/19352914/did-ruby-ever-support-this).


## It's inflexible

Alright, so since we know it's a symbol, we'd like to make that more obvious, so we change it to

    h = {:foo: :bar}

But nooooo, that's not how it works. Neither can we do

    h = {"foo": :bar}

It really is a very special case; nothing but Symbols can use `:` as a key/value separator. Lucky symbols, screw you other less worthy objects.

> "Only some symbol keys can be used in this fashion; for example, {:$set => 'b'} is valid whereas {$set: 'b'} is not. AFAIK, only symbols that are also valid labels can be used with the JavaScript-ish syntax." – [mu is too short](http://stackoverflow.com/questions/19352914/did-ruby-ever-support-this#comment28675727_19352928)

### Except in Ruby 2.2 (Updated 2015-02-02)

With the recent release of Ruby 2.2, the above is no longer accurate. With Ruby 2.2 you can indeed do

``` ruby
h = {"foo": :bar}
```

## It's implicit type coercion...

Ruby still really wants you to use a `Symbol`, though, so the key will stealthily (no warnings, nothing) be changed from a `String` to a `Symbol` behind your back:

``` ruby
h = {"foo": :bar} #=> {:foo=>:bar}
h["foo"] #=> nil
```

This is an example from a real life test suite testing some JSON API. The API responds with the following JSON:

```json
{
    "id": "folder_id"
}
```

which is tested (using RSpec):

```ruby
expect(response).to eq({"id": "folder_id"})
```

but this fails! Why? Because `"id":` doesn't mean the `String` `"id"`, (which is what is what the code explicitly says), but rather the `Symbol` `:id`:

```
     Failure/Error: expect(response).to eq({"id": "folder_id"})

       expected: {:id=>"folder_id"}
            got: {"id"=>"folder_id"}
```

😤


## You still have to use hash rockets

So even if you don't like the rockets, you still have to use them for the cases where you need `String`-based keys. This means you will likely have both JSON-style and Ruby-style hashes smattered between each other with no rhyme or reason.

And hey, if you're really lucky you might even end up with something like this eye-sore:

```ruby
{
  symbol: "It's a Symbol",
  "String" => "It's a String"
}
```

## It looks like keyword arguments, but isn't

Even though they appear exactly the same, the `foo: "bar"` in

``` ruby
h = {foo: "bar"}
```

is vastly different from the `foo: "bar"` in

``` ruby
def method(foo: "bar")
```

For example, as of Ruby 2.1 you can do

``` ruby
def method(foo:)
```

You can't do

``` ruby
h = {foo:}
```

It's special cases all the way down!


## Ruby doesn't really believe in it

Ruby doesn't even believe in the new syntax and returns hash-rocket style output:

``` ruby
h = { foo: 'bar' }
#=> {:foo=>"bar"}
```

It even expects hash-rockets if you accidentially trigger a syntax error (I accidentally left a trailing comma here):

``` ruby
method1 bar: baz,
new_method()

SyntaxError ((irb):8: syntax error, unexpected '\n', expecting =>)
```

## Get off mah lawn!

I get it. The new syntax lets old Ruby versions have something resembling named keyword arguments using a Hash instead - something Avdi showed in [RubyTapas episode 186 on Keyword Argument](https://rubytapas.dpdcart.com/subscriber/post?id=468).

That's a fine semantic meaning for that syntax. Use it for that, but don't use it anywhere else, where all it adds is confusion and inconsistencies.

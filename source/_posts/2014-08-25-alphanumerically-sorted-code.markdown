---
title: "I like my code alphabetically"
categories:
- programming
- technology
published: true
---

I have a confession to make. It might be some variant of OCD, or just stupid attention to pointless details, but I like to sort my code alphabetically.

Whenever there is a list of things where the order doesn't matter, I put them alphabetically. CSS rules, methods, constants, whatever.

<!--more-->

## Why do this insanity?

Apart from the neatness of things it tends to help me when I am looking for stuff.

The most obvious benefit comes when writing CSS (whatever the flavour). When I have a huge rule set with many declarations:

```css
.foo {
  margin-left: 0;
  width: 15em;
  background: #ddd;
  margin-left: 2em;
  border: 1px solid black;
}
```

it's easy to miss duplicate declarations, making it harder to spot potential problems. But when I sort them:

```css
.foo {
  background: #ddd;
  border: 1px solid black;
  margin-left: 0;
  margin-left: 2em;
  width: 15em;
}
```

the duplicated `margin-left` declaration is immediately obvious.

It becomes even more useful when trying to handle a merge conflict. Spotting the problem in the following code snippet, when attempting to solve the conflict isn't exactly easy:

```css
<<<<<<<<
padding: 1px;
color: #333;
margin: 2em;
==========
margin: 1em;
padding: 1em;
>>>>>>>>>
```

## It's not ambiguous

Developers love to argue. Should the initializer come before the attribute declarations, where do getter and setter methods go, how about callbacks, yadda yadda.

The alphabet isn't up for debate (well, not that much, at least). If the method name is sorted before another method, it goes before that other method. If not, it goes after.

If you do have doubts, throw your favorite language at the problem:

```ruby
["this!", "this?", "this"].sort
#=> ["this", "this!", "this?"]
```

End of discussion.

## It saves me from thinking

Whenever I go to add something to a list in a file, I have to consider where to put it. Do I just cram this attribute name at the end of this list or does it logically belong somewhere else?

When I sort the code alphabetically this has already been answered for me.

I like not having to think too much, so having this decision made for me is great.

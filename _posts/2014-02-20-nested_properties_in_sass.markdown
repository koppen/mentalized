---
layout: post
title: Nested properties in Sass
date: '2014-02-20 13:11:49 +0100'
mt_id: 2173
categories:
- programming
- webdesign
- technology
---
I have been using [Sass](http://sass-lang.com/) for ages and I never realized I could do:

    margin:
      top: 1em
      bottom: 2em

and have it compile to:

    margin-top: 1em;
    margin-bottom: 2em;

This is a great timesaver for all those `background-image`, `margin`, `padding`, `border` declarations.


<!--more-->

## Nesting several levels deep

It even allows deeper levels of nesting, so you can do:

    border:
      top:
        style: dashed
        left:
          radius: 1em

to get:

    border-top-style: dashed;
    border-top-left-radius: 1em;

I guess that'll teach me to [RTFM](http://sass-lang.com/documentation/file.SASS_REFERENCE.html#nested_properties).

---
layout: post
title: Nested properties in Sass
date: '2014-02-20 13:11:49 +0100'
mt_id: 2173
categories:
- programming
- technology
- webdesign
---
I have been using [Sass](http://sass-lang.com/) for ages and I never realized I could do:

{% highlight sass %}
margin:
  top: 1em
  bottom: 2em
{% endhighlight %}

and have it compile to:

{% highlight css %}
margin-top: 1em;
margin-bottom: 2em;
{% endhighlight %}

This is a great timesaver for all those `background-image`, `margin`, `padding`, `border` declarations.

<!--more-->

## Nesting several levels deep

It even allows deeper levels of nesting, so you can do:

{% highlight sass %}
border:
  top:
    style: dashed
    left:
      radius: 1em
{% endhighlight %}

to get:

{% highlight css %}
border-top-style: dashed;
border-top-left-radius: 1em;
{% endhighlight %}

I guess that'll teach me to [RTFM](http://sass-lang.com/documentation/file.SASS_REFERENCE.html#nested_properties).

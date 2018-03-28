---
title: Viewport-relative, scalable text
published: true
categories:
- webdesign
- mentalized.net
---
When creating fluid designs, [controlling the line length](http://www.simonstratford.com/ideal-line-length/) is a challenge. You don't want your lines to expand indefinitely, making them unreadable, even if the layout can expand indefinitely. This article details how I solved the problem on [mentalized.net](/).

<!--more-->

## `max-width` is old-school

The traditional approach is to set a `max-width` on your content element. This works great, but can create way too much whitespace on large viewports, leaving your content floating in the middle of a sea of whitespace.

When I redesigned [mentalized.net](/) to be fluid and responsive and otherwise make it buzzword compliant, I opted for a somewhat different approach.

I used [viewport-relative, scalable text](http://css-tricks.com/viewport-sized-typography/) sizing.

Try resizing your browser window. Apart from your run-of-the-mill responsiveness at smaller displays, the text starts growing larger as your viewport increases above a certain threshold.

## vw: Viewport width

The work horse behind this trick is [`vw`](http://www.w3.org/TR/css3-values/#viewport-relative-lengths) - a CSS unit that is relative to the viewport. This means that `1vw` is equal to 1% of the viewports width (and `1vh` is equal to 1% of the height).

Where we’re used to setting the width of an element to a specific amount of pixels (using `50px`), we can nowadays use `50vw` to set the width to 50% of the viewports width.

This unit naturally works for font-sizes as well. So if your  viewport is 1000 pixels wide and you set `font-size: 1em`, you have effectively set the `font-size` to `10px` (1% of 1000 pixels). If the viewport is then changed to only be 500 pixels wide, the font size will change to `5px`.

## Using this one, weird trick…

Setting our font-size relative to the viewport width has the effect of ensuring or content always has the same size - relative to the viewport.

Line lengths stay the same, word wrapping appears exactly in the same place - all regardless of the width of the browser.

## This isn’t just for text

Scaling your font size with your viewport is intriguing for sure, but the potential is even greater. It also proves vastly more reliable than previous techniques for making your layout fluid.

Percentage units go a long way for making fluid layouts. The problem is they are measured relatively to their parent elements. Which means that when you are 4 levels deep in parent elements it gets really tricky figuring out exactly what those 2% are going to be.

And good luck trying to size out borders, margins and paddings using percentages. It _is_ doable, but it quickly ends up being unwieldy.

Viewport-relative units give us the benefits from both fixed units like `px` and `em` and relative units like `%`, practically without any of the drawbacks.

## Practicalities

What I have found to be the most effective way of controlling your scalable design is to have one central, scalable font-size setting.

That base setting is the one you make scalable using the `vw` unit. Every other font-sizes is made relative to that base, using another favourite of mine; the good old `em` unit.

This ensures that we get to control the overall size of our design in just one place. If we need to make exceptions and changes using media queries, this also provides a single location to do it.

## Downsides

Now, scaling your designs with the width of your users viewport does come with some drawbacks.

1. You don’t actually know what size your site is going to be, so you’ll want to make sure to scale everything; images in particular.
2. If your visitors have wide displays with wide browsers your font sizes can grow to levels suitable for billboards. These are outliers, though, and it should be fairly easy to remedy with a media query.
3. [Browser support isn’t 100% yet](http://caniuse.com/#search=vw). It’s currently clocking in at only 77%. Luckily the fallback is reasonably easy and you could simple use `px` or `em` for those browsers without support for `vw`.

If you want to read more about this, [CSS-tricks has a fine introduction to viewport-sized typography](http://css-tricks.com/viewport-sized-typography/).

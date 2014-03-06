---
layout: post
title: 'Internet Explorer 6: The legacy'
date: '2013-06-19 07:40:52 +0200'
mt_id: 2165
categories:
- browsers
---
[Internet Explorer 6 is dead](http://www.netmagazine.com/news/ie6-declared-dead-usa-121668) ([almost](http://www.ie6countdown.com/)). It has been for while, we've buried it, danced on [its grave](http://www.ie6death.com/), and paved over the cemetery. And good riddance.

But the [most-hated browser in history](http://www.ironpaper.com/current/2012/01/web-designers-most-hated-browser-is-almost-a-thing-of-the-past/#.UcFb-PbXgt0) wasn't all bad - it turns out that it actually did do some things right.

<!--more-->

## Border-box

A common gotcha writing CSS is the fact that element widths aren't necessarily the width you specify; the width of an element is actually the sum of the specified width + padding + borders.

But not in <abbr title="Internet Explorer 6">IE6</abbr> - at least in quirks mode. Contrary to the CSS spec it insisted on using the literal width you'd specified. In many cases, this is way easier to work with. Thus, it has been introduced into CSS as [`box-sizing: border-box`](https://developer.mozilla.org/en-US/docs/Web/CSS/box-sizing) - thanks to IE6.


## Inline block elements

Another thing IE6 seemingly got right - again, in spite of the CSS spec - was its interpretation of `display: inline`. Normally, you can't set width and height and other block-like rules on inline elements. But psh, who cares - in IE you could.

Turns out, that idea was so useful that we've now [standardized and dubbed it](http://www.w3.org/wiki/CSS/Properties/display) `display: inline-block`.


## Embedded fonts

Over the last few years, the use of custom fonts on websites have soared thanks to services like [Typekit](https://typekit.com/) and [Google Fonts](http://www.google.com/fonts/) - all powered by the `@font-face` declaration, which [Internet Explorer introduced](http://www.standardista.com/css3/font-face-browser-support/). [back in version 4](http://www.zeldman.com/2009/05/23/web-fonts-now-how-were-doing-with-that/).

However, true to form Microsoft insisted on the proprietary EOT format for the embedded fonts - a format no other browser supported. Go figure.


## Dynamic calculations in CSS

CSS3 introduced the [`calc()`](http://www.w3.org/TR/css3-values/#calc) function that can be used in CSS:

    width: calc(100%/3 - 2*1em - 2*1px);

which can be incredibly useful. That's also what Microsoft thought, when they introduced [dynamic properties](http://msdn.microsoft.com/en-us/library/ms537634%28v%3Dvs.85%29.aspx) in Internet Explorer 5. Albeit not quite as powerful as `calc()` - and supposedly quite a bit more broken - dynamic properties did allow you to do stuff like

    <div style="left:expression(document.body.clientWidth/2-oDiv.offsetWidth/2)"></div>


## Vector graphics

With resolution independence becoming ever more important, the need for a scalable, non-raster graphics format increases. Internet Explorer dating back to IE5 supported [VML](http://en.wikipedia.org/wiki/Vector_Markup_Language) - which was exactly that.

These days, [SVG](http://www.w3.org/TR/SVG11/) is the format to use. SVG is [based in parts on VML](http://en.wikipedia.org/wiki/Scalable_Vector_Graphics#Overview). As a somewhat ironic turn of events, VML is exactly how you'd [polyfill SVG](http://code.google.com/p/svgweb/) in old Internet Explorers.


## XMLHttpRequest

XMLHttpRequest puts the X in AJAX and pretty much enables the current breed of highly responsive interactions in websites and -applications. 

While IE6 didn't introduce XMLHttpRequest - it was actually introduced in IE5 as part of the MSXML ActiveX component - [IE6 did support it]((http://en.wikipedia.org/wiki/XMLHttpRequest#Support_in_Internet_Explorer_versions_5.2C_5.5.2C_and_6) and was around when AJAX started getting popular.


## RIP

When Internet Explorer was released, it was an advanced browser with tons of useful features and it has played its part in moving the web forward.

Unfortunately, thanks to a bunch of odd choices - and [outright bugs](http://css-tricks.com/ie-css-bugs-thatll-get-you-every-time/) - in its rendering engine and Microsofts negligence in its later years, the legacy of Internet Explorer 6 isn't something we'll look back on with favorable eyes.

Goodbye IE6, we knew you all too well.

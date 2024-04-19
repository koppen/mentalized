---
title: "Putting Zendesks web widget on Turbolinks"
date: '2019-04-26 13:43:23 +0200'
categories:
- programming
- technology
description: "How we managed to embed Zendesks web widget in a Rails application running Turbolinks"
---

[We](https://substancelab.dk) were recently asked to add [Zendesks](https://zendesk.com) [Web Widget](https://www.Zendesk.com/embeddables/) to one of our [customer web applications](https://bornibyen.dk).

"No problem", we thought, because as Zendesk says:

> All it takes to add the Web Widget to your website is a snippet of Javascript.

Little did we know that this would turn into a task that we would struggle with on and off for well over a month...

<!--more-->

## Let's talk about Turbolinks

Thing is we use [Turbolinks](https://github.com/turbolinks/turbolinks) on this particular application - and many other applications for that matter.

If you're not familar with how and what Turbolinks does, it basically turns your server-rendered application into a Single Page Application by not fetching and parsing static assets like Javascript and stylesheets on every request.

In more detail, a Turbolinks flow looks like:

1. Initial page load when the user loads your site:
  * The HTML document is fetched from the server and rendered clientside
  * All Javascript and stylesheets are processed
2. Next page load when the user clicks a link:
  * The HTML document is fetched from the server
  * Changes to the `head` element are merged into the existing `head`.
  * The `body` is extracted and inserted into the current document, replacing the existing `body`.
  * The new body is rendered clientside.

The major benefit is in only processing scripts once, which proves for faster page views. The major downside is the fact that your Javascript is now long-running across requests and the events you're used to relying on, like jQuerys `$(document).ready()` or `DOMContentLoaded`, no longer work as expected.

It's all well and fine and [documented](https://github.com/turbolinks/turbolinks#full-list-of-events), though.

## Back to Zendesk

### Attempt 1

Flash back to the first day where we optimistically tried using Zendesks guide to installing their web widget. Just throw a simple `<script>` tag in the `head` of your site and everyhing works:

```html
<!-- Start of computerzen Zendesk Widget script -->
<script id="ze-snippet" src="https://static.zdassets.com/ekr/snippet.js?key=re-dac-ted"></script>
<!-- End of computerzen Zendesk Widget script -->
```

And on the face of things everything works, right up until we clicked a link to navigate to another page, where the widget never appeared. This makes sense, as the above is only loaded once on the initial page load and not all the following page visits.

### Attempt 2

A common way around this is to shove the snippet into the `body` of the page. Scripts in the `body` are evaluated when they are loaded/rendered, so that makes a lot of sense. And indeed, we could see the snippet being loaded on every page visit, but the widget only appeared on the first page load.

### Attempts n + 1

Around this point we started reaching out to Zendesks support, who turned out to be very helpful, and had a bunch of suggestions for things we could try; none of them worked, unfortunately.

During this time, we tried everything we could think of.

* Loading the snippet via a dynamic `script` element inserted into the DOM in a `turbolinks:render` event
* Calling every function we could find in the documentation; `zE.setSuggestions` was a suggestion from support, whereas personally I had high hopes for `zE.show` or `ze.activate`.
* Using Turbolinks' support for [permanent elements](https://github.com/turbolinks/turbolinks#persisting-elements-across-page-loads) to ensure the widget wasn't replaced during navigation.
* Decompiling (or whatever the Javascript term is) Zendesks massive web widget script in order to figure out what was actually going on.
* ... and probably a bunch of even more desperate things

In the end, what worked, was changing a single global variable...

## The solution

During our spelunking in Zendesks code, we noticed a single variable named `zEACLoaded`, which seemed to guard actually setting up the web widget. A thesis quickly formed at this point:

> What if the web widget tries to track that it has been loaded to avoid issues where people accidentally included it twice on the same page?

In the usual tear-everything-down-after-each-page-view way of life that'd make perfect sense. And in the Turbolinks (and SPA) world of keep-everything-around-indefinitely, that could result in the widget actively refusing to set itself up on subsequent page visits. Exactly the behavior we could observe.

If indeed that was the case, all we needed to do was to remove whatever the widget left lingering. And as long as we did that before rendering the next body element, the existing snippet should be able to be loaded from the `body` element and work as expected.

Behold the solution:

```javascript
window.addEventListener('turbolinks:before-render', function () {
  window.zEACLoaded = undefined;
});
```

Aint web development grand?

## Giving back

We have [submitted the instructions](https://github.com/reed/turbolinks-compatibility/pull/88) above to the [Turbolinks Compatibility project](http://reed.github.io/turbolinks-compatibility/) - a great resource which unfortunately seems more or less dead?

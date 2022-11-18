---
title: "My beef with Tailwind UI"
categories:
- development
- technology
description: "Tailwind CSS and Tailwind UI are great, but I must admit; as a long-time semantic-markup-separation-of-concerns-advocate, there are some issues."
---

I like [Tailwind UI](https://tailwindui.com). I like the aesthetics, the clearly well-thought out ideas that has gone into it, and I am in awe of the business it has spawned. Massive kudos to the Tailwind team. However, I have some things I need to get off my chest.

<!--more-->

## "Tailwind is just inline styles"

Let me get this peeve out of the way first. Being a longtime standards advocate and proponent of separation of concerns littering my markup with CSS class upon CSS class does not sit well with me.

In principle... In reality it turns out that it isn’t that big a deal. Or at least, I find the trade-off worth it.

And let's be clear, claiming you might as well be writing inline styles instead of [Tailwind](https://tailwindcss.com) classes isn't a fair comparison. There's a lot of magic happening in Tailwind that couldn't be reproduced with `style="display: flex"` or whatever.

## You pretty much need a component library

Tailwind in raw HTML gets tedious. It's fine for a single page, but outside of that you're quickly overwhelmed by the onslaught and repetitiveness of long class lists. You'll soon find yourself in a position where you have 3 call-to-action-links which appear to look the same, but have different classes applied - or the same classes in a different order. How do you find them all to change their background-color in that case?

You pretty much need a component library. Or at least something like Rails partials. Which leads us to...

## Actually implementing components

Consider these two sample buttons from [Tailwind UI](https://tailwindui.com) (uh, am I breaking the license now? 😬):

```html
<button class="inline-flex items-center px-4 py-2 border border-gray-300 text-sm leading-5 font-medium rounded-md text-gray-700 bg-white hover:text-gray-500 focus:outline-none focus:shadow-outline-blue focus:border-blue-300 active:text-gray-800 active:bg-gray-50 transition duration-150 ease-in-out">
```

```html
<button class="inline-flex items-center px-4 py-2 border border-transparent text-sm leading-5 font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-500 focus:outline-none focus:shadow-outline-indigo focus:border-indigo-700 active:bg-indigo-700 transition duration-150 ease-in-out">
```

What exactly are the differences between them? Are they the same component in different states? What's going on? Did you spot the one class that shouldn't be there? Or the one you missed adding for the hover state to work perfectly? Componentizing, debugging or maintaining code like that is not easy.

## Licensing

Tailwind UI is impressive. It's a great component library and I love seeing an open source based business rake in money. However, that business is also getting in the way of me really liking Tailwind.

We build a bunch of projects, both customer-facing and internal. I'd love to be able to create a gem or some repository with TailwindUI view components that I could include in all those projects.

I wouldn't be able to distribute it publicly, though, as Tailwind UIs licensing - understandably -prevents that. And I get it, I really do, it's just that private repositories as dependencies are a pain in the ass. Especially when you have multiple developers, CI, and production servers involved.

So we're left with having to copy/paste view components, which quickly becomes unmaintainable as the number of projects increase.

Just use another component library, you say? That's a great idea, but all the good ones (I know of) want a piece of those Tailwind UI riches so their licenses are the same - or, to be blunt, they aren't as good. It's funny what a bunch of cash can do for a project 🙄

## Classes are required

Let's talk about links. So you have a website and you've included Tailwind like you're supposed to and it's all looking fine - but then you add a link. It looks just like the surrounding text. No special color, no underline, no hover state (although it does have a pointer cursor).

So every single `a` tag needs to have `class="text-purple hover:underline hover:text-purple-light"` or whatever. Every single one. That's not feasible. So you can extract a Link component, but who does that when we already have perfectly fine link components, called [`a`-tags](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a).

[https://twitter.com/rleggos/status/1388192048466038794](https://twitter.com/rleggos/status/1388192048466038794)

Alternatively, we can [style the a tag](https://tailwindcss.com/docs/adding-base-styles) using `@apply`, but doesn't that go against the point of Tailwind and we lose the rapid prototyping bit having to wait for CSS compilation on every change:

```css
@layer base {
  a {
    @apply hover:underline;
    @apply text-purple;
  }
}
```

## The HTML-requirement

Tailwind is huge. Tailwind uses [PurgeCSS](https://purgecss.com/) to reduce its size for production. PurgeCSS expects you to write HTML. I don't like HTML, all those damn angle brackets 😉

We write pretty much everything in [Slim](http://slim-lang.com/). Easier to write and can be formatted perfectly on output. Unfortunately this makes it kind of hit and miss whether classes are removed from the final stylesheet - yay for things that only break once in production.

I guess we could generate HTML/erb first, then have PurgeCSS parse those, as [part of our build step](https://blog.minthesize.com/purgecss-with-slim-templates), but that just seems like added fragility and issues waiting to happen.

## In conclusion

For sure, I am being partially facetious above - and none of those issues have turned out to be deal-breakers for us. I like Tailwind. I like Tailwind UI. [We](https://substancelab.dk)'ll continue to use them both, I am sure.

It's all good. I just guess there are no silver bullets for UI implementation, still.

Aw shucks.

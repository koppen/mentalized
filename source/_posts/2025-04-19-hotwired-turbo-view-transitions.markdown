---
title: "Driving View Transitions with Hotwired/Turbo"
categories:
- technology
---

View transitions between pages has been a reality on the web for quite a while now (at least in the browsers that support it). It has also been possible to use them with Turbo, albeit somewhat [cumbersome](https://dev.to/nejremeslnici/how-to-use-view-transitions-in-hotwire-turbo-1kdi), but that's changed. [Turbo](https://turbo.hotwired.dev/) now has built-in support for the [View Transitions API](https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API) as of version 8+.

<!--more-->

## Opt in to view transitions in Turbo Drive

First of all, ensure you’re using [a browser with View Transitions support](https://caniuse.com/view-transitions), ie not Firefox, alas.

All we have to do to enable Turbos built-in support for view transitions is [add a meta tag](https://turbo.hotwired.dev/handbook/drive#view-transitions) to our page(s):

```html
<meta name="view-transition" content="same-origin">
```

… and that’s it! When you navigate between pages you now get the default crossfading transition.

<figure class="double">
  <video controls src="https://res.cloudinary.com/substancelab/video/upload/f_auto,q_auto,w_1024/v1745068281/mentalized/hotwired-turbo-view-transitions/default-transition.mp4" title="Default view transition"></video>
</figure>

## Make it easier to see what's going on

In the real world we don't want the transitions to take more than a few hundred miliseconds, if that. Any longer and the app starts feeling slow and sluggish. Remember, the transition cannot start until the new page has been actually loaded, so the transition does indeed slow down the user.

However, for debugging it can be beneficial to slow the transitions down so we can actually see what's happening. We can do that by target the view-transition pseudo elements and set their animation duration:

```css
::view-transition-old(root),
::view-transition-new(root) {
  animation-duration: 5s;
}
```

<figure class="double">
  <video controls src="https://res.cloudinary.com/substancelab/video/upload/f_auto,q_auto,w_1024/v1745068281/mentalized/hotwired-turbo-view-transitions/slow-transition.mp4" title="Default view transition slowed down"></video>
</figure>

## Animate the outgoing page

The default crossfade is boring, though, let’s spice it up.

A great thing about the view transition animations is that they are just standard CSS animations. This means we can use pretty much all the tricks and timing functions, we're used to. Let’s define an animation that moves an element left and fades it out:

```css
@keyframes exit-left {
  0% {
    transform: translateX(0);
    opacity: 100%;
  }
  100% {
    transform: translateX(-100%);
    opacity: 0%;
  }
}
/* ... and apply it to the leaving page */
::view-transition-old(root) {
  animation-name: exit-left;
  animation-timing-function: ease-in;
}
```

By applying this animation to the `::view-transition-old` element, we’ve made the existing page look like it disappears stage left, while the new page still crossfades in.

<figure class="double">
  <video controls src="https://res.cloudinary.com/substancelab/video/upload/f_auto,q_auto,w_1024/v1745068281/mentalized/hotwired-turbo-view-transitions/old-exit-left.mp4" title="Animate the old page out to the left"></video>
</figure>

## Animate the incoming page

Let’s change how to new page appears by adding a new animation that makes it appear to come in from the right:

```css
@keyframes enter-left {
  0% {
    transform: translateX(100%);
    opacity: 0%;
  }
  100% {
    transform: translateX(0%);
    opacity: 100%;
  }
}
::view-transition-new(root) {
  animation-name: enter-left;
  animation-timing-function: ease-out;
}
```

<figure class="double">
  <video controls src="https://res.cloudinary.com/substancelab/video/upload/f_auto,q_auto,w_1024/v1745068281/mentalized/hotwired-turbo-view-transitions/new-enter-left.mp4" title="Animate the new page in from the right"></video>
</figure>

This looks pretty neat, huh? Now, you can obviously play with [timing functions](https://developer.mozilla.org/en-US/docs/Web/CSS/animation-timing-function) and animations to your hearts content and creative ability.

## Going directions

View transitions appear on all page changes – not just the ones triggered by Turbo Drive. This also means, that when we click the Back button, we go back to the previous page with a pretty transition. However, the animation is the same as when we navigate by clicking.

<figure class="double">
  <video controls src="https://res.cloudinary.com/substancelab/video/upload/f_auto,q_auto,w_1024/v1745068281/mentalized/hotwired-turbo-view-transitions/restored-page-enters-left.mp4" title="Pages from history still arrive moving in from the right"></video>
</figure>

 Since the page we navigate to by using the back page is seen by view transitions as a new page (even though it’s actually a page from the cache) it will be animated as a new transition and enter from the right, which looks unexpected.

Luckily, [Turbo has our back](https://turbo.hotwired.dev/handbook/drive#view-transitions) here:

> Turbo also adds a `data-turbo-visit-direction` attribute to the `<html>` element to indicate the direction of the transition. The attribute can have one of the following values:
>
> * forward in advance visits.
> * back in restoration visits.

This means we can modify our CSS selectors and change the animations based on what direction we’re going; **forward** when we're moving forward in the history using links or the forward button, and **back** when using the back button.

## Only slide forward

So let’s start by ensuring we only use our left-moving animations when we navigate forward:

```css
html[data-turbo-visit-direction="forward"] {
  &::view-transition-new(root) {
    animation-name: enter-left;
    animation-timing-function: ease-out;
  }

  &::view-transition-old(root) {
    animation-name: exit-left;
    animation-timing-function: ease-in;
  }
}
```

Doing this and we get our fancy animation when we navigate forward, ie click on links, and the default crossfade when going back by using the back button.

<figure class="double">
  <video controls src="https://res.cloudinary.com/substancelab/video/upload/f_auto,q_auto,w_1024/v1745068281/mentalized/hotwired-turbo-view-transitions/restored-page-fades-in.mp4" title="Pages from history now crossfade in"></video>
</figure>

## Slide history pages in

We can improve the back animation, for example to have it go the other way of the forward animation. Let’s start by adding two animations going the other way, ie one that enters going right and one that exits going right:

```css
@keyframes exit-right {
  0% {
    transform: translateX(0);
    opacity: 100%;
  }
  100% {
    transform: translateX(100%);
    opacity: 0%;
  }
}
@keyframes enter-right {
  0% {
    transform: translateX(-100%);
    opacity: 0%;
  }
  100% {
    transform: translateX(0%);
    opacity: 100%;
  }
}
```

We can then use those animations when the navigation direction is “back”:

```css
html[data-turbo-visit-direction="back"] {
  &::view-transition-new(root) {
    animation-name: enter-right;
    animation-timing-function: ease-out;
  }

  &::view-transition-old(root) {
    animation-name: exit-right;
    animation-timing-function: ease-in;
  }
}
```

<figure class="double">
  <video controls src="https://res.cloudinary.com/substancelab/video/upload/f_auto,q_auto,w_1024/v1745068281/mentalized/hotwired-turbo-view-transitions/restored-page-enters-right.mp4" title="Pages from history arrive moving right"></video>
</figure>

## Animate just part of the page

Until now we’ve animated the entire page, which is a bit much. Let’s say we want our slide animations to apply only to the main content area of the page. In this case that area is wrapped in an `article` element. We can target that to give it a specific [view transition identifier](https://developer.mozilla.org/en-US/docs/Web/CSS/view-transition-name):

```css
article {
  view-transition-name: article;
}
```

If we then change all our previous `::view-transition-new(root)` selectors to `::view-transition-new(article)` and the same for `::view-transition-old(root)` , which becomes `::view-transition-old(article)`, we get an entirely different experience:

<figure class="double">
  <video controls src="https://res.cloudinary.com/substancelab/video/upload/f_auto,q_auto,w_1024/v1745068281/mentalized/hotwired-turbo-view-transitions/animate-article-element.mp4" title="Only the content section of the pages are transitioned"></video>
</figure>

(I've also changed the animation duration here to more realistic values).

## Further reading

* [Avi Flombaums guide to View Transitions with Turbo](https://code.avi.nyc/turbo-view-transitions-in-rails)
* [View Transition API on MDN](https://developer.mozilla.org/en-US/docs/Web/API/View_Transition_API)

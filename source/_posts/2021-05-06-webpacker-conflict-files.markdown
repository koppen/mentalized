---
title: "Webpacker 6 conflicts with .br extensions"
categories:
- development
- technology
description: "Running Webpacker with a v6 pre-release and/or beta, you might see errors saying you have conflicting assets named something .br. This shows how to fix it."
---

TLDR; if `rake assets:precompile` gives you `ERROR in Conflict: Multiple assets emit different content to the same filename js/.br` you probably need to upgrade Webpacker.

<!--more-->

## Longer version

[We](https://substancelab.dk) recently started a new [Rails]() project and set everything up with all the most recent goodness ([Webpacker 6](https://github.com/rails/webpacker), [Turbo](https://turbo.hotwire.dev/), [Tailwind](https://tailwindcss.com/) etc). All was great with sparkles and rainbows, but when it came to deployment,  `rake assets:precompile` gave us the following errors:

```
ERROR in Conflict: Multiple assets emit different content to the same filename js/.br
ERROR in Conflict: Multiple assets emit different content to the same filename .br
```

We were dumbfounded because we had no files anywhere named anything with `.br` - we didn't even know what the extension meant. We went as far as to establish theories that it might be `.rb` file that somehow got reversed, or perhaps `br` tag from a Slim file that somehow got into our Webpack pipeline.

Turns out, it's the file extension for [Brotli](https://en.wikipedia.org/wiki/Brotli)-compressed files.

## It's a bug, not a feature

Turns out, it was [a bug](https://github.com/rails/webpacker/issues/2828) in a pre-release of Webpacker. However, the bug [has long been fixed](https://github.com/rails/webpacker/pull/2830/) and a fixed version released, so we couldn't figure out why we'd still be seeing it.

After all, our `package.json` included

```
"@rails/webpacker": "^6.0.0-beta.7"
```

which is supposed to be the most recent version at the time of writing.

## What's in a caret?

However, what we hadn't realized, was exactly how [Yarn](https://yarnpkg.com/) interprets `^` and `pre` and `beta` releases.

`^` tells Yarn to use the most recent minor version of the package (so ie if you have `^1.2.3` it allows `1.3.0` to install. But in Yarn(NPM?) land `pre` > `beta`, so `^6.0.beta` allows `6.0.pre` to be installed. Go read [Michaels fine explanation of this](https://michaelsoolee.com/npm-package-tilde-caret/).

So in effect, we were installing webpacker-6.0.0-pre.2, which had the above bug. After changing the dependency to `"@rails/webpacker": "6.0.0-beta.7"` all was well again.

Ah, dependency management 🙄

---
title: "How to deploy i18n-js to Heroku when using jsbundling"
categories:
- software
- technology
description: "If you're having problems deploying a Rails application using esbuild, webpack and i18n-js to Heroku, this might be the solution."
---

We recently released a big frontend upgrade to [Front Lobby](https://www.frontlobby.dk). This included an upgrade to [i18n-js](https://github.com/fnando/i18n-js) v4 which ended up causing problems when deploying to Heroku. Here's how we fixed it.

<!--more-->

## The problem

When we tried to deploy we got the following error during Herokus build phase:

```
ERROR in ./app/javascript/i18n.js 3:0-47
  Module not found: Error: Can't resolve './translations.json' in '/tmp/build_36012f77/app/javascript'
  resolve './translations.json' in '/tmp/build_36012f77/app/javascript'
```

This is the error you'd get if i18n-js hasn't exported its translations to `translations.json` yet, as it is supposed to.

## The setup

Now, some relevant details of our setup:

* [i18n-js](https://github.com/fnando/i18n-js) 4
* [jsbundling](https://github.com/rails/jsbundling-rails) 1.2
  * Using [webpack](https://webpack.js.org/) 5.9
* Deployed to [Heroku](https://dashboard.heroku.com/)

## The common approach

The commonly recommended way to ensure your translations are available in your frontend assets is to have them exported during the `assets:precompile` task is run. In our case we need to hook into the `javascript:build` task, which is what [jsbundling](https://github.com/rails/jsbundling-rails) uses to compile assets.

To do so we've added the following rake task, which works just fine - at least in development 🙄:

```ruby
namespace :i18n do
  namespace :js do
    desc "Exports translations to be used by i18n-js"
    task :export => :environment do
      `bundle exec i18n export`
    end
  end
end

# Run `i18n export` prior to building Javascript assets, so translations are
# available for use. javascript:build is the rake task run by jsbundling
# during assets:precompile
Rake::Task["javascript:build"].enhance(["i18n:js:export"])
```

(Depending on your build system the above may vary; there are more examples at [the i18n-js discussions](https://github.com/fnando/i18n-js/discussions/710).

Alas, for some reason the above rake task didn't do the trick for us when deploying.

## Buildpacks; the solution to - and source of - all build problems

As it turns out, we were running the nodejs buildpack first (since that's [the recommended order](https://devcenter.heroku.com/articles/ruby-support#node-js-support) in order to control Node and Yarn versions). The nodejs buildpack by default [runs your `build` script](https://devcenter.heroku.com/articles/nodejs-support#customizing-the-build-process) if you have one defined in `package.json`. However, [jsbundling](https://github.com/rails/jsbundling-rails) adds a `build` script to `package.json`, which it uses internally, I guess:

```json
  "scripts": {
    "build": "webpack --config webpack.config.js"
  }
```

Unfortunately, this meant that the nodejs buildpack would try to compile our assets before the above rake task was even invoked - and even before our Ruby dependencies had been installed at all! There's no chance for our translations to have been exported at that point.

Luckily Heroku provides a way to [customize the build process](https://devcenter.heroku.com/articles/nodejs-support#customizing-the-build-process), which we can use to tell Heroku to not build anything during the build step of the nodejs buildpack:

```json
  "scripts": {
    "build": "webpack --config webpack.config.js",
    "heroku-postbuild": ""
  }
```

With this in place in `package.json` Heroku would do nothing during the nodejs build step and everything would work just fine when we reached the ruby build step:

```
-----> Build
       Detected both "build" and "heroku-postbuild" scripts
       Running heroku-postbuild (yarn)

-----> Pruning devDependencies
...
-----> Preparing app for Rails asset pipeline
       Running: rake assets:precompile
```

Here's hoping this saves someone else the headaches I had figuring it out.

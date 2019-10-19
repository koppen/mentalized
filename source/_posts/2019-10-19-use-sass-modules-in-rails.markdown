---
title: "How to use Sass modules in Rails with Webpacker"
categories:
- technology
---

Sass recently announced [their long-awaited module system](http://sass.logdown.com/posts/7858341-the-module-system-is-launched) to replace the old and naive `@import`. It is awesome, and you can start using it today.

<!--more-->

It is currently available in [Dart Sass](https://www.npmjs.com/package/sass), which as far as I can tell is the only implementation of Sass yet to support this; none of the "big ones", [libsass](https://github.com/sass/libsass) nor [node-sass](https://github.com/sass/node-sass), has added [support](https://github.com/sass/node-sass/issues/2750#issuecomment-542111194) yet.

This puts you in kind of a pickle, though, if you're using [Webpacker](https://github.com/rails/webpacker) to compile your CSS: Webpacker comes with a [sass-loader](https://github.com/rails/webpacker/blob/master/package/rules/sass.js) configuration, which uses [node-sass by default](https://github.com/rails/webpacker/issues/2239#issuecomment-522745987).

## First some setup

In order to demonstrate this working, however, we need to run through a couple of setup steps first:

1. You need a Rails application
2. You need to compile your CSS with Webpacker

If you have already set up the above, jump directly to "Use Dart Sass instead of Node Sass".

### 1. Rails application

Let's create a sample Rails application for this, skipping over the default sprockets-based asset pipeline:

```bash
$ rails new dart-sass --skip-sprockets 
$ cd dart-sass
$ rails generate controller hello world
$ rails server
```

We don't need the default application.js, so let's remove that from `application.html.erb`:

```erb
<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
```

If you now visit [http://localhost:3000/hello/world](http://localhost:3000/hello/world) in your webbrowser you should see a "Hello#world" message.


### 2. Compile CSS with Webpacker

By default Webpacker only generates Javascript files, but we need to add CSS support as well. In `config/webpacker.yml` make sure you have the following settings under `default:`:

```
  extract_css: true
  source_path: app
```

(their default values are `false` and `app/javascript` respectively). This configures Webpacker to look for entries in the `app/packs` folder, so let's add a stylesheet there:

```bash
$ mkdir -p app/packs/styles
$ touch app/packs/styles/application.scss
```

In order to use the webpack-generated stylesheet change the following line in `application.html.erb` from:

```
<%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
```

to

```
<%= stylesheet_pack_tag 'styles/application', media: 'all', 'data-turbolinks-track': 'reload' %>
```

If you now add some sample styles to your `app/packs/styles/application.sass`, you should see the changes reflected in your browser:

```
body {
  background: red;
}
```

Such nice red background, much webdesign!

## Use Dart Sass instead of Node Sass

So far the above stylesheet is boring with no Sass-magic. Time to make use of the module system.

Create a new file, `app/packs/styles/_background.scss` with:

```scss
@mixin red {
  background: red;
}
```

and let's use it in `application.scss`:

```scss
@use "background";

body {
  @include background.red;
}  
```

If you now refresh your webbrowser, you'll get a `
Webpacker::Manifest::MissingEntryError` in `Hello#world`
error. `rake assets:precompile` will fail as well, but be less informative:

```
Compiling…
Compilation failed:
```

and if you try to compile the assets manually with webpack you'll get an error as well:

```
$ npx webpack --verbose --config config/webpack/development.js
...
    ERROR in ./app/packs/styles/application.scss (./node_modules/css-loader/dist/cjs.js??ref--7-1!./node_modules/postcss-loader/src??ref--7-2!./node_modules/sass-loader/dist/cjs.js??ref--7-3!./app/packs/styles/application.scss)
    Module build failed (from ./node_modules/sass-loader/dist/cjs.js):

      @include background.red;
              ^
          Invalid CSS after "...lude background": expected "}", was ".red;"
          in ~/dart-sass/app/packs/styles/application.scss (line 4, column 12)
    Error:
      @include background.red;
              ^
          Invalid CSS after "...lude background": expected "}", was ".red;"
          in ~/dart-sass/app/packs/styles/application.scss (line 4, column 12)
        at options.error (~/dart-sass/node_modules/node-sass/lib/index.js:291:26)
```

These are all expected, because we're still using node-sass which has yet to add support for the module system.

## Configure Webpacker to use Dart Sass

First, let's add Dart Sass to the application:

```
$ yarn add sass
```

This should add the sass package with a version of at least 1.23.0.

Add the following to `config/webpack/environment.js` before `module.exports = environment`:

```javascript
// Get the actual sass-loader config
const sassLoader = environment.loaders.get('sass')
const sassLoaderConfig = sassLoader.use.find(function(element) {
  return element.loader == 'sass-loader'
})

// Use Dart-implementation of Sass (default is node-sass)
const options = sassLoaderConfig.options
options.implementation = require('sass')
```

The above code basically digs into the default Sass loader that comes bundled with Webpacker, finds its configuration, and adds an `implementation` option set to the Dart Sass module.

Make sure to restart your webserver/webpack-dev-server and try refreshing your browser. Fancy red background is back, baby!

Congratulations, you can now use Sass modules in your Rails application stylesheets!

## Versions used in this article

* node-sass 4.12.0
* Rails 6.0.0
* Ruby 2.6.5
* sass 1.23.0
* Yarn 1.19.1
* Webpacker 4.0.7

---
title: "Getting Real(time) with Rails"
date: '2018-05-18 11:15:57 +0200'
series: "Getting Real(time) with Rails"
categories:
- Rails
- programming
- technology
---

Realtime web UIs are all the rage and Rails isn't one to be left behind. This article is an investigation into how one might build a UI that renders continuosly updated values from the server without ever refreshing the page.

<!--more-->

## Software versions

I have used the following software and versions when writing this, YMMV:

* ActionCable 5.2.0
* Rails 5.2.0
* Redis 4.0.6
* Ruby 2.5.1
* Stimulus 1.0.1

## Create the Rails application

Let's get started:

```shell
$ rails new meters --webpack --skip-active-record --skip-coffee
$ cd meters
```

This generates a blank Rails application called Meters in the meters directory.

 We've asked Rails to set itself up using Webpack. We skip ActiveRecord so we won't have worry about databases for our simple app, and we skip Coffeescript because we don't need that either.

## Use Webpack

While we've installed Webpack, the default layout still includes Javascripts from the asset pipeline, so let's change that. In `app/views/layouts/application.html.erb` change:

```html
<%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
```

to

```html
<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>
```

## Add something to look at

Let's keep it simple with a single controller with a single action/view:

```shell
$ rails generate controller Gauges show
```

then change `app/views/gauges/show.html.erb` to look like:

```html
<div class="gauge">
  <div class="gauge-value"><%= rand(1..100) %></div>
</div>
```

Now, if you start your Rails application (by running `rails server` in your terminal) and visit http://0.0.0.0:3000/gauges/show you should see a value that changes randomly every time you refresh.

It doesn't look impressive, but if you feel like adding a bit of style you can add the following to `app/assets/stylesheets/application.css`:

```css
body {
  font-family: system-ui;
}
.gauge {
  border: 1px solid #ccc;
  border-radius: 3px;
  box-shadow: rgba(0, 0, 0, 0.25) 0 0.25em 2em;
  margin: 1em;
  padding: 1em;
  text-align: center;
  width: 10em;
}
.gauge-value {
  font-size: 2.56em;
}
```

## Add Stimulus

Following the [Stimulus Handbook install guide](https://stimulusjs.org/handbook/installing):

```shell
$ yarn add stimulus
```

and replace `console.log('Hello World from Webpacker')` in `app/javascript/packs/application.js` with

```javascript
import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"

const application = Application.start()
const context = require.context("./controllers", true, /\.js$/)
application.load(definitionsFromContext(context))
```

This sets up a basic Stimulus setup that we can start using. Let's add a Stimulus-controller for our gauges, by first creating a `app/javascripts/packs/controllers` then add `app/javascripts/packs/controllers/gauge_controller.js` inside it:

```javascript
import { Controller } from "stimulus"

export default class extends Controller {
}
```

Now that we have a basic Stimulus controller that doesn't do anything, let's hook it up to our view. In `app/views/gauges/show.html.erb` change `<div class="gauge">` to

```html
<div class="gauge" data-controller="gauge">
```

This tells Stimulus that we want to use our gauge_controller.js for that part of the view and using Magic(tm) Stimulus connects the two for us.

### Letting Stimulus update our view

Now that we've connected our view to Stimulus, we can expose bits and pieces of our view to Stimulus, allowing us to update it without knowing the structure of our markup.

We add a Stimulus target by changing `<div class="value">` in `app/views/gauges/show.html.erb` to:

```html
<div class="value" data-target="gauge.value">
```

and we need to tell the Stimulus controller about it as well by adding `static targets = ["value"]` inside our controller in `stimulus_controller.js`:

```javascript
export default class extends Controller {
  static targets = ["value"]
}
```

This allows us to reference the DOM object with `data-target="gauge.value` as `this.valueTarget` in `gauges_controller.js`.

To demonstrate this, we'll add a `connect()` function in the controller, which Stimulus calls each time the controller is connected to our document:

```javascript
export default class extends Controller {
  static targets = ["value"]

  connect() {
    const element = this.valueTarget
    element.innerHTML = Math.floor(Math.random() * Math.floor(100))
  }
}
```

You can read more about [targets in the Stimulus Handbook](https://stimulusjs.org/handbook/hello-stimulus#targets-map-important-elements-to-controller-properties).

Now, if you start your Rails application (by running `rails server` in your terminal) and visit http://0.0.0.0:3000/gauges/show you should see a value that changes randomly every time you refresh. Those numbers are generated by our Stimulus controller. Success!

## Set up ActionCable backend

Now that our clientside Stimulus setup is operational, we turn our attention to the realtime part of our application; ActionCable.

Now we can create an ActionCable channel that we can communicate via. Create `app/channels/gauges_channel.rb`:

```ruby
class GaugesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "gauges"
  end

  def unsubscribed
    stop_all_streams
  end
end
```

This instructs ActionCable that everything broadcast to the "gauges" stream will be forwarded to all subscribed clients - and to stop streaming to clients when they unsubscribe.

And finally, in order to facility communication between different processes, we need a backend for ActionCable. By default it likes to use Redis, so let's install that.

Add to Gemfile and run `bundle`:

```
gem "redis"
```

and change the `development` section in `config/cable.yml` from

```yaml
development:
  adapter: async
```

to

```yaml
development:
  adapter: redis
  url: <%= ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } %>
```

You're also going to need [Redis server](https://redis.io/) installed and running. Covering that installation is out of scope for this article, but it should be [available from wherever you usually get your development software](https://redis.io/download).

## Set up ActionCable frontend

With the serverside part of ActionCable in place, we can start connecting clients to the channel from the clientside.

This first step here is going to seem a little dumb, but bear with me. We need to add the ActionCable javascripts to the project.

"But Jakob", I hear you exclaim, "didn't Rails add that by default when we generated our application?". Why yes, well spotted my imaginary reader, it did, but it assumed we wanted to use the Sprockets-based asset pipeline. We've opted for Webpack, so let's keep everything inside that:

```shell
$ yarn add actioncable
```

With that in place we can connect our Stimulus controller to our ActionCable channel. In `app/javascripts/packs/application.js` change the `connect()` function to look like:

```javascript
connect() {
  var cable = ActionCable.createConsumer();
  cable.subscriptions.create('GaugesChannel', {
    received: function(data) {
    }
  });
}
```
and import ActionCable on the first line of the file:

```javascript
import ActionCable from 'actioncable';
```

If you restart the Rails server and look at your Javascript console when refreshing the gauges/show page, you should see log messages in your Rails server output saying that a client has connected to your channel:

    Successfully upgraded to WebSocket (REQUEST_METHOD: GET, HTTP_CONNECTION: Upgrade, HTTP_UPGRADE: websocket)
    GaugesChannel is transmitting the subscription confirmation
    GaugesChannel is streaming from gauges

## Closing the loop

We now have a way to send data from the serverside using `GaugesChannel` and we have a Stimulus controller connected to that channel ready to receive the data we send.

Let's do something with the data we receive. Change the `received()` function in `app/javascripts/packs/controllers/gauges_controller.js` to

```javascript
received: (data) => {
  console.log('received', data);
  const element = this.valueTarget;
  element.innerHTML = data;
}
```

Note that we're using the [arrow function syntax](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/Arrow_functions) to ensure that `this` still references our Stimulus controller.

With that in place, your Redis server running and your Rails server running, refresh the gauges/show page in your browser and fire up a rails console:

```shell
$ rails console
> ActionCable.server.broadcast('gauges', 42)
```

If all goes well, your web UI should update automagically whenever your broadcast to `'gauges'` from your console. Give it a few shots:

```ruby
ActionCable.server.broadcast('gauges', 42)
ActionCable.server.broadcast('gauges', rand(1..100))
ActionCable.server.broadcast('gauges', "Hi!")
```

😃

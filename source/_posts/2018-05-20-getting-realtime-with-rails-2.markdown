---
title: "Getting Real(time) with Rails - part 2"
date: '2018-05-20 20:11:23 +0200'
series: "Getting Real(time) with Rails"
categories:
- programming
- technology
---

The [first article](/journal/2018/05/18/getting-realtime-with-rails/) in this series showed how to implement basic realtime updates to a Rails application using [ActionCable](http://edgeguides.rubyonrails.org/action_cable_overview.html) and [Stimulus](https://stimulusjs.org/). While the code was functional it had one major flaw; we couldn't update more than one gauge at a time.

<!--more-->

The code we developed allow a single gauge widget to update its value without us refreshing the page, but if we added more gauges to the page, we'd be updating all of them at once.

In this article we'll dig into how we can keep gauges separate.

## The more, the merrier

Let's start by adding another gauge to `gauges/show.html.erb`:

```html
<div class="gauge" data-controller="gauge">
  <div class="gauge-value" data-target="gauge.value">?</div>
</div>

<div class="gauge" data-controller="gauge">
  <div class="gauge-value" data-target="gauge.value">?</div>
</div>
```

Doing this illustrates quite fine what the core of our problem is - there is nothing distinquishing the two gauge-elements from each other. We can remedy that by adding an id for each of them:

```html
<div class="gauge" data-controller="gauge" data-gauge-id="37">
  <div class="gauge-value" data-target="gauge.value">?</div>
</div>

<div class="gauge" data-controller="gauge" data-gauge-id="42">
  <div class="gauge-value" data-target="gauge.value">?</div>
</div>
```

The actual ids (here `37` and `42`) can be anything as long as they are different. They are used to let Stimulus know what gauge it is listening to values for, and will subsequently be used for addressing each gauge from ActionCable.

Next up, we'll focus on our Stimulus-controller.

## GaugeController

Stimulus gives us a simple API for getting data-values of the element the controller is connected to. This means we can grab the id we just added by using `this.data.get('id')` in `gauge_controller.js`.

Change

```javascript
const connection = {
  channel: 'GaugesChannel'
}
```

to

```javascript
  const id = parseInt(this.data.get("id"));
  const connection = {
    channel: 'GaugesChannel',
    id: id
  };
```

and we'll include each id when we connect to the ActionCable channel.

Next up, we'll focus on our ActionCable channel.

## GaugesChannel

Until now GaugesChannel has been forwarding everything to/from a "gauges" stream:

```ruby
def subscribed
  stream_from "gauges"
end
```

We can change that to target a more specific stream dependent on the id that we get from the Stimulus controller:

```ruby
def subscribed
  stream_for params[:id]
end
```

In usual Rails-fashion, `params` contain a `Hash`-like structure of the values we receive from the client, in this case our ActionCable consumer instantiated in the Stimulus controller.

With the above in place, we can update specific gauges.

## Broadcasting to a specific gauge

Previously we would send a value to all gauges by broadcasting to the `"gauges"` stream - that no longer works:

    ActionCable.server.broadcast('gauges', rand(1..100))

We now have to be more specific and target a specific stream. Thankfully ActionCable channels make that easy using  `GaugesChannel.broadcast_to`:

    GaugesChannel.broadcast_to(37, rand(1..100))
    GaugesChannel.broadcast_to(42, rand(1..100))

The first line updates one of our gauges with a random value, and the other line updates the other gauge! Succes!

😃

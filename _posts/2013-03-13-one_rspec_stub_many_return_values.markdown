---
layout: post
title: One RSpec stub, many return values
date: '2013-03-13 11:02:47 +0100'
mt_id: 2160
categories:
- programming
---
Using [RSpec Mocks](https://github.com/rspec/rspec-mocks) it is trivially easy to [stub a single method](https://www.relishapp.com/rspec/rspec-mocks/v/2-13/docs/method-stubs):

    colors.stub(:favorite).with("Person A").and_return("Mauve")

It is also easy to have different stubs for different arguments:

    colors.stub(:favorite).with("Person A").and_return("Mauve")
    colors.stub(:favorite).with("Person B").and_return("Olive")

However, the other day I needed to stub out the same method many times for a fair amount of different arguments and repeating the `foo.stub(...).with(...).and_return()` part gets tedious real fast.

Thankfully, RSpec stubs have a way around this.

<!--more-->

RSpec docs call this a ["Stub with substitute implementation"](https://www.relishapp.com/rspec/rspec-mocks/v/2-13/docs/method-stubs/stub-with-substitute-implementation). You simply setup a fake implementation for a method by passing the stub a block.

We can use this to setup a look up table inside the stubbed method to give is pretty granular control over what it returns:

    colors.stub(:favorite) do |argument|
      values = {"Person A" => "Mauve", "Person B => "Olive"}
      return values[argument]
    end

This way, whenever your tests call `colors.favorite` the argument they pass along is used to look up the returned result in the `Hash` inside the stub.

This has proven quite useful when your `FavoriteColorService` talks to a DNA sequencer live and we don't want each test run to wait 4 weeks for each result.

---
title: "Fix Net::ReadTimeout errors in Capybara with Chrome"
categories:
- programming
- technology
---

We'd recently started seeing our system specs on a few of our projects fail with errors like

    Net::ReadTimeout with #<TCPSocket:(closed)>

Turns out an updated version of Chrome couldn't be reached by the [chromedriver](https://sites.google.com/a/chromium.org/chromedriver/) we use in [Capybara](http://teamcapybara.github.io/capybara/) to control headless Chrome.

<!--more-->

## Automatic updates, yay

At some point Chrome had either auto-updated locally or we'd simply installed newer versions of it, which had likely brought Chrome to a version 74. It would seem that Chrome v74 removes the network service that chromedriver communicates with to control the browser, leaving chromedriver flailing about not having anything to talk to. Lonely chromedriver, sad.

## Update your chromedrivers, y'all

Turns out I was running a very old chromedriver version locally, and updating it to the newest (v76) fixed the issue. This is usually a good rule; always update chromedriver when Chrome updates. Unfortunately Chrome updates itself, so you can't always know 🤷‍♂️.

## Work around in code

If you can't update your chromedriver for whatever reason, you aren't out of luck. The fix/workaround itself is fairly easy; you just need to reenable that network service when launching Chrome. In our code, that looks like:

```ruby
options = Selenium::WebDriver::Chrome::Options.new(:args => ["headless"])
options.add_argument(
  "--enable-features=NetworkService,NetworkServiceInProcess",
)
Capybara::Selenium::Driver.new(
  app,
  :browser => :chrome,
  :options => options,
)
```

Curiously, this fix didn't actually work on our CI service, where we were running ChromeDriver v2.35 😱. We had to upgrade to a newer version there.

## Thanks!

Thanks a lot to all the [people discussing](https://github.com/teamcapybara/capybara/issues/2181) [this issue](https://bugs.chromium.org/p/chromedriver/issues/detail?id=2897#c4), and especially to [ar31an](https://github.com/ar31an) who posted the actual fix.

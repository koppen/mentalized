---
title: "How to fix (some) UnknownError and InvalidArgumentError in Capybara"
categories:
- software
- technology
description: "Fix UnknownError and InvalidArgumentError in Capybara by adding --disable-search-engine-choice-screen to Chrome driver options to bypass search engine dialog."
---

The other day, [our](https://substancelab.dk) headless system specs in a Ruby on Rails project started failing with a bunch of errors we hadn't seen before. Mostly `Selenium::WebDriver::Error::UnknownError: unknown error: failed to close window in 20 seconds` but in some cases also `Selenium::WebDriver::Error::InvalidArgumentError: invalid argument: 'handle' must be a string`.

Usually random errors in browser tests can be fixed by upgrading [selenium-webdriver](https://rubygems.org/gems/selenium-webdriver), [Chrome](https://www.google.com/intl/da/chrome/), [chromedriver](https://developer.chrome.com/docs/chromedriver) or any combination thereof, but not this time.

<!--more-->

## TLDR

If you're seeing errors like `unknown error: failed to close window in 20 seconds` or `invalid argument: 'handle' must be a string` in your Selenium test suite running on Chrome you might need to add `--disable-search-engine-choice-screen` to the driver options.

## Root cause

The culprit revealed itself when we tried running the test suite with an actually visible, non-headless Chrome:

![Chromes Search Engine Ballot](https://res.cloudinary.com/substancelab/image/upload/v1723628945/google-chrome-search-engine-ballot.png)

Chrome, even when running headless, wants the user to pick their search engine preference. But since there is no user, or no way to see the dialog, it'll just wait and time out after a while.

## The solution

Luckily there is a commandline option to disable the dialog: `--disable-search-engine-choice-screen`. So to fix the issue we can add that to our other Capybara driver options:

```ruby
Capybara::Selenium::Driver.new(
  app,
  :browser => :chrome,
  :options => Selenium::WebDriver::Chrome::Options.new(
    :args => [
      "--headless=new",
      "--disable-search-engine-choice-screen"
    ]
  )
)
```

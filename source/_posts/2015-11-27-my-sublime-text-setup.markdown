---
title: My Sublime Text setup
categories:
- programming
- technology
---

Without much further ado, and because a few people have asked me; this is the
stuff that I've set up and configured in Sublime Text for my every day work.
Anything I'm missing?

<!--more-->

## The basics

* [Sublime Text 3](http://www.sublimetext.com/3)
* [Package Control](https://packagecontrol.io/)

## Visuals

* [Base 16 color scheme](https://github.com/chriskempson/base16) with base16-tomorrow.dark.tmTheme
* Font: [Source Code Pro Light](https://www.google.com/fonts/specimen/Source+Code+Pro), 13.0 pixels (or whatever the unit is)

Extracted from preferences:

    "caret_style": "phase",
    "ensure_newline_at_eof_on_save": true,
    "fade_fold_buttons": false,
    "highlight_line": true,
    "line_padding_bottom": 1,
    "line_padding_top": 1,
    "translate_tabs_to_spaces": true,

## Syntaxes

* [Better Coffeescript](https://github.com/aponxi/sublime-better-coffeescript)
* [Elixir](https://github.com/elixir-lang/elixir-tmbundle)
* [Ruby Slim](https://github.com/slim-template/ruby-slim.tmbundle)
* [Sass](https://github.com/nathos/sass-textmate-bundle)

## Must haves

* [All Autocomplete](https://github.com/alienhard/SublimeAllAutocomplete): Get auto complete suggestions from more files than the currently active.
* [Better RSpec](https://github.com/fnando/better-rspec-for-sublime-text): RSpec snippets and ability to jump directly between spec/implementation.
* [GitGutter](https://github.com/jisaacks/GitGutter): See what lines you have added/changed/deleted since your last commit directly in the gutter of your file.
* [SublimeLinter](http://www.sublimelinter.com/) with [SublimeLinter-Rubocop](https://github.com/SublimeLinter/SublimeLinter-rubocop): Highlights style violations directly in your code.
* [TrailingSpaces](https://github.com/SublimeText/TrailingSpaces): Highlights trailing spaces and automates getting rid of it. Keep those lines clean.

## Evaluating

* [ApplySyntax](https://github.com/facelessuser/ApplySyntax)

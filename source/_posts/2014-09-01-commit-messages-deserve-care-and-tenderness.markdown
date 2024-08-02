---
title: "Commit messages deserve care and tenderness"
categories:
- programming
description: "As someone who routinely has to figure out why a certain piece of code is like it is, I often read commit messages. And too often I am disappointed in them."
published: true
---
Commit messages are probably the most important piece of [documentation](http://mislav.uniqpath.com/2014/02/hidden-documentation/) we have. They are not to be taken lightly.

As someone who routinely has to figure out why a certain piece of code is like it is, I often read commit messages. And too often I am disappointed in them.

<!--more-->

## Care and tenderness

Good commit messages are hard to write. They take time and effort - and when you've finally completed that massive new bug fix, what you really want to do is `git commit -m "Finally fixed the fucker"` and be on your merry way.

Besides, why should you even spend time on those damn messages? Your code is self explanatory! It should be obvious looking at the diff what the heck is going on.

## Why is more interesting than what

That is probably (hopefully) true, but the "what" is not the point of your commit message. The "what" is already obvious in the code, remember? In the commit message, we want the "why" behind the "what".

Generally speaking, commit messages serve a few purposes:

1. Provide background information for whoever is reviewing your code.
2. Inform the current team what has changed.
3. Store decisions and background for whoever needs to read it years from now.

Background information for code review has a pretty limited lifespan - and a limited audience of a few people. After the code has been accepted and merged, the code review is quickly forgotten.

Purpose #2 is pretty ephemeral as well. At some point over the next week every other developer will have pulled your changes and hopefully read through the changes.

Purpose #3 on the other hand lives forever - or at least for the rest of your projects lifespan. The audience for your commit messages is your entire team - both the members you know and every member that has yet to be hired.

You also don't know which commits is going to be picked up by a team member some time down the line, so please, make them all good.

## “But how, Jakob, how?”

I am glad you asked, and luckily there inter webs doesn’t disappoint:

* [A Note About Git Commit Messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)
* [5 Useful Tips For A Better Commit Message](http://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message)
* [GOV.UKs git style guide](https://github.com/alphagov/styleguides/blob/master/git.md#commit-messages)
* [Stop Writing Rambling Commit Messages](http://stopwritingramblingcommitmessages.com/)
* And then there’s [Linus Torvald being Linus Torvalds](https://github.com/torvalds/linux/pull/17#issuecomment-5659933)

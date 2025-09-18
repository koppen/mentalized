---
title: "The anatomy of a good commit"
date: '2018-12-12 11:43:23 +0200'
categories:
- Rails
- programming
---

Commits are the DNA of your system. They describe the evolution of your system going back to when it was the most basic, automatically generated "Hello World" example. They contain the sum of all knowledge and history of your code.

In many cases they are the least changable part of your system, so you only really get one shot at getting them right. You'd better make it count.

<!--more-->

## Good commits are focused

As with almost anything in development, [smaller is better](https://www.bignerdranch.com/blog/less-code-is-better/). All changes in a single commit should revolve around a single concept.

It's not unlikely to spot an issue that could be fixed, while you've got this file open anyway. Usually, don't. Even if this is just tiny syntax changes and it's so tiny and easy to make that it becomes tempting to just lump it in there with all the other changes.

If you do, suddenly you have two concepts in your commit; Syntax improvement and implementing the bugfix or whatever you're really working on.

Two concepts means two commits.

## Good commits are complete

A single commit should contain the complete change. When a commit is not meaningful on its own, its existence no longer provides value to the system and should be merged into another commit.

For example, you might to implement pagination in a Rails application. That's probably a multi-step process:

1. Install a pagination gem
2. Configure the pagination gem
3. Use the pagination gem in the controller
4. Render the pagination navigation in the view

Do these steps actually make sense on their? Let's apply Jakobs Rollback Test™ here:

> Would we ever want to roll back the gem installation without removing the usage or configuration of it?

If the answer is "no", those changes are dependent on each other, provide little value on their own and should be combined into a single commit.

## Good commits have good commit messages

A commit cannot be good unless its commit message is good. I won't cover the details here, that's an entire article of its own. And [that article happens to already be written by Chris Beams](https://chris.beams.io/posts/git-commit/), so take a look at that for a good rundown of best practices around commit messages.

## Why does it matter?

Good commits open up a whole bag of tricks that you cannot otherwise do - or at least that are going to be harder to pull off.

* If your commits are focused you get to be able revert and roll back changes.
* If your commits are focused merge conflicts become easier to resolve.
* If your commits are complete you get to harness the full power of `git bisect run`. 
* If your commits have good commit messages you'll be able to find out why a change was made.
* If your commits are good your code reviews should become easier.

## Practical advice

During development I will usually commit the most miniscule things on their own. Then, when I see where they fit into the larger history of the full feature I'll rebase and move and squash them together into a sequence consisting of individually sensible commits.

* Commit early, commit often.
* `git commit --amend` if a change defintely belongs with the previous commit.
* Squash and fixup when the bigger picture becomes visible

## Rules of thumb

* If you feel the need to put <cite>"and"</cite> in your commit message, the commit is probably too big.
* If you find it difficult describing what your commit does, it's probably too big.
* If you find it difficult describing the "why" of your changes, your commit might be too small.

## References

* [Commit Often, Perfect Later, Publish Once: Git Best Practices](https://sethrobertson.github.io/GitBestPractices/)
* [The Art of the Commit](https://alistapart.com/article/the-art-of-the-commit)
* [What's in a Good Commit?](https://dev.solita.fi/2013/07/04/whats-in-a-good-commit.html)
* [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit/)

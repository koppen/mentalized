---
title: "GitHub pull request suggestions considered harmful"
categories:
- development
- process
---

I recently started working with a development team that uses GitHubs "Insert a suggestion"-feature heavily during the pull request review process.

<figure>
  <img src="https://res.cloudinary.com/substancelab/image/upload/v1590589157/mentalized/github-pull-request-suggestion-ui.png" alt="GitHubs 'Insert a suggestion' UI" />
</figure>

<!--more-->

It's a neat feature for sure, and the ease of use to make minor changes like typos and whatnot is great. However, I have started to grow a dislike for it for a few reasons:

1. Changes aren't tested
2. Authors cannot verify changes
3. It encourages a messy history

## 1. Changes aren't tested

A proposed suggestion isn't tested before it gets committed. If I choose to apply the suggestion and it then turns out that it broke the build, we've now got a build-breaking change committed to the annals of time. Unless, of course, I later choose to squash or fixup or otherwise remove the commit.

It would be awesome if somehow CI could be run with the proposed change, adding a tiny notice with the suggestion that "this suggestion didn't pass on CI" or whatever.

## 2. Authors cannot verify changes

So a substantial suggestion has been proposed, and knowing that CI doesn't have my back, I'd love to be able to pull the suggestion to my local development environment to run my tests and perform manual verification.

But I can't. There is no branch with the suggestions that I could check out or something like that. So once again, I have to rely on my mental parsing of the suggestion, or I have to apply the suggestion, leaving a potential build-breaking commit for the ever-after.

## 3. It encourages a messy history

Even though GitHub has added the ability to batch suggestions into a single commit - a mighty fine addition to the feature - it's not really enough. Inevitably you end up with a bunch of "Applied suggestions from code review" commits in your git log.

You have to take a great deal of care and write up commit messages in GitHubs UI, which isn't really ideal for this - or you have to accept the fact that you have to rewrite your git history after committing.

## In conclusion

All in all GitHubs "Insert a suggestion" feature is an interesting idea, it's not really there yet - at least not for me.

For tiny changes it works fine, and it can definitely be a better way to express your suggestions, but the temptation of that "Commit suggestion" button in the UI should  be resisted.

How does your team use the feature? Have you made it work for you?
---
layout: post
title: Mining emails
date: '2002-10-28 17:09:18 +0100'
mt_id: 609
categories:
- technology
---
Just for kicks I created a tiny web-spider (less than 2K, 30 minutes coding time) in Python designed to get email addresses off websites. The script is small, the rules for recognizing website- and email-addresses are real simple, but still it is pretty effective.

Starting at my website and crawler no further than 1 link away - only following links to the homepages of websites, it runs for half a minute and returns 18 emails after crawling through 28 URLs. If I increase the distance it can crawl away from my website to 2, it crawls through 306 websites and returns 151 email addresses.

Sheesh, is it really that easy - no wonder I'm getting more and more [spam](https://www.emailsherpa.net/knows/spam/). Although I am wondering, how come there is a market for selling email addresses when it is this easy to farm them.

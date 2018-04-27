---
layout: post
title: Spam, spam, baked beans, and spam
date: '2002-11-01 02:18:39 +0100'
mt_id: 614
categories:
- technology
---
<a href="http://philringnalda.com/archives/002371.php">phil ringnalda dot com warns</a> about the latest idea from the lowlife scum also known as spammers: Target the comment sections of blogs using a script that posts a comment to every entry on the blog.

Why don't we just do like we do at <a href="http://www.dailyrush.dk">Daily Rush</a>? When a comment is posted, the blog-software checks if a post like it (either exactly or using some isTextAlike-algoritm - I believe a couple exists in CPAN making implementation in ie <a href="http://www.movabletype.org">Movable Type</a> reasonably easy) has been made recently (or at any point). If it has, the post isn't accepted.

The deluxe version could automatically ban the posting IP after a fixed amount of tries. It seems to me this would probably take care of most of the problems - at least until the spammers get a clue.

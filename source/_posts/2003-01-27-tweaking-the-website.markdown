---
title: Tweaking the website
date: '2003-01-27 15:23:08 +0100'
mt_id: 655
categories:
- mentalized.net
---
During the recent weeks I have been fiddling with the internals of this weblog. It appears to be a good place to experiment with ideas and technologies before I move them to bigger projects.

Many of the changes shouldn't be obvious to most of you unless you look really hard, but so far I'm pretty proud of the technical level of the site so far.

<!--more-->

The things I have changed so far:

<ul>

<li>Entrytitles on the journal link to the individual archives.</li>

<li>Meta tags are now used.</li>

<li>"Everything" should validate by now. <a href="http://daringfireball.net/projects/smartypants/">SmartyPants</a> and <a href="http://www.bradchoate.com/">Brad Choate's</a> MT-FormatBreaks ensures proper XHTML in most cases, while Brads <a href="http://www.bradchoate.com/past/mtsanitize.php">Sanitize-plugin</a> governs my comments from invalid and unwanted HTML.</li>

<li>Individual pages now have their own <a href="http://diveintoaccessibility.org/day_8_constructing_meaningful_page_titles.html">meaningful titles</a>. Titles will be added when I get around to it.</li>

<li>Recording referrers using my own <a href="/journal/2003/01/27/announcing-j-referrertracker/">J-ReferrerTracker</a>.</li>

<li>Using Brads <a href="http://www.bradchoate.com/past/mtmacros.php">MTMacros-plugin</a> to create &lt;acronym&gt;-tags with <a href="http://diveintomark.org/inc/macros">Mark Pilgrims macro-definitions</a> as a base.

<li>My <a href="/journal/archives/">journal archives</a> are finally existant.</li>

<li>Individual journal entries now has <a href="http://www.adaptivepath.com/publications/essays/archives/000058.php">Human Readable URLs</a>. In Movable Type this is achieved by setting the Individual Archive path to <code>&lt;$MTEntryCategory dirify="1"$/gt;/&lt;$MTEntryTitle dirify="1"$&gt;/index.asp</code>, with index.asp being my default indexpage.</li>

<li>The post comment template has been redesigned to make it more usable.</li>

<li><a href="http://www.kalsey.com/2002/07/related_entries_plugin/">MT Related Entries plugin</a> used to show other entries in the same category.</li>
</ul>

I still have a few ideas I might want to push forward with, but for now the above changes will have to do. I am still looking for a Movable Type plugin to format my links though - I keep getting unescaped &amp;-characters in URLs which breaks my otherwise validating site.

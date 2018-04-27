---
layout: post
title: Experiencing Outlook XP
date: '2003-01-03 17:55:39 +0100'
mt_id: 645
categories:
- technology
---
To make my start of 2003 even more pleasant, it turned out that my boss had bought himself a new laptop. A nice little machine that I luckily didn't have to install as it came preinstalled with Windows XP and Office XP. Unfortunatly, Outlook XP apparently sucks for formatting mails.

<!--more-->

<h2>Bloated messages</h2>

He sent me a simple mail, subject was "Test", the content was "Hey Jakob" and his signature. With headers the mail weighs about 1KB. The mail I received weighed 6KB - about 6 times the actual content. The reason for this inflated size is that Outlook XP per default sends its mails with both a text-version and a HTML version. A closer look reveals that the HTML version contains almost 5KB(!) HTML markup and 170 bytes actual text. (I wonder if Microsoft is planning to start selling bandwidth).

<h2>So-called HTML</h2>

While looking through <a href="https://mentalized.net/journal/archives/outlookxp/OutlookMessage.html">the HTML markup</a>, I noticed a striking resemblance to the tag soup that Word usually serves. Somehow it didn't surprise me that the <a href="http://validator.w3.org/check?uri=http%3A%2F%2Fwww.mentalized.net%2Fjournal%2Farchives%2Foutlookxp%2FOutlookXPMessage.html&amp;charset=%28detect+automatically%29&amp;doctype=HTML+4.01+Transitional">HTML version does not validate</a> (in all fairness, I might have chosen the wrong HTML version as I had to guess it). No biggie, we all use Internet Explorer for checking our mail, right? (actually, does anyone know of a survey on mail client usage? - could be interesting to see)

<h2>Enter SpamAssassin</h2>

I could perhaps survive the fact that Outlook XP per default inflates the messages with invalid HTML, but the fun is only just beginning. <a href="http://www.spamassassin.org" title="SpamAssassin website">SpamAssassin</a> reports:

<blockquote>
<p>
SPAM: INVALID_MSGID      (1.2 points)  Message-Id is not valid, according to RFC 2822<br />
SPAM: BIG_FONT           (-0.4 points) BODY: FONT Size +2 and up or 3 and up<br />
SPAM: HTML_70_90         (0.9 points)  BODY: Message is 70-90% HTML tags<br />
SPAM: LINK_TO_NO_SCHEME  (3.7 points)  BODY: Contains link without http:// prefix<br />
</p>
</blockquote>

That's enough to pass my SpamAssassin treshold, marking the message as spam and rendering it more or less unreadable as my mailclient now cannot render the 5K HTML. Admittedly this is basically a selfinflicted problem, as I have opted to try to remove the masses of spam I receive.

<h2>Non RFC compliancy</h2>

The SpamAssassin report above included an interesting hit: "<cite>Message-Id is not valid, according to RFC 2822</cite>". <a href="http://www.faqs.org/rfcs/rfc2822.html" title="RFC 2822">RFC 2822</a> specifies "<cite>a syntax for text messages that are sent between computer users, within the framework of "electronic mail"</cite>" - the syntax for emails.

Outlook XP fails to uniquely identify the messages it sends, invalidating tools that rely on unique messageid's to ie present messages in a threaded view. There are other uses for this, which Outlook itself could benefit from.

<h2>Strike 3, you're outta here</h2>

I naivly hope that people using Outlook XP will chose to send mails as text only. Unfortunatly people are most likely not going to change the default setting, and they themself will not experience any problems, as Outlook XP naturally handles the above problems without hesitation. What people need to realize is that when you send a HTML mail from Outlook XP, you are enforcing your choice of mailclient upon others that may not be able or willing to use Outlook.

Will we be seeing a reenactment of the "browser war" on the mailclient front? Hopefully not, but the browser war started with vendors moving away from the standards, refusing to support other vendors features or more or less intentionally making sure that websites designed for one browser didn't render properly in the competing browser. This is what Microsoft seems to be doing with Outlook XP.

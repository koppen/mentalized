---
title: "Custom Return Path with Postmark"
categories:
- email
- projects
---

[Front Lobby](https://frontlobby.dk) sends transactional emails via
[Postmark](https://postmarkapp.com). Every week Postmark sends me an email with
numbers of emails sent and delivered, which is nice.

That email also includes a list of deliverability recommendations - and for the
longest time that list has contained "Set up a custom Return-Path for
frontlobby.dk". I figured it was time to do something about it.

<!--more-->

### Find your custom return-path

In Postmark under your "Sender Signatures" you'll find a list of the domains
you've added to Postmark. If any of those are highlighted with "Return-Path Not
Verified" in red text you should follow along here.

Under the domains DNS settings (still in Postmark) is a row with "Return-Path"
and "Inactive". By default, Postmark suggests you use `pm-bounces` as the return
path. Unless you have special requirements, just use the that.

The row also shows us the value we need to add as a CNAME for whatever we chose
as the return path above. In my case I had to add a CNAME record for
`pm-bounces.frontlobby.dk` with a value of `pm.mtasv.net`.

### Verify the changes in Postmark

After adding the record in [my DNS provider](https://gandi.net) I can head back
to Postmarks DNS Settings interface to click the "Verify" button. If everything
is correct, you should see a green checkmark and a "Verified" message!

## What is the return path?

When you send a transactional email via an ESP like Postmark, you'll usually
send from a recognizable email address like "jakob@frontlobby.dk" to ensure that
your recipients recognize the sender and can reply to you.

However if an error occurs delivering your email the receiving server needs a
place to deliver error reports and whatnot. Those error report emails should end
up with your ESP so they can handle them, instead of cluttering up your inbox.

The email address that email servers send those errors to is the return path (or
bounce accress or a number of other names). If you don't do anything it's going
to be something like bounces@track.postmarkapp.com (I don't know what the actual
address for Postmark is), which is perfectly fine.

However, if you've set up [DMARC](https://www.emailsherpa.net/knows/dmarc) for
your domain (and you should have), recipient servers might start flagging your
emails in the above - even though both
[SPF](https://www.emailsherpa.net/knows/spf) and
[DKIM](https://www.emailsherpa.net/knows/dkim) pass!

Basically the recipients look at the domains from both the `From` address
(ie `frontlobby.dk`) and the bounce address (ie `postmarkapp.com`). It then
compares those domains to the ones you've authenticated via DKIM and SPF and if
it doesn't match the entire DMARC authentication fails and you risk your email
not being delivered.

---
title: "Email address validation is hard"
categories:
- programming
- technology
---

Email address validation is a pet peeve of mine. So much that I’ve built [my own library](https://github.com/substancelab/activemodel-email_address_validator/) that I can throw into our projects and be done with it.

So you can imagine my disappoint when an error rolled into our exception tracking system the other day (Actual email address changed to protect the innocent):

```
Mail::Field::ParseError: Mail::AddressList can not parse |über@example.org|
Reason was: Only able to parse up to ü
```

At first glance it seemed like we’ve allowed an email address to enter our system, that was so invalidly formatted that the excellent Mail gem couldn’t parse it, causing the application to crash instead of sending a friendly “Welcome” email to the new user. And the culprit was a single `ü` character.

<!--more-->

## Is über@example.org a validly formatted email address ?

Thus started the big quest for figuring out if that email address was actually valid. Do you know?

Reading my way through [RFCs](https://tools.ietf.org/html/rfc6532) it seemed like it should - at least in theory - be a valid email address. However, in practicality, support is very limited:

1. Firefox email validation says no.
2. Chrome email validation says no.
3. Safari email validation says no.
4. Mailgun Validation says no (well, “unknown”, which I think means “no”)
5. Microsoft/Hotmail says no when creating accounts.
6. Gmail says no when creating accounts.
7. FastMail says no when creating accounts.
8. And as mentioned, the [Mail gem](https://rubygems.org/gems/mail) didn’t like it.

So I was confused. I then tried validating it with `Mail::Address` on another project of ours, where it passed, and got even more confused. At this point I noticed that we were using [mail](https://rubygems.org/gems/mail) v2.6 on the first project and v2.7 the latter. Clearly something had changed.

## The Mail gem is awesome

Lo and behold! Mail v2.7.0 included [this pull request](https://github.com/mikel/mail/pull/1103)) which adds support for UTF-8 encoded headers. So that explained the difference between the two projects. It also gave a strong indication that non-US ASCII characters are indeed valid and possible in email addresses. So I tried sending to a bunch of different addresses with a `ü` in their local part (none of them existing, but for testing this was fine). 

It turns out that all mail clients I could easily come by had perfectly fine support for non-US ASCII characters when sending - even Gmail and Hotmail which don’t support the format for their own users. I also came across a [changelog for EXIM 4.86](https://git.exim.org/exim.git/blob/exim-4_86:/doc/doc-txt/NewStuff) which mentions [experimental support for UTF-8 characters in recipient addresses](https://bugs.exim.org/show_bug.cgi?id=1516).

And then there’s [this guy](https://medium.com/@zackbloom/i-have-a-unicode-email-address-fbecd630ec12) whose email address is `🎃@zack.is`…

## Yes, UTF-8 characters are valid
So in conclusion; non-US ASCII characters are perfectly valid in the local part of an email address (with some caveats), but support for them is still limited. 

However, if you do validate email address formats, you should [allow UTF-8 characters](https://github.com/substancelab/activemodel-email_address_validator/pull/11) instead of rejecting people who use an email service that has adopted the future.

## Conclusion

This whole story once again underlines a basic fact of accepting email addresses: 

The only guaranteed way to ensure that an email address is a valid address where a person can receive email is to send an email to that address and have that person follow a link, which you can then verify on your backend. Anything outside this is a band aid that puts you at risk of rejecting users with perfectly valid email addresses.

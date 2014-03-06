---
layout: post
title: Rails 3, ActionMailer, and Google Apps for Domains
date: '2012-05-08 18:08:43 +0200'
mt_id: 2141
categories:
- software
---
After upgrading my [Redmine](http://redmine.org) installation to Redmine 2 (the development branch) emails stopped being delivered.

I send emails through [Google Apps for Domains](http://google.com/a), so I had the following in my configuration.yml (previously email.yml):

    delivery_method: :smtp
    smtp_settings:
      address: "smtp.gmail.com"
      port: 587
      domain: "substancelab.com"
      authentication: "login"
      user_name: "foobar@example.net"
      password: "passw0rd"
      tls: true

I am pretty sure it used to work before the upgrade, now; not so much.


<!--more-->

## Damn you, SSL

Alas, when I ran `rake redmine:email:test` I kept getting a

    An error occurred while sending mail (SSL_connect returned=1 errno=0 state=SSLv2/v3 read server hello A: unknown protocol)

## What is TLS even?

I knew this has something to do with the TLS settings, but Google didn't reveal any concrete, working advice. Adding `enable_starttls_auto: true`, which seems to be most prevalent solution didn't change anything for me.

## One or the other, but not both

Only after digging deep into [ActionMailer](http://apidock.com/rails/ActionMailer/Base) and the [Mail gem](https://github.com/mikel/mail) did I discover my problem.

Having `tls: true` in the settings was messing things up even if `starttls_auto` is enabled. Changing my settings to

    delivery_method: :smtp
    smtp_settings:
      address: smtp.gmail.com
      port: 587
      domain: substancelab.com
      authentication: login
      user_name: "foobar@example.net"
      password: passw0rd
      enable_starttls_auto: true

made my email delivery work again.

File this under "blogged so you don't have to suffer as I did".

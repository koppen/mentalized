---
layout: post
title: Ruby SSL certificate verification errors
date: '2012-01-02 09:52:24 +0100'
mt_id: 2131
categories:
- programming
- technology
---
On a client project, we had recently installed [capistrano-campfire](https://github.com/technicalpickles/capistrano-campfire) to get notifications in our [Campfire](http://campfirenow.com/) chatroom whenever a deployment takes place.

Unfortunately I kept getting

    SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed (OpenSSL::SSL::SSLError)

when I tried deploying. There's nothing quite like starting the year with SSL issues...

According to [this article](http://martinottenwaelter.fr/2010/12/ruby19-and-the-ssl-error/) the problem

> ... comes from the fact that the new Ruby 1.9 installation doesn't find the certification authority certificates (CA Certs) used to verify the authenticity of secured web servers.

I my case, I was using Ruby 1.8 (well, [REE](http://www.rubyenterpriseedition.com/)) on OS X Snow Leopard, but the problem - and solution - was the same nevertheless.


<!--more-->


## The cURL way

The super easy solution is found on [Stack Overflow](http://stackoverflow.com/questions/5711190/how-to-get-rid-of-opensslsslsslerror) (as always):

    sudo curl http://curl.haxx.se/ca/cacert.pem -o /opt/local/etc/openssl/cert.pem

This installs [Mozillas CS Root Certificates Bundle](http://curl.haxx.se/ca/) at /opt/local/etc/openssl/cert.pem, where the certificates can be found by Rubys HTTP library without any extra configuration.


## Using MacPorts

As an alternative to the above, you can use MacPorts to get the bundles (as mentioned in [this article](http://martinottenwaelter.fr/2010/12/ruby19-and-the-ssl-error/)):

    $ sudo port install curl-ca-bundle

This installs the certificates bundle in /opt/local/etc/openssl/cert.pem.

You can then configure Ruby to use them:

    https.ca_file = '/opt/local/share/curl/curl-ca-bundle.crt'

or if that isn't feasible, simply link them up from the default location:

    $ sudo ln -s /opt/local/share/curl/curl-ca-bundle.crt /opt/local/etc/openssl/cert.pem

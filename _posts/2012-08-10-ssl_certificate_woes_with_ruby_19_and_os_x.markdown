---
layout: post
title: SSL certificate woes with Ruby 1.9 and OS X
date: '2012-08-10 10:53:38 +0200'
mt_id: 2145
categories:
- technology
- programming
---
I have written about [Ruby and OpenSSL woes before](http://mentalized.net/journal/2012/01/02/ruby_ssl_certificate_verification_errors/), but I recently got bit by the issues again and the solution I had outlined earlier didn't work.


<!--more-->

My simple testcase

    require 'net/https'
    https = Net::HTTP.new('www.google.com', 443)
    https.use_ssl = true
    https.request_get('/')

failed with a

    OpenSSL::SSL::SSLError: SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed

No biggie, by now the [solution](http://www.openlygeek.com/programming-2/the-best-way-to-handle-openssl-certificate-verify-failed-errors/) [has](http://blog.kabisa.nl/2009/12/04/ruby-and-ssl-certificate-validation/) [been](http://notetoself.vrensk.com/2008/09/verified-https-in-ruby/) [widely](http://stackoverflow.com/questions/5711190/how-to-get-rid-of-opensslsslsslerror) [documented](http://martinottenwaelter.fr/2010/12/ruby19-and-the-ssl-error/) - Just [install a CA certificate bundle](http://mentalized.net/journal/2012/01/02/ruby_ssl_certificate_verification_errors/):

    $ port install curl-ca-bundle

and tell Ruby to grab the certificates from where you installed them:

    https.ca_file = '/opt/local/share/curl/curl-ca-bundle.crt'

Sure enough, that makes the simple test case work.

But what if we cannot hardcode `ca_file` paths - for example if the request is being made by a third party library? Turns out, if we set the `SSL_CERT_FILE` environment variable, things work without us modifying core Ruby classes:

    export SSL_CERT_FILE=/opt/local/share/curl/curl-ca-bundle.crt

Winning!

---
layout: post
title: Routing requests to local development environment
date: '2011-10-19 09:58:33 +0200'
mt_id: 2125
categories:
- software
- technology
---
Some third party systems needs to send requests to your web application in order to work.

[Facebook](http://facebook.com) fetches the actual application, [Chargify](http://chargify.com/) notifies you of subscription changes, payment gateways tell you the transaction has been accepted.

That's fine in production where you have a public facing webserver running, but when you're developing locally you have to jump through a few hoops.


<!--more-->

## Reverse SSH tunnel

The common approach is to setup a [SSH tunnel](http://www.howtoforge.com/reverse-ssh-tunneling) on a remote server and use that as endpoint for the third party service. This is pretty standard business and can be handled by a service like [Showoff](https://showoff.io/). Personally I just use basic SSH:

    ssh -vN koppen@example.com -R 3000:localhost:3000

As long as the above is running, all requests to port 3000 on example.com is received on localhost:3000.

If you're developing Facebook apps, you can stop here. However, some third party services like [Chargify][chargify] and [Quickpay](http://quickpay.net "Danish payment gateway") refuse to use anything but port 80 (and 443) for their communication. 

While it is possible to setup the tunnel on port 80 remotely, my servers tend to already occupy port 80, so that's a no go.


## Proxy passing

The next piece of the puzzle then becomes routing to the SSH tunnel at port 3000 from port 80.

Since my development server is already running [Apache](http://httpd.apache.org/docs/2.2/mod/mod_proxy.html), this is painfully easy. I just created a new site, using [mod_proxy](http://httpd.apache.org/docs/2.2/mod/mod_proxy.html) to forward requests to the given port:

    <VirtualHost *:80>
      ServerName tunnel.example.com
      ProxyPass / http://0.0.0.0:3000/ retry=0
    </VirtualHost>

(The retry=0 option to ProxyPass prevents the endpoint from being marked as bad for a period of time if it receives a request without my tunnel being active)

With this in place, any request to tunnel.example.com is passed to 0.0.0.0:3000 on the same server, where the SSH tunnel receives it and passes it to my local development server.

Success! And the best part is, this totally makes me feel like I am [bouncing connections around in Uplink](http://www.introversion.co.uk/uplink/screenshots/uplink4.gif).

[chargify]: http://chargify.com/

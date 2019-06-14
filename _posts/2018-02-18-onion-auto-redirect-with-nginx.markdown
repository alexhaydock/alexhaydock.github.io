---
layout: post
title: "Automatically redirect Tor users to your Onion Service using Nginx"
description: "Discover how to make sure Tor Browser users are actually using your shiny new onion service."
category: tech
---
So you've just set up a shiny new Tor onion service and you want to make sure everyone is using it. This guide will show you how to use Nginx to automatically redirect Tor users to the onion domain. _This guide assumes that you are serving your website using the Nginx webserver and have access to the main Nginx configuration files._

#### Download Current List of Tor Exits
The easiest and most reliable way of non-intrusively identifying Tor users is to use the Tor Project's helpfully provided [list of current exit addresses](https://check.torproject.org/exit-addresses).

The list contains the IP addresses of all known Tor exits, but is formatted with a bunch of extra information that we don't really need. Thus, we need to download this file and parse it to isolate just the IP addresses and present them in a format that Nginx will understand.

I use the following script to download and parse the list:
```sh
#!/bin/sh
set -e
set -u

# Download exit list
curl -s --ssl-reqd https://check.torproject.org/exit-addresses -o /etc/nginx/tor-exits-raw

# Format the list for Nginx
TOREXITLIST=$(grep "ExitAddress" /etc/nginx/tor-exits-raw | awk '{print "\t" $2 " 1;"}' | sort | uniq)

# Pipe the output into an Nginx-compatible config file
echo -e "geo \$torExit {
\tdefault 0;
$TOREXITLIST
}" > /etc/nginx/torexits.conf
```

As you will see, this script uses `curl` to download the current list of Tor exits. It then uses `awk` to format the list into just IP addresses, presented the way Nginx wants them. `sort` and `uniq` are used to remove any duplicates from the list, and finally the whole list gets printed into a nicely-formatted config file ready for Nginx to read.

#### Import Exit List into Nginx
Now that we've generated our list of exits, importing this into Nginx is trivial.

In your main `nginx.conf`, ensure that you have a line somewhere within the `html{}` block that tells Nginx to `include` the exit list file:
```nginx
html {
  ...
  include /etc/nginx/torexits.conf;
  ...
}
```

#### X-Real-IP Headers (Optional: Reverse proxy users)
If you have a reverse proxy forwarding requests to your main Nginx process, you will need to be aware of the caveat that Nginx will -- by default -- interpret all connections as being from the IP address of the reverse proxy. This IP address will not be in the Tor exit list, and thus the redirect will not work without some extra information.

We can tell Nginx to interpret the user's real IP address as the one listed in the `X-Real-IP` header by adding the following to the relevant `server{}` block of the Nginx config:
```nginx
server {
  ...
  set_real_ip_from ip.addr.of.proxy;
  real_ip_header X-Real-IP;
  ...
}
```

Of course we also need to make sure the proxy is _actually setting_ this header. Your mileage may vary depending on what proxy you're using, but if you're also using Nginx for your proxying needs then this can be done with:
```nginx
proxy_set_header X-Real-IP $remote_addr;
```

#### Configure Nginx to redirect users
Now that Nginx is aware of users which are connecting over Tor, you need to ensure that the `server{}` blocks for all sites which you want to redirect are populated with a `HTTP 301` redirect, pointing users to the onion service:
```nginx
server {
  ...
  if ($torExit) {
    # If we're listed in the torexits.conf file as being a Tor exit, redirect using a 301.
    return 301 http://alex5q3xhu7wi642.onion$request_uri;
  }
  ...
}
```

#### Going Live, and Updating
Now it should be a simple matter of restarting Nginx and testing your deployment by visiting a few times from a clean Tor Browser and checking whether the redirect takes place correctly.

Tor exits tend to be quite stable and long-lived, so the list is unlikely to need updating particularly often, but please be aware that new exits will appear over time, so you likely want to ensure that you're pulling down the list of exits every so often.

You probably want to schedule updates with `cron` or systemd timers, but that is outside the scope of this guide. Just remember that after updating the list, you will need to tell Nginx to reload its config:
```
sudo systemctl reload nginx
```

#### Possible Caveats
Obviously, there are some limitations to this method. For one thing, it does not stop the initial clearnet connection to the site, and doing so would not be a problem that is particularly easy to solve without new web standards. This method does use a `HTTP 301` redirect, which tells the browser that the site in question has _moved permanently_. Browsers remember this kind of redirect indefinitely which -- in theory -- means that the browser won't bother making the clearnet connection next time. Unfortunately, this doesn't mean much in practice, as most Tor users will be using the Tor Browser (which will forget such a redirect as soon as the user closes it).

This trick will also redirect _all_ connections from Tor exit IP addresses. In some extremely niche scenarios, if someone is trying to browse to your site from a Tor exit IP address and does not happen to be using the Tor Browser, then they will be redirected to the onion domain anyway. Personally I don't consider this much of a risk, since it's unlikely that anyone who operates a Tor exit is also doing clearnet browsing through the same IP, but it's something to be aware of.

Additionally, if you're running a large site, you may want to use the Tor exit list I use in this article to conduct some analysis on your logs before deploying this change. You may have a lot more users using your clearnet site over Tor than you expect, and deploying this kind of auto-redirect may lead to a sudden increase in traffic that might put a lot of strain on your onion service. If it looks like your onion service will need to withstand heavy load, you may wish to take a look at setting up [Onionbalance](https://onionbalance.readthedocs.io/).

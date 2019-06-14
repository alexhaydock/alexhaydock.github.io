---
layout: post
title: "Update Debian via Tor Hidden Service"
description: "Learn how to make use of the Debian project's new Tor Onion Service repositories."
category: tech
---
This post is intended to serve as an easy guide to masking metadata when downloading updates for Debian systems. We can accomplish this by configuring our system to always update via the semi-official Debian Tor onion service mirror.

This article is inspired by <a target="_blank" rel="noopener noreferrer" href="http://richardhartmann.de/blog/posts/2015/08/24-Tor-enabled_Debian_mirror/">this post</a> by Debian developer Richard Hartmann, which details his experiences with the Onion service, but my hope is that this post will act as an easy introduction for less experienced users.


#### Why is this important?
To paraphrase from <a target="_blank" rel="noopener noreferrer" href="http://meetings-archive.debian.net/pub/debian-meetings/2015/debconf15/What_is_to_be_done_Reflections_on_Free_Software_Usage.webm">a talk given by Jacob Appelbaum in 2015</a>, it is a concern that many GNU/Linux distributions (including Debian) still deliver package updates via HTTP rather than HTTPS.

There are minor benefits to serving only over HTTP for package repository maintainers, including lower resource usage (encrypted traffic requires additional processing power) and an increased likelihood that updates will be cached at various places throughout the internet, potentially reducing the amount of data that the package servers end up having to transfer.

Unfortunately, when serving over unencrypted HTTP, any party able to observe connections going to-and-from a package repository can tell at any time what package a person is downloading. As Appelbaum notes, this means that when a target is observed downloading a security update for a particular package, an adversary can make a reasonable assumption that the target is currently running the older (potentially vulnerable) version of the package, and may be able to mount an attack before the download or installation of the security update has completed. This becomes especially concerning when you consider that Debian helpfully pinpoints to an attacker which updates are to fix security holes, by hosting them at the `security.debian.org` domain.

For those wondering about what other powers an adversary with this kind of network access could be doing, it should be noted packages from all major distributions are cryptographically signed by maintainers before being added to repositories, so there is little concern that a package may be maliciously modified in transit, even when served over unencrypted HTTP.

If package repositories were equipped with HTTPS support by default, an attacker with access to network traffic would no longer be able to see which package updates a user was downloading. An attacker should only be able to see that a connection is being made to the package server, and that some (encrypted) data is being transferred.

However, as <a target="_blank" rel="noopener noreferrer" href="http://richardhartmann.de/blog/posts/2015/08/24-Tor-enabled_Debian_mirror/">Debian developer Richard Hartmann notes</a>:

>"In this specific case, [HTTPS] is not of much use though. If the target downloads 4.7 MiB right after a security update with 4.7 MiB has been released, or downloads from security.debian.org, it's still obvious what's happening."

Enter the solution: _Tor_.

For a while, Debian's repositories have housed the `apt-transport-tor` package, which allowed a user to swap the nasty `http://` links in their package repository list for `tor://` links. After doing so, all package updates and installations are performed over a Tor connection to the package server.

But we can go one better...

Enter the (even better) solution: _Tor onion services_.

If we want to make sure no metadata exists about our package transaction at all, we can use a Tor onion service to achieve this. With Tor installed and running, traffic to Tor onion services is processed the same way that requests for regular HTTP services would be, but all traffic is routed <i>within</i> the Tor network, and never touches the public internet.

If you are interested in learning more about Tor onion services and their uses, you may be interested in <a target="_blank" rel="noopener noreferrer" href="https://media.ccc.de/v/32c3-7322-tor_onion_services_more_useful_than_you_think">this extremely interesting presentation from the 2015 Chaos Communications Congress</a>, given by some of the Tor Project's core development team.

Debian developer `weasel` has come to the rescue with official Tor onion services for the Debian Project.

The onion service equivalent of [ftp.debian.org] is hosted at:
```
http://vwakviie2ienjx6t.onion/
```

And the onion service equivalent of [security.debian.org] can be found at:
```
http://sgvtcaew4bxjd7ln.onion/
```

#### Installation
Throughout this guide, any of the commands shown in code blocks are intended to be executed within a Terminal unless specified otherwise.

First, we need to install Tor itself, and some packages which will allow us to conduct package updates via Tor.
```sh
sudo apt-get install tor apt-transport-tor
```

#### Start/Enable Tor Service
Now, we need to start and enable the Tor service so that it is always available for Apt transactions.

On Debian 8 or newer, this can be done with:
```sh
sudo systemctl start tor.service
sudo systemctl enable tor.service
```

#### Point Our Sources File to the Onion Service
Our current list of package repositories is held in a "sources file" by the system. This tells the system where to look for updates. We need to swap out the addresses of our current repositories for the Tor onion service address.

First, we should backup our old sources file - just in case:
```sh
sudo cp -f /etc/apt/sources.list /etc/apt/sources.list.old
```

Now we can edit our sources file with the following command:
```sh
sudo nano /etc/apt/sources.list
```
(You can also open this in a graphical text editor like `gedit` or `leafpad` if you prefer).

Insert the Tor onion service URL in place of the main Debian repo addresses found in the file, and quit - making sure to save the changes!

If you are using Debian 8 (aka Debian Jessie), your edited sources file might now look something like this (for clarity, I have included my entire file):
```
deb tor://vwakviie2ienjx6t.onion/debian jessie main
deb-src tor://vwakviie2ienjx6t.onion/debian jessie main

deb tor://sgvtcaew4bxjd7ln.onion jessie/updates main
deb-src tor://sgvtcaew4bxjd7ln.onion/ jessie/updates main

deb tor://vwakviie2ienjx6t.onion/debian jessie-updates main
deb-src tor://vwakviie2ienjx6t.onion/debian jessie-updates main
```

You might also wish to add `non-free` to the end of each line in the `sources.list` file if wish to use software that doesn't fully comply with the <a target="_blank" rel="noopener noreferrer" href="https://www.debian.org/social_contract#guidelines">Debian Free Software Guidelines</a>. The non-free repository must be enabled to install proprietary software. Some examples of proprietary packages you may wish to install might include the <code>firmware-iwlwifi</code> package to allow the use of Intel Wi-Fi cards, or the <code>nvidia-driver</code> package to make use of NVIDIA graphics cards.

#### Reboot, Clean our Package Cache, Then Run our First Tor-powered Update
After editing the sources file, we need to reboot (this might not be strictly necessary but I had some systems refuse to download anything via Tor until a reboot was performed).
```sh
sudo shutdown -r now
```

After rebooting, we are ready to perform our first update. First, clean the cache to remove any old package lists or half-downloaded items.
```sh
sudo apt clean
```

Now, update the package list (you should see the .onion address scrolling along the screen repeatedly while this is happening) and then run a system update.
```
sudo apt update && sudo apt upgrade
```

Congratulations! Now all future updates and package installations will be carried out using the Tor onion service - making you and your system just a little bit more secure.

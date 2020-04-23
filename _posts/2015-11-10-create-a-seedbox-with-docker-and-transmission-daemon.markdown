---
layout: post
title: "Create a seedbox with Docker and transmission-daemon"
description: "Learn how to build a (reasonably) secure seedbox with Docker and transmission-daemon."
category: tech
---
_**Update (May 2018):** This guide has been updated to use my Docker container for installation and setup, rather than the old method of simply installing the `transmission-daemon` package._

It is remarkably simple to use the `transmission-daemon` package to create a Linux-based seedbox that runs on essentially whatever type of device you can think of, effortlessly handling your BitTorrent downloads/uploads.

Since there is a great deal of variation in the hardware or software that can be used for this guide, hardware choices and OS installation will not be covered here. You can really build a "seedbox" out of any kind of hardware you want.

#### Installing Transmission
In this guide, we will install [Docker](https://www.docker.com/) and use it to run my `transmission-daemon` container.

Docker allows us to run apps inside [containers](https://en.wikipedia.org/wiki/Operating-system-level_virtualization), allowing us to run Transmission in a secure and sandboxed environment that only grants it enough permission to read and write to the areas of our system we specifically allow.

We can install Docker on a Ubuntu system with the command below. Most Linux distributions will also package Docker in their main repositories, or you can find specific instructions [on the Docker site](https://www.docker.com/get-docker).
```sh
sudo apt install docker.io
```

It's probably helpful at this point to add your current user to the `docker` group so you can use Docker commands without needing root access:
```sh
sudo usermod -a -G docker $(whoami)
```

#### Configure Transmission
Before we go starting Transmission and expecting everything to just work, we need to create a directory and put our config file in it.

Transmission ships with a default `settings.json` file for configuration, but I have included a mildly-modified version [here](/assets/static/settings.json.txt) for convenience. This version makes a few changes that make life with Docker easier, and should make a good starting point to work from.

Create a directory somewhere and save this file as `settings.json`. Take note of this location. It will permanently hold your Transmission config,

#### Common Config Options
Now we can edit the `settings.json` file we just downloaded. You can find the configuration options online, but there aren't many that we need to change to get this working.

#### Ports
The `peer-port` option defines the port that Transmission will listen on when transferring data over BitTorrent. You can change this to any value you really want between maybe `10000` and `65000` but the important thing is that we remember it for later.
```json
"peer-port": 51413,
```

The `peer-port-random-on-start` option does exactly what it seems like and will pick a random port for Transmission to use every time it starts up. We definitely need this disabled due to the fact that we need to know specifically what port we're using so we can tell Docker later.
```json
"peer-port-random-on-start": false,
```

#### Remote Connection Whitelist
The remote connection whitelist is a whitelist of IP addresses or ranges which are allowed to connect to Transmission's web interface. By default, we probably want to put in all of the networks found in [RFC 1918](https://datatracker.ietf.org/doc/rfc1918/), which defines all of the IP address ranges which should be treated as "private networks".

The main benefit of doing this is to protect ourselves in case we accidentally allow incoming connections to the WebUI from the internet somehow. As our config will be set up to only listen for connections from local addresses, it will not serve any machine connecting from the open internet.

Alternatively, if you know the specific IP addresses of any machines you will be connecting from, you could enter those here. If you are running the container locally only, it may be tempting to restrict this list just to connections from `127.0.0.1`, but since we are using a Docker container we need to ensure that (at least) the `172.*.*.*` range used by Docker is also in the whitelist. (Yes I know that RFC 1918 only defines `172.0.0.0/12` as a private network and this will allow anything from `172.0.0.0/8`, but the Transmission config does not support CIDR notation and it still gives us increased security vs not having any whitelist.)
```json
"rpc-whitelist": "127.*.*.*,192.168.*.*,172.*.*.*,10.*.*.*",
"rpc-whitelist-enabled": true,
```

#### Remote Access Password
The options below can be set to ensure that a username and password are needed to connect to Transmission. They should be fairly self-explanatory:
```json
"rpc-authentication-required": true,
"rpc-password": "nicelongpassword",
"rpc-username": "usernamehere",
```

When you enter a password in the settings file above in plaintext, it will automatically be converted to a hash the first time Transmission runs. This ensures that the password is not stored unnecessarily in plaintext in your config file.

#### Other Options
The config options I have covered in this guide are really the main ones that you will need to ensure that Transmission will _work_ inside your Docker container the way you would expect it to, but you are free to change other options which you think might be beneficial.

For a full guide on Transmission's `config.json` syntax, see [this wiki page](https://github.com/transmission/transmission/wiki/Editing-Configuration-Files).

#### Launching Transmission
You can launch Transmission with Docker Compose using a simple file that looks like this:
```yaml
version: "2.3"

# Set the USERID and GROUPID environment variables to the User/Group
# IDs that you want Transmission to run under.
services:
  transmission:
    image: registry.gitlab.com/alexhaydock/docker-transmission:latest
    container_name: transmission
    environment:
      USERID: "1000"
      GROUPID: "1000"
    mem_limit: 2G
    ports:
      - "9091:9091"
      - "31967:31967"
      - "31967:31967/udp"
    volumes:
      - /home/a/TransmissionConf:/transmission/config
      - /home/a/TransmissionDownloads:/transmission/downloads
```

For some explanation of what's going on above:

The `USERID` and `GROUPID` variables set in the `environment:` section allow you to run Transmission as a different user or group ID. This is useful for controlling permissions on your host system. In the example above, Transmission will run with a user ID and group ID of `1000`. This will probably make file manipulation nice and convenient, as this is probably the same ID as the primary user on your host system. This means effectively that files can be manipulated by the Transmission user as if it was the primary user on the system. This may not be what you desire, for security reasons or convenience reasons, so you can change the IDs Transmission uses in this file. Most people can probably leave this at `1000`.

The `mem_limit` sets a value limiting the maximum memory that the Transmission container can use. 2GB seems to be a sensible limit so I have configured this here.

The `ports:` directive specifies the ports that will be accessible from outside the container. Here we need to specify two ports. `9091` is the default port for access to the Transmission interface, and in this example `31967` is the port we have chosen for transferring torrent data. We need to declare the `31967` port twice as you will see -- once for TCP, which is the default, and once for UDP, which we specify by including `/udp`.

The `volumes:` directive allows us to mount filesystems inside the container. This is where we will keep Transmission's config data, and any data we download. We need to do this so that it is accessible outside the container, and so the data persists after the container is stopped. Here I mount a `TransmissionConf/` directory from my home directory into `/transmission/config` inside the container. And I mount a `TransmissionDownloads/` directory into the container as `/transmission/downloads`. It's probably a good idea to leave the container paths (to the right side of the `:` character) the same when you're editing this config file, but you're free to mount the Config and Data directories from wherever you please on your host system. Just be aware that if you changed the `USERID` or `GROUPID` earlier then whichever IDs you chose will need to have write access to the files in question.

You can change the ownership of files (for instance to a user and group ID of `5001`) with:
```sh
sudo chown -R 5001:5001 /path/to/directory
```

Once we're happy with our Docker Compose file, we can save it as `docker-compose.yml` and then run:
```sh
docker-compose -f /path/to/docker-compose.yml up -d
```

When we run the above command, not much output will turn up in the terminal (beyond downloading the Docker image if you didn't already have it). To check it's definitely running, we can use `docker ps`. For more info about debugging and interacting with Docker containers, see the Docker documentation.

#### Connecting Remotely via Web Browser
We can now connect to our Transmission instance by inputting the IP address of our server and the port defined in the `rpc-port` value into a web browser, for example:
```
http://192.168.1.10:9091/
```

Now, after entering the `rpc-username` and `rpc-password` also defined in the config file, we should be able to interact with Transmission through our web browser.

<div class="img">
  <img class="col three" src="{{ site.baseurl }}/assets/img/transmission-webui.png">
</div>

Try adding and removing some torrents!

#### Connecting Remotely via Transmission Remote GUI (Optional)
The Transmission web interface may work well for you, in which case you don't need to follow the rest of this guide and are now done!

If, however, you prefer the look of more traditional desktop clients, [Transmission Remote GUI](https://github.com/transmission-remote-gui/transgui) is a wonderful piece of software that allows you to connect to `transmission-daemon` with a GUI that strongly resembles the _uTorrent_ or _Deluge_ BitTorrent clients.

You can install it on most distributions as the `transgui` package, and it is also available for Windows and OS X on the official site.

Once you have installed the software, launch it. You will be presented with a graphical configuration tool that allows you to enter the details of the system running `transmission-daemon`.

An example using appropriate settings is shown below:

<div class="img">
  <img class="col three" src="{{ site.baseurl }}/assets/img/transgui-settings.png">
</div>

Not much of this will differ for you, but you probably want to change the IP address to the address of the target machine, and the port if you changed the `rpc-port` value. You will obviously want to change the username and password fields also.

After completing this configuration, save it and Transmission GUI should connect to the `transmission-daemon` process running on the remote machine.

<div class="img">
  <img class="col three" src="{{ site.baseurl }}/assets/img/transgui-example.png">
</div>

You are now connected to Transmission and can freely add/remove torrents at will. Downloads and uploads will continue when you disconnect, and even if you turn the machine off that you are connecting from. As long as the machine running `transmission-daemon` remains on, you will continue to contribute to the BitTorrent community.

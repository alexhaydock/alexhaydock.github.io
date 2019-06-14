---
layout: post
title: "Fix Tor Onion Services on CentOS or Fedora (without disabling SELinux!)"
description: "a.k.a. How I abuse Docker to deal with an annoying issue in SELinux without compromising security."
category: tech
---
You're probably reading this page because you run CentOS or Fedora, and you're trying to host a Tor onion service which is just refusing to work. Hopefully I can help there.

#### Problem Overview
There are many reasons why CentOS and Fedora are both attractive distributions for webserver use. CentOS is rock-solid stable and comes with a 10-year support period, and Fedora has all the shiny new features and packages that you might want for development. Both distributions are also attractive in that they enable the SELinux kernel security tool out of the box.

Before we go any further, I just want to join the chorus of sysadmins and security gurus who like to shout at people to [stop disabling SELinux](http://stopdisablingselinux.com/)! It can be a pain, but it offers great protection and it can be tamed where necessary.

If you're reading this page then you will no doubt have noticed that attempting to set up a Tor onion service with SELinux enabled will throw up a confusing permissions error that might look something like:
```
Nov 09 22:05:18 hostname tor[7561]: Nov 09 22:05:18.245 [warn] Directory /var/lib/tor/hiddenservice/ cannot be read: Permission denied
```

or maybe:
```
Nov 09 22:12:33.119 [warn] /var/lib/tor/hiddenservice/ is not owned by this user (root, 0) but by toranon (997). Perhaps you are running Tor as the wrong user
```

I posted about this issue on Stack Exchange [way back in 2015](https://superuser.com/questions/998850/tor-hidden-service-settings-failing-to-allow-tor-service-to-start-on-centos-fedo/1230324) and it also seems to be featured as a bug in [Red Hat's bugtracker](https://bugzilla.redhat.com/show_bug.cgi?id=1292626), but as of 2018 this problem appears to still persist.

#### A Potential Fix
As Sean McLemon suggests [in his blog post here](http://blog.mclemon.io/fedora-getting-tor-and-selinux-to-play-nice), one thing we can do is attempt to start the `tor` service as normal after adding our hidden service lines to the Tor config, and then use `audit2allow` to generate an SELinux policy as follows:
```
sudo ausearch -c 'tor' --raw | audit2allow -M tor-selinux-workaround
```

The above command will parse recent SELinux permission denials and generate a policy file called `tor-selinux-workaround.pp`, which we can then load into SELinux with the `semodule` command.

#### The SELinux Common Intermediate Language
The method described above does actually _work_, but I'm not a huge fan of using `audit2allow` and leaving it at that. The `.pp` modules it generates are a binary file format, and this makes them difficult to parse to ensure that they're only adding exceptions for what is strictly necessary and not catching anything else that might also have been in the logs.

We can sort this out by adding an extra step to the process, converting our binary files into the human-readable [Common Intermediate Language](https://github.com/SELinuxProject/cil/wiki) format, which we can then edit manually:
```
cat tor-selinux-workaround.pp | /usr/libexec/selinux/hll/pp > tor-selinux-workaround.cil
```

The `.cil` file can then be opened in a regular text editor and edited. After narrowing down to the absolute minimum number of exceptions that Tor needs in order to work with onion services, my file has only two lines:
```
(typeattributeset cil_gen_require tor_t)
(allow tor_t self (capability (dac_override dac_read_search)))
```

Now we _could_ load this into SELinux with the following command:
```
sudo semodule -i tor-selinux-workaround.cil
```

If you're not interested in getting stuck in with Docker or containers, then the above command will work for you...**but** upon closer inspection, now that we can read the raw CIL, we can see what's actually going on when we run it.

As we can see, the SELinux fix sets exceptions for the two [Linux Capabilities](https://linux.die.net/man/7/capabilities): `CAP_DAC_OVERRIDE`, and `CAP_DAC_READ_SEARCH`. DAC stands for Discretionary Access Control (file permissions, in other words).

According to SELinux guru [Dan Walsh](https://danwalsh.livejournal.com/69478.html), "a process running as `UID=0` with `DAC_READ_SEARCH` can read any file on the system, even if the permission flags would not allow a root process to read it.  Similarly `DAC_OVERRIDE`, means the process can ignore all permission/ownerships of all files on the system."

As the Tor binary does indeed launch as root (it then drops privileges based on how the "User" line is set in `/etc/tor/torrc`), setting these permission exceptions for Tor is certainly not the most secure solution we could come up with. It's definitely worlds away from disabling SELinux outright, but we can still do better.

#### Using Docker for a Better (Lazy) Fix
So my ultimate solution to this was that I still wanted my Tor daemon to be constrained by SELinux, and prevented from messing with anything on my host.

At this point, I decided to opt for a Docker based solution.

It's very simple to create a [Dockerfile](https://docs.docker.com/engine/reference/builder/) that will allow us to run Tor inside a container with all of the capabilities it would otherwise have on the host.

The Dockerfile below should be all that we need:
```
FROM alpine:3.8
LABEL maintainer "Alex Haydock <alex@alexhaydock.co.uk>"

COPY torrc /etc/tor/torrc

RUN set -xe \
    \
# Install Tor
    && apk --no-cache add tor shadow \
    \
# Change Tor user to a high UID that's unlikely to conflict with anything on the host
    && usermod -u 7942 -o tor \
    \
# Remove the shadow package (we only needed it for the usermod command)
    && apk del shadow

# Runtime settings
USER tor
ENV HOME "/var/lib/tor"
WORKDIR ["/var/lib/tor"]
CMD ["/usr/bin/tor", "-f", "/etc/tor/torrc"]
```

As you will note, what happens here is that Docker uses an [Alpine Linux](https://www.alpinelinux.org/) based container for our image. It then installs Tor into this image, and changes the UID of the `tor` user to a high one. This means that when we run Tor inside the container, it is running as a UID which is very unlikely to match any user that exists on the host.

You will also notice that the Dockerfile specifies `USER tor`. This means that containers which are launched based on this Dockerfile will `always` run the Tor process as an unprivileged user. We can get away without launching Tor as root, so why wouldn't we?

The final piece of our puzzle is to build this container. For that, we need Docker installed, and this Dockerfile along with a `torrc` file in the same directory.

The `torrc` file can literally be this simple:
```
SOCKSPort 0

HiddenServiceDir /var/lib/tor/hiddenservice
HiddenServicePort 80 123.123.123.123:80
```

In this example, Tor will not start a SOCKS5 proxy, and will serve a hidden service on port `80`. Requests to the hidden service on that port will be directed to `123.123.123.123` also on port `80`.

Let's build our container. Enter the directory holding the `Dockerfile` and `torrc`, and run:
```
docker build -t tor .
```

When this completes, we can now run the container:
```
docker run -d --name=tor --restart=always -v "/path/to/keys/on/host":"/var/lib/tor/hiddenservice":Z tor
```

The above command will `run` the `tor` container in `-d`etached mode, and will `always` restart it (e.g. It will come back up when we reboot the system).

You will also notice that we pass an argument with `-v` that consists of a directory path on our host (`/path/to/keys/on/host`) and a corresponding path inside the container (`/var/lib/tor/hiddenservice`). The path inside the container is the one Tor is expecting as per our `torrc` above. We want to mount this host directory into the container so that when Tor creates our hidden service private keys and hostname, they are kept somewhere safe (on the host) and not inside the container, where they would be lost when the container was stopped or restarted. The `:Z` option is for SELinux and ensures that the Docker daemon [appropriately sets labels](https://docs.docker.com/storage/bind-mounts/#configure-the-selinux-label) for the directory on the host so that it may be accessed inside a container.

We do, however, need to ensure that the directory path on our host is owned by the same UID that is running Tor inside the container (yes, permission issues again!). We can do that simply with:
```
sudo chown -R 7942 /path/to/keys/on/host
```

As long as we securely keep the contents of the above directory, we can migrate this container to another host with ease, or re-build it when updates are required.


#### Other Fun Container Options
Not content with simply **avoiding** granting additional Linux Capabilities to our Tor process, we can take advantage of the fact that our process is now running in a container and use Docker's `CAP_DROP` feature to **actively prevent** processes within the container from using **any** such capabilities.

This might not seem like much of a realistic attack vector since we're not running the Tor process as root (as capabilities only apply to processes run as root), however dropping all ability to use capabilities ensures that many potential privilege escalation exploits are thwarted (e.g. those which might rely on a vulnerable [SUID](https://www.linux.com/blog/what-suid-and-how-set-suid-linuxunix) binary).

We can add this additional security with the `--cap-drop=all` flag:
```
docker run -d --name=tor --restart=always --cap-drop=all -v "/path/to/keys/on/host":"/var/lib/tor/hiddenservice":Z tor
```

Now, we can test that the capabilities of our running container have been effectively dropped by running (`docker exec` runs this command inside our existing `tor` container):
```
docker exec -it tor /bin/grep Cap /proc/self/status
```

We should see:
```
CapInh:	0000000000000000
CapPrm:	0000000000000000
CapEff:	0000000000000000
CapBnd:	0000000000000000
CapAmb:	0000000000000000
```

And we can compare this result to an unconfined Alpine Linux container like so:
```
docker run -it alpine /bin/grep Cap /proc/self/status
```

We will probably see something like:
```
CapInh:	00000000a80425fb
CapPrm:	00000000a80425fb
CapEff:	00000000a80425fb
CapBnd:	00000000a80425fb
CapAmb:	0000000000000000
```

For a full explanation of the above output, you can see [this Project Atomic blog post](https://www.projectatomic.io/blog/2016/01/how-to-run-a-more-secure-non-root-user-container/), but if you see only zeroes for your container, then the capability restrictions are working nicely, and you can relax safely and securely and enjoy the fact that your Tor process is thoroughly contained and constrained.

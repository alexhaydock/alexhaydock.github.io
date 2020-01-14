---
layout: post
title: "Configuration (mis)management: breaking back into my own production systems with Docker"
description: "Say it with me: the <code>docker</code> group is root."
category: tech
---
#### TL;DR
If you somehow made it here looking for a one-line solution to give yourself `sudo` privileges when you're already a member of the `docker` group, try:
```sh
docker run --rm -it -e HOSTUID="$(id -u)" -v "/:/host:rw" "registry.gitlab.com/alexhaydock/getroot:$(uname -m)"
```

***
#### Unforeseen Circumstances
Over the past year, I have been working on migrating to Ansible for managing all the servers for various projects. Some are physical, some are on various cloud providers. Essentially the point is that my projects are all over the place in many locations and with many purposes, and there's lots of them. And that's where the fun starts to begin.

It's a normal day, and I'm logged into one of these project boxes, and I go to check for updates...

Wait... what's this?

```sh
$ sudo apt-get update
alex is not in the sudoers file.  This incident will be reported.
```

Great... this wasn't exactly what I was expecting. Everything worked fine just the day before. I hadn't changed anything significant recently, and I definitely had administrator privileges before that.

<div class="img">
  <img class="col three" src="{{ site.baseurl }}/assets/img/xkcd-sudo.png">
</div>
<div class="col three caption">I'm a little worried about how my Xmas presents are going to look this year. <a href="https://xkcd.com/838/">(XKCD: Incident)</a></div>

<br>
It took me a little while to develop a theory about what might have happened. But first, it's worth delving into how sudo privileges are assigned on Ubuntu.

The error message noted that I was `not in the sudoers file`. The `sudoers` file, generally at `/etc/sudoers`, defines the users who are allowed to use the `sudo` command. On Ubuntu systems, the main user created during installation is not added specifically to this file, but is instead added to the `sudo` group. The default `sudoers` file on Ubuntu defines all members of the `sudo` group as being able to, you guessed it, use `sudo`.

Indeed, when running `groups`, we find out that our user is definitely not a member of the `sudo` group as we would expect:
```sh
$ groups
alex docker
```

#### Configuration (Mis)management
Looking at the group list above, it started to dawn on me what might have happened. I mentioned before that I had been working on migrating all my config management to Ansible. Sure enough, I had written a playbook a few weeks ago that added my user to the `docker` group (yes yes, I know, but we'll return to that decision later).

I checked my playbook and, sure enough, here was the offending section:
```yml
- name: Add user to Docker group
  user:
    name: alex
    groups: docker
```

I checked the Ansible documentation [for the `user` module](https://docs.ansible.com/ansible/latest/modules/user_module.html) and spotted my mistake immediately. The `append` parameter controls whether the groups in your list are _appended_ to the user's current list of groups, or whether the groups you list will become the _only_ groups the user is a member of. I'd completely overlooked this section of the documentation, and I'd left the `append` parameter out of my playbook entirely.

As you might have guessed by now, the default is `append: no`. When I defined the `docker` group in my playbook, Ansible helpfully ensured that my user was a member of _only_ the `docker` group (it is also a member of its own user group, but that doesn't do us a whole lot of good).

This also explains why so much time was able to pass between me making the broken change that introduced this bug, and seeing it live on a system. Group membership on Linux generally apparently takes effect at login, and these systems typically are only rebooted every few weeks or for major kernel/systemd upgrades. That made this one of those wonderful bugs which lies dormant for a while, only to show up unexpectedly when you'd almost completely forgotten about the specific script or config change you made three weeks back that might have introduced it.

But it gets worse. In those three weeks, I kept building on this playbook; tweaking it, adding roles, adding tasks, and, crucially, deploying it to production systems... and tweaking it, and building upon it, and deploying it some more. Until -- as I realised with a rush of horror -- I had pushed this broken change to almost every system I manage.

For readers who have never met me in real life -- and have thus been spared the chore of hearing long rants about how amazing Docker is and how everything should be in containers -- I feel like it might be much needed context to explain that I _love_ containers. I love the idea of stateless, idempotent systems and infrastructure as code that makes scaling up and down a dream and migration nearly effortless. So I end up running pretty much _everything_ in containers. Normally, this works like a dream. But today it had been my downfall. The only system which had been spared from the broken config push was a single lonely Raspberry Pi connected to my stereo that does nothing but play music.

Okay, no problem. We can still fix this. We might not be able to use `sudo`, but we can still `su` to `root` with the root password and sort everything back out, right?

Well, no. On Ubuntu systems the root account does not have a password set by default, which effectively locks the account. The idea is that instead of running anything as `root`, individual actions are given run with privilege by regular users using `sudo`. At this point I have realised that I am effectively locked out of all of these boxes. I'm left without any real way of doing _anything_ which might require privilege. On all of my production systems. Ouch.

I collapsed into my chair with a sigh and resigned myself to pondering my next move while listening to R.E.M's [It's the End of the World as We Know It](https://www.youtube.com/watch?v=8OyBtMPqpNY)... on the only working system I had left.

#### Regaining Control
If you read forums and support pages for Docker, you'll find some _very_ strong opinions about whether it's ever sensible to add users to the `docker` group. Those in favour will tell you that adding a user to the `docker` group makes it much easier to manage Docker containers, as it gets rid of the need for nagging password prompts every time you want to do anything at all with Docker or containers. But on the other hand, opponents will tell you that doing so is a serious security risk, as it effectively provides the otherwise unprivileged user unchecked access to the Docker socket without a password.

The latter concern is particularly important in multi-user deployments. For myself, though, I was the only (human) user on all these systems, so I didn't consider the concerns to be much of a problem for my threat model. I could trust _myself_ at least, surely?

Either way, I had taken the decision to add my user to the `docker` group. Sure, I had broken all the other groups in the process, but our Ansible playbook had at least dutifully added our users to the `docker` group as requested. So what does this mean for us?

Well, full access to the Docker socket gives us the ability to interact with Docker at will, creating and destroying containers as we please. By default, most Docker containers run with the user inside the container having a UID of `0`, aka `root`. This allows us to manipulate files, folders and applications inside a container as if we are root and without needing to worry about permission issues. Crucially, Docker also allows us to use [bind mounts](https://docs.docker.com/storage/bind-mounts/) to mount directories from our host system into containers.

So I fired up a quick test to confirm whether my thinking was on the right track:
```sh
docker run --rm -it -v /etc/shadow:/opt/etc/shadow alpine:latest
```

The above command is quite simple and just mounts the `/etc/shadow` file to the location `/opt/etc/shadow` inside an Alpine Linux container.

When we try to view the shadow file _on the host_, we get:
```sh
$ cat /etc/shadow
cat: /etc/shadow: Permission denied
```

But when we try _inside our new container_, we can read the file just fine, mounted from the host:
```sh
root@47f4da624aae:/# cat /opt/etc/shadow
root:!:18242:0:99999:7:::
daemon:*:18186:0:99999:7:::
bin:*:18186:0:99999:7:::
[...]
```

So because we can create Docker containers, and run as `root` _within_ the containers, we are able to use Docker bind mounts to manipulate files on the host as if we were `root` on the host. This is looking good for us. So what exactly can we do with this?

Could we edit the shadow file directly to enable the root account and set a password? This was my first thought but, after some ~~investigation~~ Stack Overflow, [it doesn't seem like a good idea](https://unix.stackexchange.com/questions/190241/why-should-you-never-edit-the-etc-shadow-file-directly).

So let's try something a bit cleaner and see whether we can edit the `/etc/sudoers` file that I mentioned earlier:.
```sh
root@47f4da624aae:/# echo "alex ALL=(ALL:ALL) ALL" >> /etc/sudoers && visudo -cf /etc/sudoers
/etc/sudoers: parsed OK
/etc/sudoers.d/README: parsed OK
```

Shockingly, this worked! I was able to use `sudo` again, and was able to use my newly-regained privileges to restore my group membership to the groups I had been in previously.

#### Hair of the Dog
So I could regain control on a system-by-system basis, but this wasn't going to be enough. I had automated myself into this mess, and I was determined to automate myself out of it. Could I turn this aronud and use the tools that had already stung me to fix the issue I'd caused?

I took what I had learned above, and wrapped it up [into a Docker container](https://gitlab.com/alexhaydock/getroot) to automate the privilege escalation process, and pushed it to my GitLab container registry. You can go and have a look, and build/run the container for yourself. It's the same one in the command at the top of the article, and should work on `x86_64`, `armv7l` and `aarch64` systems.

So now that I had a nice concise single-line way of exploiting my own systems, I could turn back to Ansible to automate the process of deploying it, as so:
```yml
- name: Find our UID on the remote system
  command: "id -g"
  register: uid

- name: Just a nice friendly Docker privilege escalation 🐳
  docker_container:
    image: "registry.gitlab.com/alexhaydock/getroot:{{ ansible_architecture }}"
    env:
      HOSTUID: "{{ uid.stdout }}"
    volumes:
      - /:/host

- name: Restore the default Ubuntu groups for an unprivileged user
  user:
    name: "{{ ansible_user_id }}"
    group: "{{ ansible_user_id }}"
    groups: adm,cdrom,docker,sudo,dip,plugdev,lxd
```

And voilà... I tested this thoroughly of course (lessons had been learned) and then pushed it to all my systems, restoring my access and taking me right back to where I was before making my broken change a few weeks earlier, stronger and wiser.

#### Lessons Learned
* Configuration management is fantastic, as it lets you quickly push minor config changes automatically to a huge number of systems.
* Configuration management is terrible, as it lets you quickly push minor config changes automatically to a huge number of systems.
* RTFM, and _test your code_! Since this, I have implemented a strategy with Vagrant and Test Kitchen which allows me to test my configuration changes before I deploy them and catch any issues before they spiral out of control.
* The `docker` group is root. Don't add any users to the `docker` group who shouldn't have root access to the system.
* I tested this on a system running SELinux and access to the `/etc/shadow` and `/etc/sudoers` files was completely blocked from inside the container. If I'd been running Fedora or CentOS instead of Ubuntu I'd probably be cursing myself right now and going through the pain of rebuilding 20+ systems, but it just goes to show that SELinux *works*! [Don't disable it](https://stopdisablingselinux.com/).
* Further to the above, Red Hat's (fully compatible) answer to Docker is called [Podman](https://podman.io/) and doesn't require a big heavy daemon running as `root` like Docker does. This means there's no need for a specific group to allow unprivileged users to access the daemon. There isn't one.
* Podman allows unprivileged users to run containers completely rootless.
* The [user namespace](https://www.redhat.com/sysadmin/rootless-podman-makes-sense) tools that Podman uses make managing bind-mount permissions a dream.
* Yes, I'm switching to Podman. Can you tell?

So, I learned a few painful lessons through this process and through subsequent investigation which I'm going to apply to how I deploy things in the future, and I consider myself stronger and more informed for it.

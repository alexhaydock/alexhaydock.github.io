---
layout: post
title: "Dear Hollywood: Stop using fake IP addresses!"
description: "86.7.5.309"
category: tech
twittertitle: "Dear Hollywood, Stop using fake IP addresses!"
twitterdescription: "86.7.5.309"
twitterimage: ip_tool.png
twittercard: big
---
So if you're my kind of nerd then you've spotted it a hundred times already... You're just getting to love a TV show or movie and then they drop an unforgiveable bombshell: the obviously fake IP address.

<div class="img">
  <img class="col three" src="{{ site.baseurl }}/assets/img/ip_poi.jpg">
</div>
<div class="col three caption"><a href="https://www.youtube.com/watch?v=aw67xWCHxqE">Person of Interest (S01E13)</a></div>
<br>

Back in 1981, pop band Tommy Tutone [sang about a mysterious woman called Jenny](https://www.youtube.com/watch?v=0V40eNJ8MIQ). From the lyrics, Jenny left her name and number scrawled the stall of a men's bathroom. Popular for its earworm chorus, the song revolves around a repeating refrain: the phone number 8675-309.

> Jenny don't change your number<br>I need to make you mine<br>Jenny I call your number<br>867-5309

Jenny rapidly hit #4 on the Billboard Hot 100 chart. What's notable about the song is that the number used, 8675-309 is a real and routable phone number. Indeed, lead singer Tommy Heath [confirmed many years later](https://www.youtube.com/watch?v=6aeBlPysd1E) that the number belonged to someone he knew.

As the song grew in popularity, it spurred a deluge of prank calls to owners of 8675-309 numbers asking for "Jenny". Without an area code prefix, the number is treated as a local number when dialled so there are likely thousands of unfortunate "Jennies" across the United States who received countless prank calls as a result of the song.

This is [confirmed by Snopes](https://www.snopes.com/fact-check/867-5309-jenny/), which suggests that calls to the number still haven't entirely stopped, some 40 years later. The [Jenny Network](https://jennynetwork.com) owns one of these numbers, and posts voicemails to the number on their website for all to listen to -- though sadly at this stage it seems to be flooded more by telemarketers than Jenny pranksters.

<div class="img">
  <img class="col three" src="{{ site.baseurl }}/assets/img/ip_thenet.jpg">
</div>
<div class="col three caption"><a href="https://www.imdb.com/title/tt0113957/">The Net (1995)</a></div>
<br>

At the time Tommy Tuetone's track was released, telephone companies in the US had already been encouraging TV and movie producers to use the 555 prefix for fictional numbers for nearly two decades. According to Wikipedia, some early examples include [The Second Time Around (1961)](https://www.imdb.com/title/tt0055421/), which used 555-3485, and [Panic in Year Zero! (1961)](https://www.imdb.com/title/tt0056331/), which used 555-2106.

In the UK, Ofcom maintain a detailed list of non-routable UK numbers which can be used for TV and movie productions, including specific geographic area codes for extra realism. Indeed, this blog post and tool were inspired by a tool developed by Neil Brown, which will [generate a number from this range](https://neilzone.co.uk/number/) for you to use.

So, back to our main topic: fake IP addresses. With the fate of the thousands of unfortunate "Jennies" in mind, it's easy to see why writers and technical advisors to productions might choose to use fake IP addresses. Real and routable IP addresses will belong to someone or some entity somewhere and it's easier to just avoid any issues by using an IP address that's completely non-functional.

There are a few ways I've seen to mangle an IP address. In the most common notation we're familiar with, IPv4 addresses are split into four 8-bit octets (`254.254.254.254`). Often one of the four octets of the address will contain a number greater than the maximum that can be held by an 8-bit value (`254`), making the address invalid.

<div class="img">
  <img class="col three" src="{{ site.baseurl }}/assets/img/ip_csi.jpg">
</div>
<div class="col three caption"><a href="https://www.imdb.com/title/tt0113957/">CSI: Miami</a></div>
<br>

I've also seen some pretty egregious examples which add a fifth entire octet to the IP address, creating some abomination like `172.16.43.199.320`. Unfortunately (fortunately?) I wasn't able to find any visual examples of that approach in action.

Some writers opt to use link-local addresses onscreen instead. These addresses represent local networks and are not routable via the wider internet, so are safe from the Jenny problem. However, particularly pedantic viewers will then snort derisively if the plot involves these addresses belonging to remote internet resources.

So what can writers to do be more accurate, and to avoid ripping pedants like myself out of our collective suspended disbelief while watching?

Well, just like the 555 ranges used in the USA and the Ofcom ranges in the UK, there are ranges of IP addresses reserved for use in fictional works. These addresses are non-routable and can be freely used in TV, movies and documentation without worrying that they will belong to some unfortunate person in the future.

The Internet Engineering Task Force (IETF) maintains two documents which define ranges of addresses for this: [RFC 5737](https://tools.ietf.org/html/rfc5737) for IPv4 addresses, and [RFC 3849](https://tools.ietf.org/html/rfc3849) for IPv6 addresses.

The IPv4 ranges that can be used are:
* 192.0.2.0/24 (TEST-NET-1)
* 198.51.100.0/24 (TEST-NET-2)
* 203.0.113.0/24 (TEST-NET-3)

and the reserved IPv6 address range:
* 2001:DB8::/32

If these look confusing, it's because they are presented in [CIDR notation](https://en.wikipedia.org/wiki/CIDR_notation), which is a way of defining a range of IP addresses that can be used.

To make things easier, I have produced a tool which will randomly generate a TV and movie ready address for you, which you can find by clicking on the image below.

<div class="img">
  <a href="/ip"><img class="col three" src="{{ site.baseurl }}/assets/img/ip_tool.png"></a>
</div>
<div class="col three caption"><a href="/ip">My RFC 5737 Tool</a></div>
<br>

So this post is just a bit of fun and my tool doesn't support IPv6 ranges yet, but hopefully you enjoyed this brief glimpse into "things that shouldn't bother me as much as they do".
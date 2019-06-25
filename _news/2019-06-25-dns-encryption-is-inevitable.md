---
layout: post
title: "DNS Encryption is Inevitable: The Government Must Embrace It"
date: 2019-06-25
inline: false
---
<div class="img_row">
  <img class="col three" src="{{ site.baseurl }}/assets/img/encrypted-dns-article-header.jpg">
</div>
<div class="col three caption">Photo by <a href="https://unsplash.com/photos/M5tzZtFCOfs">Taylor Vick</a> on Unsplash.</div>

***
A new report co-authored by myself and published yesterday by the Open Rights Group delves into the topic of encrypted DNS services and concludes that, despite recent concern from politicians, encrypted DNS is not a set of concerning anti-censorship proposals 'in the making'. Encrypted DNS revolves around fully-fledged standards already implemented by a number of devices and services, is already seeing widespread adoption from the tech industry, and provides notable benefits to user privacy.

The issue of DNS encryption has been raised in Parliament multiple times recently, including questions about its potential [impact on content blocking by ISPs](https://hansard.parliament.uk/Lords/2019-05-14/debates/E84CBBAE-E005-46E0-B7E5-845882DB1ED8/InternetEncryption#contribution-1173F87E-6D5C-4D40-AA22-AE130D5FE34C) and the Internet Watch Foundation. Concerns about the impact of encrypted DNS services on the effectiveness of age verification have [also been raised](https://hansard.parliament.uk/Commons/2019-06-20/debates/FEB4CA3E-3F17-4E1C-803A-7194ECB996FF/OnlinePornographyAgeVerification#contribution-9B5F82E0-B9A4-41F5-AD91-0A9DB75523F0) on [multiple occasions](https://hansard.parliament.uk/Lords/2019-06-20/debates/25EBF901-BE4F-488B-8AE9-9A7DB1089DE5/AgeVerification#contribution-DF6BE9F4-5287-4A44-B2EF-6E0DAD70F867).

> Does the Secretary of State agree that online companies are outsmarting the Government, and that we urgently need to know how the Government plan to catch up? <br><br> -- Cat Smith MP (House of Commons discussion, [20 June 2019](https://hansard.parliament.uk/Commons/2019-06-20/debates/FEB4CA3E-3F17-4E1C-803A-7194ECB996FF/OnlinePornographyAgeVerification#contribution-9B5F82E0-B9A4-41F5-AD91-0A9DB75523F0))

In a nutshell, most of the concern expressed about encrypted DNS is that it will lead to increased difficulty in policing internet content and filtering websites. According to an [April 2019 report in The Times](https://www.thetimes.co.uk/article/warning-over-google-chrome-browsers-new-threat-to-children-vm09w9jpr), the technologies *"will make it harder to block harmful material, including child-abuse images and terrorist propaganda"*.

Encrypted DNS generally involves one of two similar standards: [DNS-over-HTTPS](https://en.wikipedia.org/wiki/DNS_over_HTTPS) (DoH), or [DNS-over-TLS](https://en.wikipedia.org/wiki/DNS_over_TLS) (DoT). For whatever reason, most political discussion seems to only make reference to DoH, even though DoT is the older and more mature of the two standards (and has already been available [in Android since 2018](https://android-developers.googleblog.com/2018/04/dns-over-tls-support-in-android-p.html)).

At a simple level, both standards work to encrypt Domain Name System (DNS) queries issued by a user or a user's device so that they cannot be read or modified in transit between the user's hardware and the DNS server which responds to the query. DNS queries are used to translate human-readable web addresses (such as [alexhaydock.co.uk](https://alexhaydock.co.uk)) into machine-readable IP addresses (such as `185.199.109.153`). Traditional DNS services do not offer encryption which means that, **for the majority of internet users, records about the websites they visit are available to anyone with the ability to eavesdrop on their connection**. Attackers could also choose to maliciously modify the replies provided by a user's DNS server to send a user's traffic to a malicious destination.

In recent years there has been a drastic shift towards fully encrypted web services. Modern web browsers now even [mark pages which do not use HTTPS](https://www.blog.google/products/chrome/milestone-chrome-security-marking-http-not-secure/) as "Not Secure". Many of the core standards underpinning the modern internet are still relatively unchanged since their development decades ago -- before security was a major concern. Over the years, most of these have been augmented to haphazardly staple-on enough security features to remain relevant in the modern era. **Until now, DNS was one of the few core internet standards which had yet to be viably updated for the modern encrypted world.**

There are a great number of stakeholders who have already indicated their support, or intent to add support, for DoH and DoT:
* **Android** - Supports [DoT](https://android-developers.googleblog.com/2018/04/dns-over-tls-support-in-android-p.html) natively as of Android 9, and DoH via [Cloudflare App](https://play.google.com/store/apps/details?id=com.cloudflare.onedotonedotonedotone).
* **Apple iOS** - Supports DoT and DoH via [Cloudflare App](https://apps.apple.com/us/app/1-1-1-1-faster-internet/id1423538627).
* **Cloudflare DNS** - Supports [DoH](https://developers.cloudflare.com/1.1.1.1/dns-over-https/) and [DoT](https://developers.cloudflare.com/1.1.1.1/dns-over-tls/).
* **Google Chrome** - Currently testing [DoH](https://mailarchive.ietf.org/arch/msg/dns-privacy/kpt6ZYMN5H3DsXPVi_QldmbAdJw).
* **Google PublicDNS** - Supports [DoH](https://developers.google.com/speed/public-dns/docs/dns-over-https) and [DoT](https://developers.google.com/speed/public-dns/docs/dns-over-tls).
* **IIJ** *(Japanese ISP)* - Currently testing [DoH](https://twitter.com/IIJ_doumae/status/1125945383144714241).
* **Mozilla Firefox** - Supports [DoH](https://blog.mozilla.org/futurereleases/2019/04/02/dns-over-https-doh-update-recent-testing-results-and-next-steps/) natively, and plans to roll out for all users.
* **Quad9 DNS** - Supports [DoH](https://www.quad9.net/doh-quad9-dns-servers/) and [DoT](https://www.quad9.net/faq/#Does_Quad9_support_DNS_over_TLS).

It's worth noting that, since the function of a DNS server is to translate web addresses into the corresponding IP addresses required by internet connected devices, it is possible to create DNS services which provide encryption *and* also offer filtering for those who expressly wish to use it (such as parents, schools, or public Wi-Fi operators). This allows users to gain the privacy and security benefits of encrypted DNS without sacrificing the ability to filter out unwanted domains. This recommendation, along with many others, is discussed at length in the full report linked below.

The march of encryption for core web standards is inevitable. The Government must recognise the level of interest that encrypted DNS is receiving from the tech industry. The pursuit of user privacy is a central interest of many internet stakeholders and the collective interest in encrypting all of the core technologies underpinning the internet will not go away, regardless of any battles the Government may mount against DoH or DoT. Instead of fruitlessly trying to cling onto [broad and ineffective](/news/2019-05-01-isp-adult-content-filtering/) domain filtering powers, the Government must work *with* stakeholders to embrace DoH and DoT as an opportunity to provide user privacy whilst also enabling *optional* content filtering for those who expressly want it.

More detail on all of the above, including the Open Rights Group's full recommendations, can be found [in the full report here](https://www.openrightsgroup.org/about/reports/dns-security-getting-it-right).
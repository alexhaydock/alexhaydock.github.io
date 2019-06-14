---
layout: post
title: "Free for All: A simple Libreboot installation tutorial for the ThinkPad X60/X60s/X60T"
description: "Learn how to set up the open Libreboot firmware for BIOS freedom."
category: tech
---
_**Update (Feb 2018):** This guide was originally published in March 2015, at a time when the Libreboot project did not have particularly comprehensive documentation. The site has since been updated, and I recommend [checking it out](https://libreboot.org/docs/install/) instead._

Recently, the Free Software Foundation granted its first ever “Respects Your Freedom” certification [to the range of ThinkPad X60 laptops](https://www.fsf.org/news/gluglug-x60-laptop-now-certified-to-respect-your-freedom) sold by Gluglug that come pre-flashed with the free-and-open-source (FOSS) BIOS replacement ‘Libreboot’.

> “Finally there is a free software laptop that respects your freedom as it comes from the store”<br>---&nbsp;Richard Stallman

To understand the pressing need for free and open software and hardware, you may wish to watch [this TEDx talk](https://youtu.be/Ag1AKIl_2GM) by Richard Stallman, president of the Free Software Foundation.

Refurbished and “freed” models of the 2006 laptop sold by Gluglug are [sold for between £198 and £298](http://shop.gluglug.org.uk/product/ibm-lenovo-thinkpad-x60-coreboot/) at the time of writing. This cost (a substantial amount for even the most dedicated privacy advocate) is mostly as a result of the relatively high cost of obtaining ThinkPad hardware in the UK, where the Gluglug store is based. ThinkPad hardware is often cheaper elsewhere, particularly in the US.

You should be able to find budget X60 laptops on eBay today for a reasonable price and (particularly if you are US-based) this may be more cost-effective then buying a Gluglug machine. You can then follow along with this guide.

Additionally, the Gluglug store only stocks easy-to-obtain models of the laptop, featuring the 32-bit Core 2 Duo T2400 or L2400 processor. These would have been mid-range configurations at the time the laptops were sold but, in 2015's age of high definition video and content-heavy websites, these slow chips are beginning to show their age.

When originally sold, the X60 also [supported a range of more powerful 64-bit processors](http://www.thinkwiki.org/wiki/Category:X60). These are now comparatively difficult to find but, if possible, one of these will certainly represent a more capable daily-use machine than any of the 32 bit models.

For example, a Libreboot X60 with the fastest available CPU (Core 2 Duo T7200) is capable of playing back full HD 1080p video without even breaking a sweat, as seen here:

<div class="img">
  <img class="col three" src="{{ site.baseurl }}/assets/img/libreboot_bbb.jpg">
</div>
<div class="col three caption"><i>Big Buck Bunny</i> is a Blender Foundation project — available under the Creative Commons Attribution 3.0 license.</div>

Please be aware that models with more powerful processors are usually harder to find and often much more expensive.

For your convenience, a list of supported 64-bit processors in this range:

**ThinkPad X60:**
- Intel Core 2 Duo T7200 (2.00GHz)
- Intel Core 2 Duo T5600 (1.83GHz)
- Intel Core 2 Duo T5500 (1.66GHz)

**ThinkPad X60s:**
- Intel Core 2 Duo L7400 (1.50GHz)

**ThinkPad X60 Tablet:**
- Intel Core 2 Duo L7400 (1.50GHz)

Although models with the above processors will offer better performance, all models of X60, X60s or X60T (including 32-bit models) are supported by Libreboot.

### Installation Guide

#### Preparation
To prepare, install your preferred GNU/Linux distribution onto the X60. This step will not be covered in this guide. I recommend [Trisquel](https://trisquel.info/en/download), which is a fully FOSS operating system based on Ubuntu.

You will need to use a terminal to enter the commands used in this article.

#### Download
First, download the Libreboot binaries from [the official download page](http://libreboot.org/download).
Extract the download:
```sh
tar -xvf libreboot_bin.tar.xz
```
Enter the newly-created directory:
```sh
cd libreboot_bin/
```

#### Compile Required Software
To flash Libreboot successfully, `flashrom` and `bucts` must be compiled from source &mdash; and some dependencies must be installed before this can be done.

To install dependencies on **Debian-based** (Trisquel, Debian, Ubuntu, …) distributions:
```sh
sudo ./deps-trisquel
```
To install dependencies on **Arch-based** (Parabola, Arch, …) distributions:
```sh
sudo ./deps-parabola
```
Firstly, to build `flashrom` from source:
```sh
sudo ./builddeps-flashrom
```
Then, to build `bucts` from source:
```sh
sudo ./builddeps-bucts
```

#### Select Libreboot ROM to Flash
Inside the `bin/` directory of the extracted download, you will find various different Libreboot ROMs.

Select the ROM that matches your keyboard layout.

Unless you have a particular reason to choose the txtmode ROM, it is recommended that you pick the vesafb ROM that matches your hardware.

For example, the ROM I have chosen is `bin/x60/x60_ukqwerty_vesafb.rom`

#### Backup Stock Lenovo BIOS (Recommended)
In case you find that you wish to restore the default Lenovo BIOS to your machine at a later date, it is recommended that you back up the stock BIOS.

Your stock BIOS image is unique to your laptop. **Without a backup of your BIOS, you will be unable to restore it if something goes wrong**. You cannot use a BIOS image from another machine.

Enter the `flashrom/` directory in the Libreboot download:
```sh
cd flashrom
```

Your Lenovo BIOS may be one of two types: `sst` or `macronix`. Run **both** of these commands to ensure you have attempted to back up both kinds:
```sh
sudo ./flashrom_lenovobios_sst -p internal -r backup.bin
sudo ./flashrom_lenovobios_macronix -p internal -r backup.bin
```

Only one of the two commands should be successful. If a `backup.bin` file is now present in the `flashrom/` directory, your backup has been successful.

Copy the `backup.bin` file to a removable medium like a flash drive to ensure its safety.

#### Flashing Libreboot: Stage One
Return to the `libreboot_bin/` directory.

Run the script to complete the first flash. Replace the ROM name with the one you decided to use above:
```sh
sudo ./lenovobios_firstflash bin/x60/x60_ukqwerty_vesafb.rom
```

Wait for the process to finish. **You should expect to see various “Critical Error” messages during the prcedure.** This is expected behaviour.

Check that the line below was displayed. If this line was displayed, then this stage of the procedure has been successful:
```
Updated BUC.TS=1–64kb address ranges at 0xFFFE0000 and 0xFFFF0000 are swapped.
```

**WARNING! — If the above line was not displayed, do not continue to the next step and do not restart your machine. Run the flashing script again.**

If the flashing has been successful, the following errors (or at least very similar errors) will be displayed:
```
Reading old flash chip contents… done.
Erasing and writing flash chip… spi_block_erase_20 failed during command execution at address 0x0
Reading current flash chip contents… done. spi_block_erase_52 failed during command execution at address 0x0
Reading current flash chip contents… done. Transaction error!
spi_block_erase_d8 failed during command execution at address 0x1f0000
Reading current flash chip contents… done. spi_chip_erase_60 failed during command execution
Reading current flash chip contents… done. spi_chip_erase_c7 failed during command execution
FAILED!
Uh oh. Erase/write failed. Checking if anything changed.
Your flash chip is in an unknown state.
```

**WARNING! — If the errors displayed do not closely match this expected output, do not continue to the next step and do not restart your machine. Run the flashing script again.**

If the errors displayed match those seen above, shut down the machine (do not restart).

Wait, and Libreboot should start up automatically and boot into your GNU/Linux operating system.

After booting, proceed to the next stage.

#### Flashing Libreboot: Stage Two
Navigate back to the `libreboot_bin/` directory.

Run the script to complete the second flash. Replace the ROM name with the one you decided to use above:
```sh
sudo ./lenovobios_secondflash bin/x60/x60_ukqwerty_vesafb.rom
```

Check that the line below was displayed. If this line was displayed, then this stage of the procedure has been successful:
```
Updated BUC.TS=0–128kb address range 0xFFFE0000–0xFFFFFFFF is untranslated
```

**WARNING! — If the above line was not displayed, do not continue to the next step and do not restart your machine. Run the flashing script again.**

You should also see, without any errors:
```
Verifying flash… VERIFIED.
```

If this is displayed, then Libreboot flashing has been successful.

Shut down the machine, and boot it again. **If it boots without error, your Libreboot installation has been a success, and you can stop here.**

#### Updating Libreboot
To update Libreboot when future versions are released:

Download and extract the latest Libreboot binaries and navigate to the extracted directory using a terminal.

Run the following command to flash your chosen ROM:
```sh
sudo ./flash bin/x60/x60_ukqwerty_vesafb.rom
```

You should see the following message, without any errors:
```sh
Verifying flash… VERIFIED.
```

Shut down your system, and then boot.

Libreboot update is now complete.

#### Using Wi-Fi
The default wireless chip in ThinkPad models is manufactured by Intel, and requires nonfree drivers. These chips do not work with FOSS operating systems such as Trisquel.

To use Wi-Fi connectivity after flashing Libreboot, you will need to replace the Intel Wi-Fi card with one that has FOSS drivers available.

Atheros wireless chips are usually recommended, as they are usually natively supported by FOSS GNU/Linux distributions.

You may consult the X60's [Hardware Maintenance Manual](http://support.lenovo.com/us/en/docs/MIGR-62866) for information on how to replace the wireless chip.

Please note that ethernet connectivity will work under Libreboot with no issue. It is not necessary to upgrade the Wi-Fi chipset if you only intend to use your machine’s ethernet ports.

#### License
This guide and its text contents are licensed under a Creative Commons Attribution 3.0 License.

Please feel free to copy, redistribute, update, translate or build upon this guide for any purpose. Doing so provides a great benefit to the FOSS community.

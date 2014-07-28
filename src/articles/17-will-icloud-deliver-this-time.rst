---
title: Will iCloud deliver this time?
pubDate: 2014-07-29 01:19
modDate: 2014-07-29 01:19
tags: apple, user-experience
---

Will iCloud deliver this time?
==============================

Somewhere around September, or maybe October, Apple will release `iOS 8
<https://en.wikipedia.org/wiki/IOS_8>`_ and `OS X 10.10 Yosemite
<https://en.wikipedia.org/wiki/OS_X_Yosemite>`_. One of the highlights of this
release will be `CloudKit
<http://arstechnica.com/apple/2014/06/apple-announces-ios-8-at-wwdc/>`_, which
will be sort of like... Dropbox. Or maybe Google Drive/Google App Engine. In
fact, the newer OS versions will finally show *files* on your device. You know,
that ugly thing Apple has been trying to force you forget about and nobody
wants to touch.

The sad thing is that CloudKit seems like it will be their current iCloud with
a slightly more open and feature full API. Why sad? Well, `there has been
<http://blackpixel.com/blog/2013/03/the-return-of-netnewswire.html>`_ `plenty
said about <http://createlivelove.com/246>`_ `how much iCloud
<http://www.theverge.com/2013/3/26/4148628/why-doesnt-icloud-just-work>`_
`actually sucks
<http://inessential.com/2013/03/27/why_developers_shouldnt_use_icloud_sy>`_
`from the developer point of view
<http://informalprotocol.com/2012/11/your-app-needs-to-sync/>`_. In fact, I
have tried to use iCloud and I can tell you that yes, except for really really
tiny bits of data *you don't care about*, it sucks badly in terms of
performance. For anything that you *care about* you should avoid iCloud (at
least in its current version).

During the past days of beta and candidate release polishing, Apple `told
developers at the beginning of July
<http://www.macrumors.com/2014/07/04/apple-cloudkit-wipe-july-7/>`_ that they
would be wiping data for certain types of applications using CloudKit. Huh,
really? We aren't talking about a few noobs getting together and putting a
website for the first time. Presumably we are talking about Apple, who started
doing `web scale <http://www.youtube.com/watch?v=b2F-DItXtZs>`_ stuff in iOS 5
(more than two years ago now!). Oh well. Wouldn't be that scary unless… wait,
now I got another mail, they are wiping all CloudKit public databases on July
22 too. Which begs the question: are they actually building on their old shit
or are they inventing new shit which will have its own set of new bugs
(ahem, features)?

This sad history of previous facts doesn't reassure me things will be happy in
the future. In fact, that's all from the developer's point of view. But let me
tell you about the user point of view for what iCloud has been up till today.


Reminders
=========

The reminders app is like your Hello World for network programmers. Only
programmers typically call it **TODO**. You have a bunch of tasks, you set a
date (or not) and you go checking them when you finish. Pretty simple, how
could you not make this work? Bad news, reminders still works incorrectly
sometimes.  One of the typical problems I have with it are periodical
reminders. These are todo tasks which at a certain date they give you an alarm,
and badge the application icon to remind you you have *N* tasks pending to
check. So you check them, exit… and the badge doesn't change. So you go again
in, the task is deleted, go out, nope, the badge still has a number. Go in…
wait, the task reappeared again? You check it, go out, oh finally, now it's
checked and there is no badge.

Another problem happens when you have multiple devices. For instance, let's say
you have a task with a date, and you have a laptop and an iPhone. You add the
reminder and off you go. Then, at some point you get an alert both on the
iPhone and the computer, just slightly off because their clocks are not exactly
the same. Say, you open the iPhone app and check it. Also on the laptop you
click the notification away. Only problem is for some reason if you click off
the notification, the iPhone task appears as non checked the next time you open
the app. And with a badge too!

It's as if the iphone is sending the check, then the mac is sending the check,
something goes terribly wrong and one things it has not been done. Sometimes
this happens to me with dates. I change the date of a reminder and other
devices don't have it updated, but I check them anyway. Only later the
reminders reappear with the modified date. As if the *I-modified-the-date*
reaches after the *I-deleted-the-task* and this revives the deleted reminder.


iMessages
=========

It was really cool to be able to send SMS like messages for free and from the
laptop to other iPhone users. Only until you realise it sucks so much and stop
using this. The most annoying thing is that delivery is random. I've received
messages up to two days after they were sent. But that's when you get lucky.
The bad is when messages **never** reach. And this is actually fun to see when
you have multiple devices connected to the same iCloud account.

The other day I started a talk with my sister. Wrote a message from the laptop.
After some time the iPhone revives with an answer. I wait a few minutes… but
nothing, the laptop doesn't receive the answer. Anyway, I type the answer on
the laptop and again, after some minutes, I get a notification, this time on
the iPhone, and 30 seconds later on the iPad (which didn't get the first
answer), and… not on the laptop. Huh. Rinse and repeat. Now I get both device
notifications, and yes, finally! The laptop iMessages app shows the
*user-is-typing-a-reply* icon. I get the answer on the iPhone, then the iPad…
and after three minutes the *typing* icon disappears, and get a blank screen,
no reply.


Calendar
========

Up until Mavericks, my laptop would show *"syncing calendars"* or something
like that, only it would never stop. I would have to kill the calendar app and
open it again. For some reason then it would *usually* work. What was the
calendar syncing? Why did it use a blocking alert dialog anyway preventing me
from using the rest of the app locally? And is it actually gone in Mavericks?
Haven't seen that odd alert, but I've seen my calendar not having certain
events I added on my iPhone.


Mail
====

A hahahahaha. **Just no**. I'm not letting them mangle work email after seeing
what they do with trivial data. Plus I've found out that sometimes the
Mavericks mail app doesn't work very well with IMAP drafts. You delete the
draft and after some time it appears again (usually after quitting and opening
Mail again). The only way to get rid of such ghost drafts is to nuke them on
the server with whatever web mail interface you have, or a saner IMAP client.


iPhoto
======

Apple's picture managing software doesn't necessarily use iCloud, but you can
enable the **photo stream** or whatever is its official branding name, and
presumably devices will upload photos to the iCloud. Then in iPhoto you enable
the "download automatically from iCloud stuff" option. This is very nice, you
don't have to connect the devices to the computer and pictures start to appear. Only like previously said, sometimes pictures never appeared.

But more importantly, deleted pictures *can't be killed*! Let me explain. When
I take pictures with the iPhone, since it's a mobile and they usually suck to
take pictures, and the LCD doesn't show really anything, I always take several
pictures of the same scene, then on the computer I look at them carefully and
pick the best. The rest get deleted.

Well, the photo stream stores up to 1000 pictures. What I noticed is that after
several days passed since I deleted the imported photos in iPhoto… they would
come back! I noticed this by chance, I started looking at previous picture
rolls and I would have duplicated pictures. This is because I would have the
original picture version from iCloud, and the one which I would edit, modify,
then save and re compress outside of iPhoto to reimport again and save precious
disk space (usually iDevices use lousy JPG compression to preserve shitty
background noise from mobile pictures you don't want to keep anyway, so re
compressing the pictures saves a lot of space without noticeable quality loss).

So I disabled the iPhoto importation. Then I disabled iPhoto stream, because I
realized I don't want it for anything else and could live better with Apple not
sneakily looking at my personal pictures.

Oh, and not related to iCloud, I had about 10,000 images tagged with faces but
one day I went to the faces option in iPhoto and all had vanished. Well, let's
look in Time Machine… nope, the oldest backup didn't have them. Way to go
Apple, you lose user data and don't even bother to tell us.

iTunes
======

Not totally related to iCloud, this shows how bad their network implementation
tends to be. Previous to iCloud (I believe) iTunes started to have wifi sync.
Wohoo! Never connect your iPhone again and be able to transfer data to it any
time! Sounds really nice. Started to use it and… nope, from random syncs which
would not finish but not give errors (which means stuff would not be copied and
you are not notified) to the most dreaded iPhone is 5cm away from laptop but
they don't see each other until you reboot both devices!

Now I don't use wifi iTunes sync on any device, and to avoid *support calls*
nobody in my family does either.


Podcasts
========

The podcasts app has really troubles to keep in sync. So much that from time to
time I open it and all my *feeds* are duplicated. Cool, now which one is the
good one? They are identical. But I delete one and keep using whatever podcast
I was listening too. Only later that deletion seems to make no more podcast
update. So you have to go on the device and computer, purge all, then refresh
and create new subscriptions. Amazing quality, have had it happened twice
already, and now I *see* dupe feeds again, but I've learned to just look in
another direction and not try to delete them.

Two is better than one anyway.


Contacts
========

I don't have anything bad to say about Contacts. Except that one time where I
noticed nothing would sync. At some point, contacts would simply not *cross
over* from the laptop to the iPhone or vice versa, neither changes to previous
contacts neither new entries. What was wrong? I even made some tests, creating
new items, forcing refresh however I could, but nothing.

After travelling the deep Apple support forums I found that the laptop was at
least logging some errors during sync. Then with some arcane command line
commands I was able to convert strange looking universal identifier codes into
address book contacts, purge them, and reimport them again. Then it started to
work again.

Oh, maybe not. It actually started to work again when I stopped syncing
contacts through iTunes. You see, you can sync both through iCloud and through
the physical connection. Not a good idea. Use one, but not both, otherwise you
have weird problems too.


Conclusion
==========

I would love if this stuff worked. But right now as you can see I've disabled
pretty much everything related to network sync because Apple can't make it
work. And third party developers can't make it work either, I wonder why would
that be… or why most solutions involve turning off Apple features/software.
Whatever I choose in the future for web sync/development I will make sure it
has no relationship to Apple.

Still, good luck Apple! I hope you make the best software! No hard feelings on
the years of pain you have provided me and my loved ones!

::
    $ wget http://apple.com/icloud-just-works
    ...
    2014-07-29 01:19:38 ERROR 404: Not Found.

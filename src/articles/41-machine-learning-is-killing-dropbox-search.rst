---
title: Machine learning is killing Dropbox search
pubdate: 2019-05-04 20:50
moddate: 2019-05-04 20:50
tags: programming, dropbox, kotlin, design, politics, tools, user experience
---

Machine learning is killing Dropbox search
==========================================

.. raw:: html

    <a href="https://toodur2.tistory.com/1938"
        ><img src="../../../i/dropbox_searching.jpg"
        alt="A webapp in Nim? What is he smoking? Is that possible at all?"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>


Waking up with your left foot
-----------------------------

Recently the `Dropbox Tech Blog <https://blogs.dropbox.com/tech/>`_ published
one article titled `Using machine learning to predict what file you need next
<https://blogs.dropbox.com/tech/2019/05/content-suggestions-machine-learning/>`_
which ended ticking me off. The reason is simple, Dropbox search feature
stopped working for me about two years ago. Unfortunately I'm used to dozens of
products having bugs that make them inconvenient, and you simply learn to live
with crap because fixing it is more expensive than ignoring it. As a programmer
you learn that software is far from being the product of a single person, and
groups of different people have different views on what quality is, means, or
how it is achieved. We are all slaves to the financial aspect of business
anyway, and we know the business side doesn't really care about bugs unless
they torpedo their income, so priorities tend to be somewhere else (shiny new
features! Shinyyyyyyy!). So seeing the Dropbox blog gloat about how awesome
machine learning is finally prompted me to make public how crap their search
actually is, and has been for years.

Sometime in 2017 (or even earlier) the search feature stopped working for me. I
use Dropbox not as storage but as an easy to use asynchronous file transfer
system, where other Dropbox users share folders with me. I put files in them,
and they retrieve them. Most of these actions are automated, so I can copy/move
a file from the command line and know it will magically materialize somewhere
else and free itself from Dropbox, so the free space of the account is
eventually regained and I don't trip over their storage limit. Sometimes I want
to know if I've already sent a file to somebody, so I would log in to the
website and search the filename.  This **used to work** perfectly fine, showing
matches in deleted files, but at some point results would stop coming.

After waiting for some time and seeing it not being fixed (I also noticed the
"Events" page disappeared, which showed you the full history of file movement
on the account), I decided to patch the search feature myself (sometime around
Christmas 2017). I started looking at their `developer documentation
<https://www.dropbox.com/developers/documentation>`_ and realised they had a
Java SDK. At the time the `Kotlin language <https://kotlinlang.org/>`_ was new
to me, so I decided to use it in order to get familiar with it. And hence, the
`Dropbox file racoon <https://gitlab.com/gradha/dropbox-file-racoon>`_ project
was born (the `first commit points to my Christmas holidays
<https://gitlab.com/gradha/dropbox-file-racoon/commit/afb228cdc16ff1587f79a801ccf47e48e3e87f69>`_,
which is the only reason I know the approximate timeline of events).

At this very moment, if I use Dropbox web search feature to look up for the
``rm_4`` filename part, I get 5 lousy results, as shown by the following
screenshot you can click to enlarge:

.. raw:: html

    <br clear="right">
    <center><a href="../../../i/dropbox_search_rm_4.jpg"
        ><img src="../../../i/dropbox_search_rm_4.jpg"
        alt="Dropbox search results for the rm_4 string"
        style="width:100%;max-width:753px"
        hspace="8pt" vspace="8pt"></a></center>

On the other hand, using the search program I wrote I get 50 matches. Here's an
excerpt::

   $ dropbox-file-racoon.jexe -s rm_4
   Searching for SQLite term rm\_4
   Got 50 matches for 'rm_4'.
   x /gon/rm_400-Yut_championships-180513.mp4
   x /gon/rm_401-TvNotice2-180520.mp4
   x /gon/rm_402-Aoa txombi reis 180527.mp4
   …
   x /gon/rm_447-somin_in_love_end-190414.mp4
   x /gon/rm_448-online_search_race.mkv
   v /gon/rm_449-secret_host_s-190428.mp4
   Got 50 matches.


Cool dezignerz
--------------

Shit posting about engineers behind machine learning wouldn't be fun if I
didn't also include designers. Some time before Dropbox search stopped working
completely in 2017, results would be displayed with their filenames truncated
due to an idiotic web redesign which wasted screen space.  Which is totally
useful if you don't care about filenames. Looking at their website now it seems
that the same idiots are still in charge. Here is a screenshot of the results
page on my browser window, maximized to the full extent my laptop screen allows
(you might need to click the image to appreciate the details):

.. raw:: html

    <center><a href="../../../i/dropbox_search_rm_4_wide.jpg"
        ><img src="../../../i/dropbox_search_rm_4_wide.jpg"
        alt="Dropbox search results for the rm_4 string wide"
        style="width:100%;max-width:1440px"
        hspace="8pt" vspace="8pt"></a></center>

What you can see in that screenshot is that it shows the results of the
``rm_4`` search and truncates the file names. The total screen size width is
2880 pixels, but the width allowed for filenames seems to be just 600 pixels,
or about 20% of the total screen width. The whole *usable area* of results in
the middle is about 1600 pixels, so about 45% of screen width is dedicated to
**responsive** sidebars. Thanks, designers, what would we do in a world without
you! In fact, you can see that designers did **already receive complaints**,
because *they fucking added a fucking tooltip*. Nicely done, who said they
don't care about users?

It comforts me to verify that high profile firms like Dropbox, Apple, Google
and others are filled with the same idiots I've had the pleasure to work with
in the past:

* What to you mean accessibility? What is that?
* No, we can't change the font size because it breaks alignment for this very
  specific screen on my phone. I don't care about the 95% of other phones.
* Let the OS align sentences? Heresy!
* The translation of this sentence doesn't fit in the space? Let's use
  acronyms and/or slang!

In fact, my last *encounter* with a designer to whom I raised accessibility
issues was met with a polite shut the fuck up and presume this feature, or
users who use it, doesn't exist. I can also count the times I've had to
implement accessibility on mobile apps with a single finger from my… a single
finger (guess which one, ha!). And this happened only after those inexistent
users complained.

Also, in case you were not paying attention, the first screenshot shows the
results of the ``rm_4`` search sorted by **Relevance**. Because you know,
sorting by **fricking name** would be too much to ask, and relevance decides to
put rm_445 in front of rm_449, with the files in between showing up later. Who
in the world sorts file names by file name anyway!


Making your own search
----------------------

OK, OK, I'm a picky user. I *should not complain* about results being
illegible, or getting 5 entries where 50 should be returned. A special place in
hell is reserved for people like me, who believe software should be useful
first, and bells and whistles can come later. Unfortunately I don't plan on
dying tomorrow, so in the meantime I decided to look up the Dropbox API and
make my own search.

What I ended up doing was using the `API which exposes the whole Dropbox
history
<https://gitlab.com/gradha/dropbox-file-racoon/blob/master/src/main/kotlin/fileracoon/main.kt#L30>`_
and looping over the paged results, storing them in a local SQLite database.
The database `is very simple and is made of two simple tables
<https://gitlab.com/gradha/dropbox-file-racoon/blob/master/src/main/kotlin/fileracoon/database.kt#L240>`_:
the ``paths`` table stores all the filename paths, the ``global_state`` table
is a convenience and stores the token passed by the user the first time to
reuse in future queries. Once the tables are retrieved, simple `SQL LIKE
queries can be run
<https://gitlab.com/gradha/dropbox-file-racoon/blob/master/src/main/kotlin/fileracoon/database.kt#L106>`_,
which have the convenience of actually working and returning useful results.

Unfortunately this program was never meant to be public, so it is not prepared
to work easily, and you have to do your own Dropbox developer token
provisioning. If you are interested, I described this in the `requirements
section of the project README
<https://gitlab.com/gradha/dropbox-file-racoon#requirements>`_, so you can set
the project right and actually use it. In fact, that README commit is the only
change I did recently, because it has been working forever since, and will keep
working until Dropbox decides to close their API. Non machine learning software
has the advantage that it works the same all the time.

In my case, the ``.config/dropbox-file-racoon.sqlite3`` database weights at the
moment 224MB, and contains 872195 entries. Usually the first time I perform a
search it takes about 5 to 10 seconds on my machine to show results. If I
repeat the query the results come then in less than one second. There is no
database server here, so the *warming up* of the queries is probably done by
the OS, caching the whole 224MB file in RAM and speeding up later queries. Just
for laughs, here are some more search comparison results between the website
and my local search:

* ``wi_3``: Dropbox returns 1 result, racoon returns 106.
* ``fancam``: Dropbox returns 63 results, racoon returns 54148.
* ``tumblr_``: Dropbox returns 106 results, racoon returns 21292.
* ``150304``: Dropbox returns 0 results and shows a dog digging the ground,
  racoon returns 20.

.. raw:: html

    <center><a href="http://www.idol-grapher.com/1989"
        ><img src="../../../i/dropbox_go_away.jpg"
        alt="Go away! Your Dropbox search results are not here and never will!"
        style="width:100%;max-width:750px"
        hspace="8pt" vspace="8pt"></a></center>


Final words
-----------

I'm pretty sure the guys at Dropbox, *a highly collaborative cross-team effort
between the product, infrastructure, and machine learning teams* can figure
out, sometime in the future, that their search sucks. They only need to use
it. I mean, they have time to blog post how awesome they are, but they can't
spare a few minutes to set up a test case where a few search texts are tried
against a static corpus and the number of results should be the same on every
iteration of their product?

To be fair, the problem seems to be that their whole machine learning sentient
thingy `has Alzheimer's disease
<https://en.wikipedia.org/wiki/Alzheimer%27s_disease>`_, because it seems to
limit all results to about one or two months worth of results. Maybe all this
machine learning, which could be replaced by `SQLite <https://sqlite.org>`_, is
just too power hungry for text sizes longer than this blog post. Knowing the
Dropbox guys favor Python, hopefully they didn't `ditch their Pyston attempt
<../../2014/04/could-dropbox-switch-to-nimrod.html>`_ and rewrote everything in
JavaScript. Ugh, or maybe they did, seeing their `Pyston implementation
languishes since 2017 <https://github.com/dropbox/pyston/commits/py3>`_, which
is dangerously close in time to when search stopped working for me…
coincidence?

There is always something good in `all of this despair
<https://www.youtube.com/watch?v=yoU2sf0bHI8>`_: Skynet won't find John Connor.
It will try to use machine learning to search for the guy and instead `the Jar
Jar Binks actor <https://www.imdb.com/name/nm0078886/>`_ will be terminated to
`avoid the suffering <https://www.youtube.com/watch?v=qfNiSkd3HfI>`_.

::
    $ nim c -r brain.nim
    Error, file not found.

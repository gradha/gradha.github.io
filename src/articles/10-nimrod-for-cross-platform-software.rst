---
title: Nimrod for cross platform software
date: 2014-03-06 17:21
tags: programming,nimrod,seohtracker,elhaso
---

Nimrod for cross platform software
==================================

On the 21st of February of 2014, Sarah Con… er… `Seohtracker v4 was released
for iOS <http://www.elhaso.es/seohtracker/ios.en.html>`_. A puny little iOS
app. And now the app has crossed the bridge and made it to the Mac App Store as
`Seohtracker for OSX <http://www.elhaso.es/seohtracker/osx.en.html>`_. Why
would this be of any relevance? Because both programs are partially implemented
in the `Nimrod programming language <http://nimrod-lang.org>`_.

The `Nimrod programming language <http://nimrod-lang.org>`_ compiles
pythonesque style code into portable C. Might be more portable than Java. And
more machine performant at the low level. And more developer performant at the
high level!  And more lisp macros. And… whatever man.  It's just cool, and I
believe it is going to allow me to produce real life programs for more
platforms with less effort (still working on the *less effort* part, though).

But Nimrod is relatively new and unpopular. Despite the website stating "*The
Nimrod Compiler can also generate C++ or Objective C for easier interfacing.*",
there's not much *proof* out there you can take as reference. So I decided to
start my own, and that's what Seohtracker is. The internal architecture of
Seohtracker splits the interface from the logic. Hence, you have a `cross
platform logic code <https://github.com/gradha/seohtracker-logic>`_ which is
implemented in just Nimrod. Then, somewhere in the middle is floating a `thin
Nimrod to Obj-C convenience layer
<https://github.com/gradha/seohtracker-ios/blob/c512307ea505dc7c2262b88ddc8599e94f5f4a74/src/nim/n_global.nim>`_
which exposes the Nimrod logic, and finally you have the `iOS
<https://github.com/gradha/seohtracker-ios>`_ and `OS X
<https://github.com/gradha/seohtracker-mac>`_ clients which are consumers of
this API.

Why not write **everything** in Nimrod? That's something I've heard a lot. The
most important practical reason is I'm a simple guy doing this on his own, and
I can't compare to `well paid and full of people firms <http://xamarin.com>`_
doing the wrapping of all the little details. But also because each platform
has a different UI which requires separate design. For instance, the iOS
version of Seohtracker is split in multiple view controllers, each reigning its
own screen, while the mac version is pretty much contained in a single root
view controller for the main window. Or how about help? The mobile version
includes little breadcrumbs of information in certain screens, while the mac
version simply lets you go to the index and browse whatever your heart desires.

And this is just the beginning! A planned iPad specific UI already requires a
different approach from the iPhone version. But what about Android? And what
about Linux? Yes, you can implement a GTK2 version for Linux/Windows too (plus
there already are bindings for this toolkit). If you **try** to cram every
platform under the same language and graphical toolkit, you are likely to piss
off people on each platform, as the result won't be a 100% full citizen
compared to the rest of the operating system, just that strange bloke with the
weird hair, who hopefully gets the job done, or else…


Show me the money!
------------------

In the spirit of releasing `some statistics like other projects do
<http://praeclarum.org/post/42378027611/icircuit-code-reuse-part-cinq>`_, here
are some results of running `SLOCCount <http://www.dwheeler.com/sloccount/>`_
on the iOS, OSX and logic modules as tagged for the v4 release:

.. raw:: html

    <table border="1pt">
    <tr><th>Category</th><th>iOS</th><th>OSX</th><th>Logic</th></tr>
    <tr>
        <td>Lines of code in objc</td>
        <td align="right">1886 (68.71%)</td>
        <td align="right">1107 (73.85%)</td>
        <td align="right"></td>
    </tr><tr>
        <td>Lines of code in python</td>
        <td align="right">792 (29.85%)</td>
        <td align="right">324 (21.61%)</td>
        <td align="right">832 (100%)</td>
    </tr><tr>
        <td>Lines of code in sh</td>
        <td align="right">67 (2.44%)</td>
        <td align="right">68 (4.54%</td>
        <td align="right"></td>
    </tr><tr>
        <td>Total physical source lines of code (sloc)</td>
        <td align="right">2,745</td>
        <td align="right">1,499</td>
        <td align="right">832</td>
    </tr><tr>
        <td>Development Effort Estimate, Person-Years (Person-Months)<br>
            (Basic COCOMO model, Person-Months = 2.4 * (KSLOC**1.05))</td>
        <td align="right">0.58 (6.93)</td>
        <td align="right">0.31 (3.67)</td>
        <td align="right">0.16 (1.28)</td>
    </tr><tr>
        <td>Schedule Estimate, Years (Months)<br>
            (Basic COCOMO model, Months = 2.5 * (person-months**0.38))</td>
        <td align="right">0.43 (5.22)</td>
        <td align="right">0.34 (4.10)</td>
        <td align="right">0.27 (3.24)</td>
    </tr><tr>
        <td>Estimated Average Number of Developers (Effort/Schedule)</td>
        <td align="right">1.33</td>
        <td align="right">0.90</td>
        <td align="right">0.61</td>
    </tr><tr>
        <td>Total Estimated Cost to Develop
            (average salary = $56,286/year, overhead = 2.40).</td>
        <td align="right">$ 78,003</td>
        <td align="right">$ 41,327</td>
        <td align="right">$ 22,273</td>
    </tr><tr>
        <td>Grand total</td>
        <td align="center" colspan="3">$ 141,603</td>
    </tr><tr>
        <td colspan="4">
    SLOCCount, Copyright (C) 2001-2004 David A. Wheeler<br>
    SLOCCount is Open Source Software/Free Software, licensed under the GNU
    GPL.<br>
    SLOCCount comes with ABSOLUTELY NO WARRANTY, and you are welcome to
    redistribute it under certain conditions as specified by the GNU GPL
    license; see the documentation for details.<br>
    Please credit this data as "generated using David A. Wheeler's
    'SLOCCount'."
    </td></tr></table>

* Yuck! `Python <http://python.org>`_? Yeah, sorry about that shock.  SLOCCount
  doesn't support Nimrod, but since the source code and syntax is very similar
  with regards to line counting, I modified my copy of SLOCCount to treat
  ``.nim`` files as python to get immediate results.
* The number of lines for Nimrod is really small compared to Objective-C
  because the logic is small as well, this kind of app is mostly user
  interface, plus Nimrod is a higher level language than Objective-C. Just
  starting an Objective-C file from the Xcode template tends to give you a full
  page chunk of code doing nothing at all. It's not as bad as Java, but still
  very verbose.
* Even though both the iOS and OSX clients are just interface, instead of shell
  scripts I used Nimrod through `nakefiles
  <https://github.com/fowlmouth/nake>`_ to drive compilation, generate and
  package the different resources. Think of nakefiles as `GNU makefiles on
  steroids
  <https://github.com/gradha/seohtracker-mac/blob/0163927a5e8294c0dc2923f3f3612e36a9b6e389/nakefile.nim>`_.
  That's the reason you see Nimrod lines of code dedicated to them. Nearly none
  of them do any *logic* code in the app the user sees, they are for support.
  Also, both iOS and OSX nakefiles share some code I haven't yet come to
  factor, since I was more interested in releasing the OSX version first.
* Unfortunately for this comparison I took the repositories as they were tagged
  for the v4 release. The splitting of Nimrod code from the iOS repository into
  a separate module **happened later**. Which means that the iOS lines of codes
  for Nimrod are bogus, the current development branch shows just 204 lines of
  Nimrod code, which goes more in line with the 324 lines of Nimrod code for OS
  X (the OS X nakefile does more to transform and generate native OS X help
  files). Anyway, the point here is that reducing the Nimrod lines of code
  attributed to the iOS client would increase the percentage of native
  Objective-C code and put it more in line with the OS X version.
* Thanks to the separation of logic vs interface, the `test suite of the logic
  module
  <https://github.com/gradha/seohtracker-logic/tree/bcb1fb7fec655a0b5714d1e9efd349abb257a6e4/tests>`_
  needs to exist only once. Compare this to current independent mobile
  developments where different teams develop iOS and Android (sometimes even
  different code bases for iPhone vs iPad!), each incurring its own share of
  bugs and odd behaviours. Have you seen people update iOS/Android to leave
  *the other* platform (whatever it might be) picking dust? In my case, the
  testing can be done once, and from here on for each additional platform I add
  to the suite I get *free time* to spend `browsing kpop videos on youtube
  <https://www.youtube.com/watch?v=bZC7yA1Cymc>`_.
* $56,286/year? Seriously? What parallel universe does that come from?
  According to `more recent articles
  <http://pinoria.com/better-software-programmer-doctor/>`_, a software
  developer gets on average $90,060/year. And if you go asking around, it seems
  like this *mobile thing* is not a fad, and mobile developers tend to be paid
  more because there is less of them (and arguably they are worse, because they
  haven't had the chance to get enough experience in such a short lived field
  yet). But anyway, how would the cost look like with that higher more recent
  average? Just multiply by a factor of ``90,060/56,286 = 1.6``.

.. raw:: html

    <table border="1pt">
    <tr><th>Category</th><th>iOS</th><th>OSX</th><th>Logic</th></tr>
    <tr>
        <td>Total Estimated Cost to Develop
            (average salary = $90,060/year, overhead = 2.40).</td>
        <td align="right">$ 124,808</td>
        <td align="right">$ 66,125</td>
        <td align="right">$ 35,637</td>
    </tr><tr>
        <td>Grand total</td>
        <td align="center" colspan="3">$ 226,570</td>
    </tr><tr>
        <td colspan="4">
    Updated salary wages by <a
    href="http://pinoria.com/better-software-programmer-doctor/">random
    internet US centric post</a>.
    </td></tr></table>

In any case, you should ignore the statistics for lines of code, they are
pretty much useless in the real world, especially for experiments like this
which don't fall into the *normal development* category.


It's 16:27 past deadline
-------------------------

How about if we measure time? Fortunately I did track all the hours I put into
this project so far. Unfortunately, until v4 all the previous iPhone releases
had both Objective-C and Nimrod hours lumped, while after v4 most Nimrod hours
will go to the logic module. At least we can get more realistic cost estimates.
Let's consider a full US work year in neoliberal hours, which clocks at 2088
hours per year.  Using this metric we get that the default average software
developer earns 26.96 $/h, while the *corrected* averaged programmer earns
43.13 $/h (still lower than what I've seen reported on various iOS forums, but
let it be).

--------------- ------------  --------------  ----------
State           iOS           OS X            Logic
--------------- ------------  --------------  ----------
v1              44.33
v2              22.08
**v1+v2**       **66.41**
v3              9.17
**v1+v2+v3**    **75.58**
v4              26.08         56.42           3.75
**v1+v2+v3+v4** **101.66**
--------------- ------------  --------------  ----------

Total hours for the combined project: 161.83.

Estimated costs: ``161.83 * 26.96 = 4362.94$``

Or the more realistic average: ``161.83 * 41.13 = 6979.73$``

Thoughts:

* No kidding, under 4 hours to implement the full logic of the code, split in a
  nice documented module, all with unit tests? Nah, that was essentially the
  time it took me to *extirpate* the code from the iOS repo into the logic
  repo.
* The actual time I have probably spent on the Nimrod code is more in line with
  40 hours, which is roughly the total iOS minus the OS X time. This would mean
  that nearly half of development time was shaved off thanks to Nimrod. Even
  though `you don't care <http://www.youtube.com/watch?v=4r7wHMg5Yjg>`_, thank
  you, Nimrod!
* Seriously, 226,570$ vs 6,979.73$? I know that SLOCCount has `a whole lot of
  documentation which I haven't even tried to read
  <http://www.dwheeler.com/sloccount/sloccount.html#cocomo>`_ explaining how to
  fine tune the estimated cost of the lines of code, but the difference is
  ridiculous.  People using lines of code to measure anything should be hanged
  from trees (regardless of proper SLOCCount parameters). The true real cost of
  this software so far has been approximately one month of an iOS developer.
* An experienced OS X
  developer would have reduced the hour count of 56.42 hours even more. Despite
  being similar to iOS, OS X has its own share of weird oddities accrued
  through years of bugs and incorrect API designs. Really, it took me 8h to
  figure out how to correctly generate the OS X help from HTML files. Or 3h to
  find out how to `keep widgets on top of a scrolling window from leaving
  artifacts <http://stackoverflow.com/a/22183622/172690>`_. Which begs the
  question: why are your defaults so sucky OSX? **WHY?!** Experience on a
  platform goes a long way towards being productive.
* Looks like there are no good choices for OS X regarding in-app advertisements
  like on the mobile platforms. I did take a look at `BuySellAds
  <http://buysellads.com>`_ and `The DECK <http://decknetwork.net>`_, but they
  are so exclusive they don't answer email or they reject you. So I rolled my
  own. `Behold the power of marketing!
  <https://raw.github.com/gradha/seohtracker-mac/0163927a5e8294c0dc2923f3f3612e36a9b6e389/resources/screenshots/2.png>`_
  (right there, in the lower right corner of the left window). Any opportunity
  is good to make fun of the world for being such a shitty place.

The good about using Nimrod
---------------------------

The bad about using Nimrod
--------------------------

You don't need Nimrod to write software for iOS and OSX
-------------------------------------------------------

True. The astute reader will realize that both platforms use `Objective-C
<https://en.wikipedia.org/wiki/Objective-C>`_, a quite ancient crap language
(what else can you expect from C?) which only recently (thanks to the iPhone)
has been cardiopulmonarily resuscitated with `GCD
<https://en.wikipedia.org/wiki/Grand_central_dispatch>`_ and `ARC
<https://en.wikipedia.org/wiki/Automatic_Reference_Counting>`_ (don't you love
to throw acronyms around to look like you know *stuff*?) so that programmers
from other platforms willing to start writing software for Apple devices manage
to get past the `yuck factor <https://en.wikipedia.org/wiki/Yuck_factor>`_.

But in the previous paragraphs I've already outlined the possibilities: the
Nimrod logic code is already cross platform, you can grab the compiler and run
the test suite on Windows, Mac, Linux and whatever else you are able to run
Nimrod. Also, I'm just a single guy with limited time. Don't worry, the
interface for the other future platforms will come. Just no guarantees on a
delivery date, being a programmer means you have to master weaseling out of
committing to a deadline, so whenever it's done.

There you have it. My first little step. Hopefully it will turn into a long
walk. Who knows, maybe Nimrod will even start to be relevant to Wikipedia? In
your dreams…

.. raw:: html
    <small><table border="1" bgcolor="ffdbdb" cellpadding="8pt"><tr><td>

`Nimrod (programming language). From Wikipedia, the free encyclopedia
<https://en.wikipedia.org/wiki/Nimrod_(programming_language)>`_.

This page has been deleted. The deletion and move log for the page are provided
below for reference.

* 23:57, 28 October 2013 ErrantX (talk | contribs) deleted page Nimrod
  (programming language) (G4: Recreation of a page that was deleted per a
  deletion discussion: See for context:
  https://news.ycombinator.com/item?id=6627318)
* 16:55, 28 August 2013 Postdlf (talk | contribs) deleted page Nimrod
  (programming language) (Wikipedia:Articles for deletion/Nimrod (programming
  language) (2nd nomination))
* 00:02, 18 May 2010 Cirt (talk | contribs) deleted page Nimrod (programming
  language) (Wikipedia:Articles for deletion/Nimrod (programming language))

.. raw:: html
    </td></tr></table></small>

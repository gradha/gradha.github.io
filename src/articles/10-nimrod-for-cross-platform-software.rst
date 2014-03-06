---
title: Nimrod for cross platform software
date: 2014-03-06 17:21
tags: programming,nimrod,seohtracker
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
on the iOS, OSX and logic modules:

Blah

It's 16:27 past deadline
-------------------------

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
Nimrod. Also, I'm just a single guy with limited time. Don't worry, the other
platforms will come. But no guarantees on a delivery date, being a programmer
means you have to master weaseling out of committing to a deadline. So whenever
it's done.

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

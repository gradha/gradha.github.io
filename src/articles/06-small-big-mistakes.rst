---
title: Small big mistakes
date: 2014-01-14 09:02
tags: programming,nimrod,bureaucracy
---

Small big mistakes
==================

Open software is cool. Everybody can join in and tinker with the code. But
sometimes the entrance threshold is too high and projects are kept *under the
radar* for most people. I believe the `Nimrod programming language
<http://nimrod-lang.org>`_ by Andreas Rumpf & Contributors slightly tiptoes
into the *could-be-much-better-with-a-little-more-care*. The disadvantage of
Nimrod is that it is a programming language, and a really full fledged one
which beats most commonly used ones in terms of flexibility and amazing
features. Most potential contributors are intimidated by the initial complexity
of such software (not everybody writes compilers for breakfast).

But even more pitiful is what I consider basic administration mistakes which
discourage potential users. It is not fun when `users have to report that the
build instructions fail <https://github.com/Araq/Nimrod/issues/750>`_ (wait a
second, why are build instructions not part of the `continuous integration farm
<http://build.nimrod-lang.org/>`_?) and the issue is neglected for weeks or
months. It is even less funny that this is neglected because somebody has to
manually upload files to the website, and starts to look like a bad joke when
*after* updating the website, some pages are still missing due to human error,
so another manual interaction is needed.

For a group of people capable of creating a programming language the only
possible answer is lack of attention to releases. When `programmers who don't
like repeating themselves
<https://en.wikipedia.org/wiki/Don%27t_Repeat_Yourself>`_ (sometimes called
`lazy <http://weblogs.asp.net/erobillard/pages/3801.aspx>`_ but `in a positive
way <http://blogoscoped.com/archive/2005-08-24-n14.html>`_) are confronted with
a manual task, there are two possible paths: avoid the task or automate the
hell out of it. In this case, Nimrod's visibility is hurt, as new users come
and find something which doesn't work at first glance. Why should they keep
bothering when there's a constant torrent of new shiny programming languages
out there competing for everybody's attention? In more technical terms, it
doesn't matter how many users have write access to the repository if updating
the website still has a `bus factor
<http://www.crummy.com/writing/segfault.org/Bus.html>`_ bottleneck.

Some time ago `Babel, the official package manager for Nimrod
<https://github.com/nimrod-code/babel>`_ was in a state of flux where some
stuff did not work correctly, or required some prodding. I don't understand
what is so hard about keeping the repository *master* branch compilable. Maybe
I'm weird. But it get's better!  Here's something to `facepalm
<http://knowyourmeme.com/memes/facepalm>`_ if you want to use Babel to install
`Aporia <https://github.com/nimrod-code/Aporia>`_, the *official* Nimrod
editor, linked from the `Nimrod webpage <http://nimrod-lang.org>`_::

    $ babel install aporia
    Downloading aporia into /tmp/babel/aporia using git...
    Found tags...
    blah
    blah
    more blah
    and then…
    FAILURE: Specified directory does not contain a .babel file.
    $

So the *secret handshake* this time is to run ``babel install aporia#head``.
Totally obvious. The Aporia repository uses tags, but unfortunately the last
one didn't have a ``.babel`` file with the package info, so the ``#head``
suffix fixes that. As if version numbers were *expensive* and you could not
simply bump the version number and re tag the repository with the added file.
On the bright side Aporia specifies this in the `compiling section of the
README <https://github.com/nimrod-code/Aporia#compiling>`_, but it is a weird
bright side to be, demanding all your potential users to jump through hoops
when you can easily avoid that collective pain.

But it all makes you wonder: how many people did find Aporia listed in Babel's
``list`` command output and tried to install it? Hint: IRC logs show a few. How
many didn't bother asking on IRC? We will never know… How many users did tried
to compile Babel during the time it was *unstable*? Hopefully few. How many
users did Nimrod lose to outdated github build instructions, since pretty much
every other Nimrod software in active development requires the git version?
These are all trivial things to solve really.

Oh, and how much do I hate `people graciously giving commit access to github
repositories <http://felixge.de/2013/03/11/the-pull-request-hack.html>`_. Let
me explain: if this works for you it is only because you are a one man shop or
don't really care about the project and are looking for somebody to replace
you. Can you imagine a project like `Webkit <http://www.webkit.org>`_ or `the
Linux kernel <https://www.kernel.org>`_ giving out write access to just about
everybody? Not going to happen, that software has value, and random changes by
random people are unlikely to increase value. Sorry, the *pull request hack*
only works if your project has essentially no value to you, or if you think
100% of humans are good, something which is `easily disputed
<http://www.penny-arcade.com/comic/2004/03/19/>`_. It's the reason we have
`captchas <https://en.wikipedia.org/wiki/Captcha>`_ to give our opinion on many
websites.

Unfortunately I'm preaching to the walls: in my *professional* life as a
software developer I've seen even worse blunders in commercial software. You
know, the one where people's heads roll when something goes wrong. So my theory
is that most people doing open source software simply replicate what they have
learned at work. Or worse, are too lazy to even do that minimum effort!

That's when I ``<inception_bwaaaa>`` *step in to save the world of software*
``</inception_bwaaaa>``. Actually, I did read recently some hilarious articles
by `James Mickens <https://research.microsoft.com/en-us/people/mickens/>`_
(scroll to the bottom of that page, or find the extracts and direct links at
the `Programming is terrible blog
<http://programmingisterrible.com/post/72437339273/james-mickens-the-funniest-person-in-microsoft>`_
which is also a nice read), so I thought to myself, hey, why not try and write
something absurd while being semi serious about the issue? So here goes my
paper in pedantic PDF form:

 * `How to release software periodically
   <how_to_release_software_periodically.pdf>`_.

Hmm… maybe that wasn't such a good idea after all.

```nimrod
$ nimrod rst2html paper.rst
paper.rst(5, 1) Error: invalid directive: 'humour'
```

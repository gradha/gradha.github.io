====================================
How to release software periodically
====================================

:author: Grzegorz Adam Hankiewicz
:department: Software releases
:location: Spain, Colmenar Viejo 28770
:contact: melissavirusiloveyou@gradha.imap.cc

ABSTRACT
========

We explain the perils and hiccups of existing software development both
professionally and in amateur circles with regards to software releases.
Software releases can be tamed and we propose a method which can be applied to
any software. We demonstrate how different projects stored in Github compare
and how they can improve. We dislike BitBucket and therefore don't say much
about them. We also talk in plural form despite us being a single being,
hopefully not because we suffer from schizophrenia or delusions of grandeur;
also we use semicolons whenever we feel like it and try to concatenate word
after word to create long enough sentences that not even a professional Opera
Singer could say out loud in a single breath despite not saying much at all.

Keywords
--------

Nimrod, babel, nake, nakefiles, kpop, metal, politics, bike shedding, rst, pdf,
github, 9muses, snsd.

INTRODUCTION
============

Releasing software is boring; even an underage monkey trained in Ruby or Python
can access Github and upload anything, therefore giving the impression of being
hipster. In particular, there are many trained monkeys uploading software to
repositories seemingly at random and then leaving them to wither without
subsequent changes. Individual talks (please see NSA archives for the recorded
conversations) suggested the main reason for the halting of the development was
a lack of defined guidelines for software releases, troubles handling
distributed version control systems, missing leadership, insufficient contact
information for potential contributors and feature creep among others.

Troubles handling distributed version control systems
-----------------------------------------------------

BitBucket sucks, so we will ignore it and talk only about Github which is super
cool. As many of the world's developers woke up from the prehistory of zip
files and maybe CVS or Subversion directly into the bright and sparkling world
of git, the transition was less than ideal and we have found many of the
cro-magnon developers kept using their methodologies (or rather lack of any
formal methodology) for… ever. Despite git being a distributed version control
system allowing individuals to create peer to peer micro networks, the social
nature of humans forces them to stick all together like a pile of excrement to
a single known server, because God forbid anybody have a different opinion.

Branches are a much appreciated feature of git and other distributed version
control systems, but developers mostly talk about branches in future tense
without ever using them because, fuck it, why should they bother in the first
place when you can put everything in *master*.

As such, the best practice of creating a branch per feature of the software is
usually neglected and the *master* branch of git used as a recycle bin, with
software stability hopefully drawing a sinusoid function between official
release versions (but no guarantees on that). There is no exit from this pit of
despair, and we understand that developers who fall through it actually reach
one of the Circles of Hell in life, blurring the distinction of death.

Insufficient contact information
--------------------------------

Projects, especially those in the open source domain, tout themselves as having
the potential of attracting anybody and allowing them to contribute. But every
software project is different and requires a different approach to
contributions. Some projects require contributors to create issues while others
require their users to write documents and publish them for everybody else to
laugh at them (see pep)

Potential contributors find the lack of instructions or guidelines for
contribution as a hurdle. There is always the expectation that Murphy will make
your contribution, no matter how useful, linger in a special developer limbo
because you forgot to tag the issue correctly or didn't explicitly address one
of the developers with commit rights to the repository.

Missing leadership
------------------

Talking about developers with commit rights, there are many repositories which
at some point *block* development because its authors don't accept pull
requests and Google still points to their fork despite others being more
advanced. Sometimes a note like "*sorry, went out for coffee, will never be
back*" could give ideas to the contributors that the selected fork is a dead
end, but people don't want to be nice to each other, and therefore we can't
have nice things.

A variant of this phenomena is the Ivory Tower developer who once every two
moons graces the population with a visit, saying few words to some selected
developers and leaving the rest wondering what have they done in this, or their
previous life, to not be worthy. According to our measurements most thin
skinned contributors are effectively dissuaded from the project and never come
back, since they happen to fall somewhere in the middle between full moons and
see no activity.

Feature creep
-------------

Enough is enough. But people sometimes forget how much of enough is enough, and
keep adding without consideration. Instead of finishing fixing minor bugs, new
incomplete features are added to a project preventing it from ever reaching a
*stable* state. Combined with the lack of branches of most projects even
newcomers to a project will check out a repository and never get it working,
most of them leaving at that point to watch pictures of cats being posted to
reddit.

Feature creep is usually attributed to lack of focus. Lack of an updated task
list (aka TODO last updated two years ago), hundreds of issues piling up, or
mentions of heavy use of alcohol in forums or irc channels are indicators of
this.


USING GIT-FLOW
==============

Integration
-----------

LIMITATIONS
===========

RELATED WORK
============

CONCLUSION
==========

Acknowledgements
----------------

REFERENCES
==========


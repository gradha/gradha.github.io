====================================
How to release software periodically
====================================

:author: Grzegorz Adam Hankiewicz
:department: Software releases
:location: Spain, Colmenar Viejo, 28770
:contact: melissavirusiloveyou@gradha.imap.cc
:adult rating: not safe for work (NSFW)

ABSTRACT
========

We explain the perils and hiccups of existing software development both
professionally and in amateur circles with regards to software releases.
Software releases can be tamed and we propose a method which can be applied to
most software. We demonstrate how different projects stored in Github
[#github]_ compare and how they can improve. We dislike Bitbucket [#bitbucket]_
and therefore don't say much about them. We also talk in plural form despite us
being a single being, hopefully not because we suffer from schizophrenia or
delusions of grandeur; also we use semicolons whenever we feel like it and try
to concatenate word after word to create long enough sentences that not even a
professional Opera singer could say out loud in a single breath despite not
saying much at all; maybe.

Keywords
--------

9muses
Nimrod
babel
bike
dvcs
github
kpop
metal
nake
nakefiles
nsfw
pdf
politics
rst
shedding
snsd
swearing

INTRODUCTION
============

Releasing software once is simple; even an underage monkey trained in Ruby
[#ruby]_ or Python [#python]_ can access Github and upload anything, therefore
giving the impression of being hipster, but the question is how to follow the
initial release. In particular, there are many trained monkeys uploading
software to repositories seemingly at random and then leaving them to wither
without subsequent changes.  Individual talks [#nsa]_ with a non significant
statistically group of developers suggested the main reasons for the halting of
the development was a lack of defined guidelines for software releases,
troubles handling distributed version control systems, missing leadership,
insufficient contact information for potential contributors and feature creep
among others.  We leave other bus related [#bus]_ arguments out of the equation
as we are interested only in the situations where the will is there, but it is
obstructed by something else.


Troubles handling distributed version control systems
-----------------------------------------------------

Bitbucket sucks [#bbsucks]_, so we will ignore it and talk only about Github
which is super cool. As many of the world's developers woke up from the
prehistory of zip files and maybe CVS [#cvs]_ or Subversion [#subversion]_
directly into the bright and sparkling world of git [#git]_, the transition was
less than ideal and we have found many of the cro-magnon developers kept using
their methodologies (or rather lack of any formal methodology) for… ever.
Despite git being a distributed version control system allowing individuals to
create peer to peer micro networks, the social nature of humans forces them to
stick all together like a pile of excrement to a single known server, because
God forbid anybody have a different opinion.  Hence Github [#github]_.

Branches are a much appreciated feature of git and other distributed version
control systems, but developers mostly talk about branches in future tense
without ever using them because, fuck it, why should they bother in the first
place when you can put everything in *master*.

As such, the best practice of creating a branch per feature of the software is
usually neglected and the *master* branch of git used as a recycle bin, with
software stability hopefully drawing a sinusoid function between official
release versions (but no guarantees on that). There is no exit from this pit of
despair, and we understand that developers who fall through it actually reach
one of the Circles of Hell in life [#hell]_.

A little education of the tools you use every day can go a long way. Look, even
learning to read is hard, but you are reading this, so can't you see how much
you have already won? So go ahead and try reading some git documentation (see
manual online).

Poor or wrong contact information
---------------------------------

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

See http://code.google.com/p/openjpeg/wiki/DevelopmentProcess

Missing leadership
------------------

Talking about developers with commit rights, there are many repositories which
at some point *block* development because its authors don't accept pull
requests and Google still points to their fork despite others being more
advanced. Sometimes a note like "*sorry, went out for coffee, will never be
back*" could give ideas to the contributors that the selected fork is a dead
end, but people don't want to be nice to each other, and therefore we can't
have nice things (see obamacare).

A variant of this phenomena is the Ivory Tower Developer who once every two
moons graces the mortal population with a visit, saying few words to some
selected developers and leaving the rest wondering what have they done in this,
or their previous life, to not be worthy. According to our measurements most
thin skinned contributors are effectively dissuaded from the project and never
come back, since they happen to fall somewhere in the middle between full moons
and see no activity.

A similar problem happens when a project has several developers with commit
rights but there is no strict guideline on who does what. As such, if a pull
request or issue falls *between boundaries* of these developers, the time to
address the pull request or issue grows exponentially with the number of
overlapping developers (see figure).

The solution to missing leadership is political and falls out of the scope of
technology. Unless we could give electric shocks through the internet to other
people. We can only dream…


Feature creep
-------------

Enough is enough. But people sometimes forget how much of enough is enough, and
keep adding without consideration. Instead of finishing fixing minor bugs, new
incomplete features are added to a project preventing it from ever reaching a
*stable* state. Combined with the lack of branches of most projects even
newcomers to a project will check out a repository and never get it working,
most of them leaving at that point to watch pictures of cats that look like
Hitler [#kitlers]_ being posted on the internet.

Feature creep is usually attributed to lack of focus. Lack of an updated task
list (aka vague TODO last updated two years ago), hundreds of issues piling up,
or mentions of heavy use of alcohol in forums or irc channels are indicators of
this. You are a firefly and get distracted by shiny new things; we understand.


GIT-FLOW, SAVIOUR OF THE WORLD
==============================

Git-flow is a solution which can help with many of the enumerated problems. It
is essentially gratuitous bureaucracy applied to software development. At the
mere mention of bureaucracy most developers flee leaving a trail of screams and
pulled out hair. However, git-flow automates that bureaucracy to the bare
minimum, enforcing a practical guideline to develop.  Nothing from the points
described below actually require git-flow; it is just a bunch of scripts to
deal with the bureaucracy.

Git-flow is well documented and has plenty of fans who have already documented
how it works. These paper only highlights *why* it works, and how it solves the
problems software developers have.


Master is not the master any more?
----------------------------------

The first big change of how git-flow works is that by default it considers the
*master* branch to be stable. And rightly so: a newcomer to a project may want
to clone the repo and compile it. Since the default branch is *master*, it is
best if it is stable and compiles without issues. Hence, a secondary branch
named *develop* is created, where the actual commit and merge orgy happens.

When the developers consider that the contents of *develop* should be made
public, they can merge that branch with master. Git-flow will also tag the
source tree at that point with a version number and a message. Tags are
automatically understood by hosts like Github as software release points, and
it is very easy to create software releases from them.

Through this simple change an easy pattern is established: any branch merged
with master means a *public* change is done. During normal development these
public changes will mean normal bug free development.


Hotfixes
--------

Things go south. You know this if you are a developer. And to fix them,
*hotfixes* are issued. Sometimes a bug might be too embarrassing to leave out
there, or it involves the pride of your employer's son. Whatever the reason,
your normal development cycle is not fast enough and you have to stop whatever
you were happily doing in *develop* and fix *master* instead.

For these situations you start with git-flow a *hotfix* branch based on
*master*. In this branch you commit everything needed to make the software work
again and save countless puppies. Once the hotfix is finished, git-flow will
merge it against *master*, but it will also merge it against *develop*. This is
very handy in the case where the fix involves new code; the scripts make sure
it is applied in both places.

In the case of the hotfix involving applying code already found in the
*develop* branch because the political nature of the bug escalated (eg. known
crash which somebody figures how leak Scarlett Johansson private pictures
[#scarlett]_) you can simply cherry pick changes from the develop branch. Those
will be merged into master, and the automatic merge into *develop* again will
make sure that when your normal development cycle reaches the release state git
won't complain about duplicate stuff.

Necessary documentation
-----------------------

The disadvantage of using git-flow (or just about anything else other than
piling commits recklessly on *master*) is that it requires documentation. The
number of bureaucratic developers is still outweighed by the hordes of
senseless commit-happy hackers. As such, these hackers will clash with the
process unless it is clearly documented.

The bare minimum is mentioning that you use a specific kind of process for
software development. Mentioning git-flow and linking to it may be enough.

Sub develop branches
--------------------

The same process created around the master and develop branches can be reused
recursively for the purpose of clearly limiting feature creep for each release.
Moving development to a *develop* branch doesn't magically avoid feature creep.
If the next software release has to have features ``A``, ``B``, ``C`` and you
can't wait to implement ``D``, simply create another branch, maybe
*develop-future* where you add these changes. This split avoids that ``A``,
``B``, and ``C`` are eventually solved, but the *develop* branch can't be
merged into *master* because it contains an incomplete ``D``, or worse,
unstable. If you can't be arsed to finish the tasks required for the stable
release, at least don't get in the way of others implementing then.

This goes well also with periodical public releases. The old Vulcan saying
"Release early, release often" is usually ignored in its second part, because
most people try to avoid planning. Every three months in your development,
decide what features are enough to make a stable release and keep develop only
for them. Woah, we just rediscovered Debian's release cycle of stable, testing
and unstable. Aren't we clever? Any of your arguments against this is invalid
unless you prove that your software is more complex than an operative system
with thousands of interdependent packages. QED.

* modify other stuff to "watch videos" and put youtube
* change cat reference to kitlers

CONCLUSION AND LIMITATIONS
==========================



1. Lower collaboration threshold.


LIMITATIONS
===========

RELATED WORK
============

Acknowledgements
----------------

.. raw:: pdf

    PageBreak oneColumn

REFERENCES
==========

.. [#github] `_GitHub <https://github.com>`_.

.. [#bitbucket] `Atlassian Bitbucket <https://bitbucket.org>`_.

.. [#ruby] `Ruby, a programmer's best friend <http://www.ruby-lang.org/>`_.

.. [#python] `Python Programming Language <http://www.python.org>`_.

.. [#nsa] See `NSA archives <http://www.nsa.gov>`_ for the recorded
    conversations.

.. [#bus] `What if Linus Torvalds Gets Hit By A Bus?
    <http://www.crummy.com/writing/segfault.org/Bus.html>`_

.. [#bbsucks] `Spooning by Bitbucket <https://bitbucket.org/spooning/>`_.

.. [#cvs] `Concurrent Versions System <http://www.nongnu.org/cvs/>`_.

.. [#subversion] `Apache™ Subversion®, Enterprise-class centralized version
    control for the masses <https://subversion.apache.org>`_.

.. [#git] `git --distributed-is-the-new-centralized <http://git-scm.com>`_.

.. [#hell] `Infero, by Dante Alighieri
    <https://en.wikipedia.org/wiki/Circles_of_hell>`_.

.. [#kitlers] `Cats that look like hitler
    <http://www.catsthatlooklikehitler.com/>`_.

.. [#scarlett] `Scarlett Johannson Nude Cell Phone Pics
    <http://www.kineda.com/scarlett-johannson-nude-cell-phone-pics/>`_.


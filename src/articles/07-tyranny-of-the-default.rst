---
title: Tyranny of the default
date: 2014-01-14 21:18
tags: programming,bureaucracy,git
---

Tyranny of the default
======================

I'm a proponent of developing software in branches, and more particularly,
having a `stable or production branch which tracks public software releases
<https://www.atlassian.com/git/workflows#!workflow-gitflow>`_ for the purpose
of issuing hotfixes whenever necessary without interrupting the normal
development cycle. One nice tool which helps enforce this style of development
from the command line is `git-flow <https://github.com/nvie/gitflow>`_. It's
just a bunch of scripts which avoids typing repetitive commands. If you prefer
using a GUI, the `nice folks from Atlassian <http://www.atlassian.com>`_,
creators of `Bitbucket
<https://www.atlassian.com/software/bitbucket/overview>`_, also have released
`SourceTree <http://www.sourcetreeapp.com>`_, a `git <http://git-scm.com>`_ and
`Mercurial <http://mercurial.selenic.com>`_ client with `smart branching
support for git-flow
<http://blog.sourcetreeapp.com/2012/08/01/smart-branching-with-sourcetree-and-git-flow/>`_.

But the defaults for git-flow and any git host like `GitHub
<https://github.com>`_ clash. By default git, and any git hosting, is going to
create empty repositories with a default branch named ``master``. When you
initialize git-flow on such a repo, it will ask a set of questions and suggest
defaults::

    $ git-flow init
    No branches exist yet. Base branches must be created now.
    Branch name for production releases: [master] 
    Branch name for "next release" development: [develop] 

    How to name your supporting branch prefixes?
    Feature branches? [feature/] 
    Release branches? [release/] 
    Hotfix branches? [hotfix/] 
    Support branches? [support/] 
    Version tag prefix? [] 

This is bad. Everybody tool by default will make changes on the ``master``
branch, but that's not what you want! You actually want other people to make
changes based off the ``develop`` branch. This is what I call the tyranny of
the default, which I first heard from `Steve Gibson on the Security Now podcast
<https://www.grc.com/securitynow.htm>`_. The idea behind this tyranny is
simple: most people don't touch the settings of their software.

And therefore, if you are a git-flow user, you are likely using the wrong
default. It is the wrong default because anybody forking your project and
sending pull requests will do so against the ``master`` branch. Fortunately,
`GitHub allows one to change the default branch
<https://help.github.com/articles/setting-the-default-branch>`_ of any
repository. You can do this at any time: from that moment on, any user cloning
the repository will get the new default branch, and 

Should master die in a fire?
============================

The question is, should you keep using ``master`` for the stable even after
changing GitHub default branch? Many users are unaware of sophisticated branch
development, so they may anyway try to look at the ``master`` branch ignoring
project documentation (which is likely to be missing anyway…). Also, since
``master`` is a default, it is likely there is software out there which has
*hardcoded* values which may fail.  Discovering these and communicating them to
the developers is a nice touch.

For these reasons it is best if you avoid having a ``master`` branch **at
all**.  What would you call it? ``releases`` is too close to the ``release``
branches temporarily created by git-flow. ``official`` sounds weird. Maybe
``stable``, which indicates to people that the branch is *safe* and won't crash
and burn.

```
$ git checkout develop
error: pathspec 'develop' did not match any file(s) known to git.
```

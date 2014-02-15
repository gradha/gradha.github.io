---
title: Master can't die
date: 2014-02-06 10:34
tags: programming,bureaucracy,git,tools
---

Master can't die
================

In a `previous article
<http://gradha.github.io/articles/2014/01/the-tyranny-of-gitflow-defaults.html>`_
I suggested renaming repository branch ``master`` to ``stable`` and leave
``develop`` as the development hub. Part was to inform users, and part to
detect which software is unable to work with git repositories without a master
branch. Well, that didn't took long: no git clients on earth work properly if
you remove master.

The official git client comes closest: it *works*, where *works* means it gets
the source code, but lacking a ``master`` branch prevents it from populating
*by default* the files in the directory and you are left with the hidden
``.git`` thinking something is not working. So you either have to specify the
branch name to checkout during the cloning operation, or check out, get a weird
warning, then manually checkout one of the available branches. Other clients
like SourceTree seem to refuse to work with the empty repo, or don't know what
to do next. I guess checking any branch if ``master`` is not available is too
hard for developers to figure out. Or maybe it is part of the git spec?

Anyway, you can't get rid off of ``master`` unless you want to deal with user
support nightmares. So the alternative I'm settling for is to leave ``master``
as the unstable development branch (goes well with github and most people's
expectations), and make git-flow use a ``stable`` branch for software releases.
This is essentially the *inverse* of git-flow defaults: where it creates an
extra ``develop`` branch, I create a ``stable`` branch with reversed meaning.

::

    $ git clone https://github.com/gradha/seohtracker-ios.git
    ...
    warning: remote HEAD refers to nonexistent ref, unable to checkout

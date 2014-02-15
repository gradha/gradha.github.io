---
title: The tyranny of git-flow defaults
date: 2014-01-18 00:39
tags: programming,bureaucracy,git,tools
---

The tyranny of git-flow defaults
================================

**UPDATE:** The suggestion to remove the git ``master`` branch is very bad. `It
is better to keep it
<http://gradha.github.io/articles/2014/02/master-cant-die.html>`_ and change
git-flow's ``develop`` for a ``stable`` branch.

I'm a proponent of developing software in branches, and more particularly,
having a `stable or production branch which tracks public software releases
<https://www.atlassian.com/git/workflows#!workflow-gitflow>`_ for the purpose
of performing hotfixes whenever necessary without interrupting the normal
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
initialize git-flow on such a repository, it will ask a set of questions and
suggest defaults::

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

This is bad. Everybody by default will make changes on the ``master`` branch,
but that's not what you want! You actually want other people to make changes
based off the ``develop`` branch. This is what I call the tyranny of the
default, which I first heard from `Steve Gibson on the Security Now podcast
<https://www.grc.com/securitynow.htm>`_. The idea behind this tyranny is
simple: most people don't touch the settings of their software.

And therefore, if you are a git-flow user, you are likely using the wrong
default for collaboration. It is the wrong default because anybody forking
your project and sending pull requests will do so against the ``master``
branch. Fortunately, `GitHub allows one to change the default branch
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

The rest of this post is a guide to perform the necessary changes to follow
this convention of having a ``stable`` branch and a ``develop`` branch which is
the default receiver of pull requests. Unfortunately git doesn't track branch
renames, so if you already have a repository and plan to go on a renaming
spree, you will hear a lot of complaints. On the other hand, git tells you if
you try to pull from a branch which has disappeared, so at least people will
notice, unlike a lot of RSS feeds which don't age well…

Cases for repository owners
===========================

Starting from scratch
---------------------

The ideal situation, create your project locally, then upload to GitHub. It's
the ideal case because nobody will *suffer* the change::

    $ mkdir secretharem
    $ cd secretharem
    $ git init
    $ git-flow init
    [answer with 'stable' instead of the default 'mater']

The ``git-flow init`` command will create each branch with an initial commit.
Now you can go to GitHub and create an empty repository, then we upload the
branches (note we specify both ``stable`` and ``develop``)::

    $ git remote add origin git@github.com:user/secretharem.git
    $ git push -u origin stable develop

Interestingly at this point GitHub will have picked ``develop`` as the default
branch for the project, likely due to ASCII sorting. But it won't hurt if you
go to ``https://github.com/user/secretharem/settings`` and verify that the
default branch is set to ``develop``.

This is the ideal setup because your repository starts with the *correct*
configuration, and any future forks on GitHub will use that information for
pull requests against the ``develop`` branch.

Moving an existing repo to git-flow
-----------------------------------

Usually you will have a repository with the ``master`` branch and no more.
Before initializing git-flow you should rename the master branch::

    $ git clone git@github.com:user/worldneedsmorexml.git
    $ cd worldneedsmorexml
    $ git checkout -b develop
    $ git checkout -b stable
    $ git-flow init
    [answer with 'stable' first, 'develop' later]
    $ git push --set-upstream origin develop stable

From the lonely ``master`` branch we create first the aliases ``develop`` and
``stable`` because otherwise git-flow complaints that they don't exist. After
the branches have been pushed to GitHub, go to
``https://github.com/user/worldneedsmorexml/settings`` and change the default
branch from ``master`` to ``develop``. If you don't this, trying to delete the
master branch will fail because **you can't remove from GitHub the default
branch**. After that, deletion is easy::

    $ git branch -d master
    $ git push origin :master

The syntax for removing branches is that, pushing the branch with a colon
before its name.

Renaming a git-flow master branch to stable
-------------------------------------------

If you have a repository using git-flow and want to rename ``master`` to
``stable``, first go to GitHub's settings and change the default branch to
``develop`` which you will likely have not done yet. Then::

    $ cd ilovekpop
    $ git checkout develop
    $ git branch -m master stable
    $ git push --set-upstream origin stable
    $ git push origin :master
    [now edit .git/config with your text editor]

Since git-flow is already initialized locally, it will be tracking the old
``master`` branch. Open ``.git/config`` and rename that to ``stable``. After
that everything should keep working as usual.

Cases for people with a cloned repository
=========================================

Starting from scratch
---------------------

Not hard, you do a ``git clone`` and the default GitHub branch (``develop``)
gets checked out.

Existing clone after branch rename
----------------------------------

Users with existing checkouts will get the following message when they try to
pull from the deleted branch::

    Your configuration specifies to merge with the ref 'master'
    from the remote, but no such ref was fetched.

This means that the branch has disappeared. And hopefully the user noticed
during the previous ``git pull`` that new branches were created. The user can
then check out one of the new branches and delete master::

    $ git checkout develop|stable
    $ git branch -d master

Cases for users with forks
==========================

Well, this is interesting. If I recall correctly, in the good old days of
GitHub each forked repository had a button on the website which allowed you to
*merge upstream changes* clicking on it. This seems to have been gone and
replaced with `instructions to perform those changes manually from the command
line <https://help.github.com/articles/syncing-a-fork>`_ (so much for GUIs,
eh?). And likely for good reason: it rarely worked, and for popular
repositories with many forks it surely taxed their servers, because it would
look for changes not only in the *upstream* repository but also other forks
(remember, git is a distributed version control system, so there's no *real*
upstream or server). In fact, I remember having to refresh that page several
times due to the amount of time it took to calculate *changes* to merge.

Well, presuming you have configured an `upstream source like their instructions
suggest <https://help.github.com/articles/syncing-a-fork>`_, you can update
your ``master`` branch to follow either of the new ones with simple local
commands, then delete your ``master``::

    $ git checkout -b develop
    $ git merge upstream/develop
    $ git push --set-upstream origin develop
    $ git branch -d master
    $ git push origin :master
    remote: error: refusing to delete the current branch: refs/heads/master
    To git@github.com:forkuser/healthyspam.git
     ! [remote rejected] master (deletion of the current branch prohibited)
     error: failed to push some refs to 'git@github.com:forkuser/healthyspam.git'
    $

Ah, indeed. Remember, **you can't remove GitHub's default branch**. You first
need to go to your own fork on GitHub, change the repository settings to the
recently pushed ``develop`` branch, and then you can remove your old
``master``. Replace the commands with ``stable`` if you would prefer to track
that instead.

One strange feature of git is that after a remote branch has been deleted, you
will likely still see it if you try to list it::

    $ git fetch upstream
    remote: Counting objects: 8, done.
    remote: Total 6 (delta 1), reused 6 (delta 1)
    Unpacking objects: 100% (6/6), done.
    From github.com:remoteuser/healthyspam
     * [new branch]      develop    -> upstream/develop
     * [new branch]      stable     -> upstream/stable
    $ git branch -va
    * master                   a8e1d54 Initial commit
      remotes/origin/HEAD      -> origin/master
      remotes/origin/master    a8e1d54 Initial commit
      remotes/upstream/develop 280e777 Develop
      remotes/upstream/master  a8e1d54 Initial commit
      remotes/upstream/stable  8cdc31d Stable

You only need to `run a command to prune the local cache
<http://stackoverflow.com/a/1072178/172690>`_::

    $ git remote prune upstream
    Pruning upstream
    URL: git@github.com:remoteuser/healthyspam.git
     * [pruned] upstream/master

Now you are clean and properly updated with the upstream branches.


But users get now the develop branch by default!
================================================

Indeed, if you have changed GitHub's default branch to ``develop`` and a user
clones a repository, by default he gets that single development branch. And
that's what you want, really. Git is not a software distribution platform (cue
complaints from people downloading huge repository histories), it's for
developers.  If you are in the situation of having multiple branches, one of
them for releases, that's because you are *doing* public releases. Your users
willing to get a stable version will get those, or will follow your
documentation (or their intuition) to check out the ``stable`` branch.

**UPDATE:** The suggestion to remove the git ``master`` branch is very bad. `It
is better to keep it
<http://gradha.github.io/articles/2014/02/master-cant-die.html>`_ and change
git-flow's ``develop`` for a ``stable`` branch.

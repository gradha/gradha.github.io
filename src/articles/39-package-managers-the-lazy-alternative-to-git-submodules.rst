---
title: Package managers, the lazy alternative to git submodules
pubdate: 2018-11-19 01:30
moddate: 2018-11-19 01:30
tags: design, user experience, programming, git, tools, python
---

Package managers, the lazy alternative to git submodules
========================================================

The problem
-----------

.. raw:: html

    <a href="http://www.idol-grapher.com/2099"
        ><img src="../../../i/lazy_developers.jpg"
        alt="I'm not lazy, I'm just saving my energy"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>


Package managers have always looked strange to me. Why would you *want* to use
one?  It is actually not weird to have that point of view, especially if your
background comes from programming languages like C or C++, which don't have any
well known package manager (`even though people keep trying to build some
<https://stackoverflow.com/a/36023212/172690>`_) and `developers resort to
using the system libraries/packages or git submodules to manage their software
builds
<https://www.reddit.com/r/cpp/comments/3d1vjq/is_there_a_c_package_manager_if_not_how_do_you/>`_.
On the other hand, people mostly coming from interpreted languages are so used
to the idea that **not** using a package manager seems like crazy advice.
Today, software development uses some form of source content management, and it
seems like `git <https://git-scm.com>`_ has *won the war*, especially since it
is used by `GitHub <https://github.com>`_, possibly the most popular free
repository choice for open source and free software. As such, many developers
are exposed to ``git``, but not many know about `submodules
<https://git-scm.com/docs/gitsubmodules>`_, a command which allows you to keep
track external sources in a secure and deterministic way.

Package managers are more user friendly than ``git submodule``, and the
requirements to get started using one tend to be reduced to writing a simple
text file and running one or at most two commands to download all the
dependencies. Package managers have thus exploded in circles where software
distribution is preferably done in source code form, requiring end users to
build the source or run it (in the case of interpreted languages). Rather than
asking users to install dependencies one by one into their system, package
managers typically allow downloading source or binary dependencies into the
project, usually without requiring a system install, allowing users to build
the project without administrator rights on a system (quite useful for build
servers, own or rented).

However, this user friendliness towards developers and users is starting to
catch developers unguarded of malicious intent. In the case of the `npm
<https://www.npmjs.com>`_ ecosystem, `malicious actors have sometimes gained
access to the accounts of certain developers and uploaded malicious versions of
their packages
<https://www.bleepingcomputer.com/news/security/compromised-javascript-package-caught-stealing-npm-credentials/>`_.
Recently Homebrew, the so called missing package manager for macOs, suffered a
`supply chain attack
<https://medium.com/@vesirin/how-i-gained-commit-access-to-homebrew-in-30-minutes-2ae314df03ab>`_,
where people blindly trusting and downloading Homebrew packages could have
gotten extra unwanted code. Using ``git submodule`` doesn't offer any
protection against malicious developers uploading libraries with *hidden
malicious behavior*, but it can help to prevent the supplantation of an
existing *good* package with a bad one (`unless you are capable of subverting
git hashes <https://stackoverflow.com/a/23253149/172690>`_, of course).

Package managers keep references to external packages through a textual version
requirement number, usually in the form of a string like ``2.3.4`` or
``2.*``/``2.+`` (which are even **worse** from a security point of view because
not even you are sure what you will get from the dependency!). The local
package manager fetches data from an external repository and gets the specified
number or the latest matching the version pseudo regular expression.  That's
where the attack comes, you are trusting this package to be the one you *mean*.
On the other hand, using ``git submodule`` forces you to refer to a specific
git hash, and that can't be subverted.

I'm used to the popular package managers for mobile development (`Cocoapods
<https://cocoapods.org>`_ for iOS and gradle/maven for Android) and in terms of
security they offer none by default for supply chain attacks. In the case of
``gradle``, `software dependencies are specified as version numbers
<https://docs.gradle.org/current/userguide/managing_dependency_configurations.html#managing_dependency_configurations>`_
(ie. com.google.guava:guaga:23.0). Cocoapods does essentially the same, which
means that both iOS and Android developers are subject to supply chain attacks
if somebody manages to hijack the repository and replace the dependency. The
security conscious developer could fetch the dependencies and commit the
fetched version into their repository, getting the worst cross between a
package manager and ``git submodule``: potentially big repository increase,
versioning *noise* and manual dependencies.

In order to be *secure* and get exactly what you want, for `Cocoapods you need
to specify a git repository and a specific commit
<https://guides.cocoapods.org/using/the-podfile.html>`_ (oh my, doesn't that
look like a ``git submodule`` thing). Recent versions of `gradle are starting
to allow specifying git repositories and branches
<https://blog.gradle.org/introducing-source-dependencies>`_, so being able to
specify a specific commit will hopefully come along.  Same thing applies to the
`nimble package manager <https://github.com/nim-lang/nimble>`_ for the `Nim
programming language <https://nim-lang.org>`_. Most certainly the majority of
users will specify a string version number, but it also offers the possibility
of specifying a specific hash (note that git tags or branches aren't safe
either, they can be changed!). Extract from the documentation:

    ``$ nimble install nimgame@#head``

    *This is of course Git-specific, for Mercurial, use tip instead of head. A
    branch, tag, or commit hash may also be specified in the place of head.*

At this point the package manager is just a fancy wrapper around the ``git
submodule`` command, so is it really needed? It is true that package managers
can offer more features, like search of packages by keywords or automatic
build/testing features, so maybe there is a valid reason for using package
managers they reduce the amount of work a developer has to do, but in terms of
supply chain attacks and build reproducibility they are just a ticking bomb
waiting to explode in your face. Plus I'd argue those *other* features are best
serviced somewhere else, or in different separate commands/tools (the last
thing you want for user friendliness is a package manager with more command
line switches than git!).

Luckily for package managers the solution is trivial: add an option to specify
the hash of the downloaded package. Just normalize the *hacks* which allow you
to specify a git commit into a generic package hash, allowing for normal
binary/zip distribution to also be safe, and make that hash not dependant on
the protocol for people with other source versioning software.

Even if developers are lazy and use an arbitrary version number to get a
package into their system because they are exploring solutions, as long as they
validate it and verify it is OK, they could then *freeze* the local hash into
their build specification. With this simple change, supply chain attacks would
be prevented, because changing a good ``2.3.4`` package into an evil ``2.3.4``
would necessarily alter the hash of the final package, and the package manager
could flag it and prevent including malicious code into a project (pretty
important for automated continuous integration build machines distributing
nightly snapshots of a development branch to end users!).

One more feature I find very useful of **not** using package managers is the
specification of different or conflicting versions of a dependency compared to
one installed globally on the system and making sure nothing in the build
environment affects the build. In order to have reproducible builds you want
the compiler to read the version you want and nothing else. Yet it happened to
me in the past that I was *expecting* the build of a program to use a library
installed in a directory, but the default compiler search path was getting the
same named library from another place, thus getting a different version for a
hilarious waste of time. For Nim code this has lead me to always use the
`noNimblePath compiler switch <https://nim-lang.org/docs/nimc.html>`_ which
prevents any global or pseudo global modules to be included in the project and
forces you to specify the local path to the modules you want to use. This is
more important for people building libraries for others, so I guess it's not so
important for the majority of developers. People like solving problems with big
guns, so you end up seeing teams provisioning virtual machines to make
reproducible builds, rather than asking their tools to be able to deal with the
environment properly. Talk about priorities.

.. raw:: html

    <center><a href="http://thestudio.kr/2302"
        ><img src="../../../i/everything_has_a_solution.jpg"
        alt="Did you see that? Adding an optional hash parameter will make us look good again in the cataratic eyes of a few picky programmers"
        style="width:100%;max-width:750px" align="center"
        hspace="8pt" vspace="8pt"></a></center>


Still prefer git? Keep calm and commit bugfixes
-----------------------------------------------

Most developers think that the URLs baked into git submodules can't be changed,
but this would defeat the purpose of a decentralized source control management
tool.  In order to see how flexible git submodules are without suffering from
supply chain attacks, we will go through a multi repository scenario.
Digression: why do many git tutorials and documentation present the scenario of
programming on an airplane (search for the `word
<https://www.atlassian.com/git/tutorials/what-is-git>`_ `airplane
<https://www2.cisl.ucar.edu/sites/default/files/2016%20March%2011%20-%20Git%20Training.pdf>`_)?
It is confusing, I thought programmers were meant to never leave their parents'
basement? What are programmers now, some kind of `idols travelling to places
<http://www.asianjunkie.com/2017/04/11/fans-mad-at-jype-cause-they-showed-up-at-an-airport-unprompted-to-meet-twice/>`_
and `getting harassed at airports
<http://www.asianjunkie.com/2017/12/12/siyeon-reveals-just-how-much-she-cares-about-airport-fashion-confirms-love-of-pants/>`_
by reporters asking them `what their latest commit was
<http://www.youtube.com/watch?v=-4aux5NTjSU>`_?  I'm so confused Internet, `get
your stereotypes right
<https://knowyourmeme.com/memes/the-hacker-known-as-4chan>`_!

Anyway, we will fix a bug in a project dependency completely offline across
packages, which will require changing the remote repositories to local ones
where the work will be done for a while, then upload for others to check. The
magic of commit hashes will allow us to orchestrate offline a series of related
commits without having to push to a public repository. In fact, since reviews
are so common, we will make changes in separate branches for entangled pull
requests. All offline. In an airplane. `With freaking snakes
<https://www.youtube.com/watch?v=rfscVS0vtbw>`_.

Before we step on the airplane, however, we need to construct our public
repositories to verify this is all working. I'm going to use `GitLab
<https://gitlab.com>`_ for the example but any other host will work. By going
to `https://gitlab.com/projects/new <https://gitlab.com/projects/new>`_ I
create new ``gsm_lib_module`` and ``gsm_miner`` projects, both public.  Let's
create some local code to fill those awesome repositories with Python::

    [~]$ cd /tmp/

    [/tmp]$ mkdir gsm_lib_module

    [/tmp]$ cd gsm_lib_module/

    [/tmp/gsm_lib_module]$ vim .gitignore

    [/tmp/gsm_lib_module]$ cat .gitignore
    *.pyc
    *.swp
    .DS_Store

    [/tmp/gsm_lib_module]$ git init
    Initialized empty Git repository in /private/tmp/gsm_lib_module/.git/

    [/tmp/gsm_lib_module(master)]$ git add .gitignore

    [/tmp/gsm_lib_module(master)]$ git commit -av -m "Starting repo"
    [master (root-commit) 02e0f10] Starting repo
     1 file changed, 3 insertions(+)
     create mode 100644 .gitignore

    [/tmp/gsm_lib_module(master)]$ vim lib_module.py

    [/tmp/gsm_lib_module(master)]$ cat lib_module.py
    def say_hello_lib():
        print("Hello lib")

    if __name__ == "__main__":
        say_hello_lib()

    [/tmp/gsm_lib_module(master)]$ vim __init__.py

    [/tmp/gsm_lib_module(master)]$ cat __init__.py
    from lib_module import say_hello_lib

    [/tmp/gsm_lib_module(master)]$

    [/tmp/gsm_lib_module(master)]$ git commit -av -m "Blockchain library"
    [master ee19c05] Blockchain library
     2 files changed, 6 insertions(+)
     create mode 100644 __init__.py
     create mode 100644 lib_module.py

    [/tmp/gsm_lib_module(master)]$ git remote add origin git@gitlab.com:gradha/gsm_lib_module.git

    [/tmp/gsm_lib_module(master)]$ git push -u origin master
    Counting objects: 7, done.
    Delta compression using up to 8 threads.
    Compressing objects: 100% (4/4), done.
    Writing objects: 100% (7/7), 661 bytes | 661.00 KiB/s, done.
    Total 7 (delta 0), reused 0 (delta 0)
    To gitlab.com:gradha/gsm_lib_module.git
     * [new branch]      master -> master
    Branch 'master' set up to track remote branch 'master' from 'origin'.

With that sequence of commands we will have a library project available at
`https://gitlab.com/gradha/gsm_lib_module
<https://gitlab.com/gradha/gsm_lib_module>`_. Your URLs will be different, of
course, due to the username being different. Let's create now an awesome python
blockchain thingy::

    [~]$ cd /tmp/

    [/tmp]$ mkdir gsm_miner

    [/tmp]$ cd gsm_miner/

    [/tmp/gsm_miner]$

    [/tmp/gsm_miner]$ vim .gitignore

    [/tmp/gsm_miner]$ cat .gitignore
    *.pyc
    *.swp
    .DS_Store

    [/tmp/gsm_miner]$ git init
    Initialized empty Git repository in /private/tmp/gsm_miner/.git/

    [/tmp/gsm_miner(master)]$ git add .gitignore

    [/tmp/gsm_miner(master)]$ git commit -av -m "Starting repo"
    [master (root-commit) 69f664f] Starting repo
     1 file changed, 3 insertions(+)
     create mode 100644 .gitignore

    [/tmp/gsm_miner(master)]$ vim program.py

    [/tmp/gsm_miner(master)]$ cat program.py
    import gsm_lib_module

    def main():
        print("Running main module")
        gsm_lib_module.say_hello_lib()

    if __name__ == "__main__":
        main()

    [/tmp/gsm_miner(master)]$ git submodule init

    [/tmp/gsm_miner(master)]$ git submodule add https://gitlab.com/gradha/gsm_lib_module.git
    Cloning into '/private/tmp/gsm_miner/gsm_lib_module'...
    remote: Enumerating objects: 7, done.
    remote: Counting objects: 100% (7/7), done.
    remote: Compressing objects: 100% (4/4), done.
    remote: Total 7 (delta 0), reused 0 (delta 0)
    Unpacking objects: 100% (7/7), done.

    [/tmp/gsm_miner(master)]$ python program.py
    Running main module
    Hello lib

    [/tmp/gsm_miner(master)]$ git add program.py

    [/tmp/gsm_miner(master)]$ git commit -av -m "Getting there"
    [master da08e71] Getting there
     3 files changed, 12 insertions(+)
     create mode 100644 .gitmodules
     create mode 160000 gsm_lib_module
     create mode 100644 program.py

    [/tmp/gsm_miner(master)]$ git remote add origin git@gitlab.com:gradha/gsm_miner.git

    [/tmp/gsm_miner(master)]$ git push -u origin master
    Counting objects: 7, done.
    Delta compression using up to 8 threads.
    Compressing objects: 100% (5/5), done.
    Writing objects: 100% (7/7), 756 bytes | 756.00 KiB/s, done.
    Total 7 (delta 0), reused 3 (delta 0)
    To gitlab.com:gradha/gsm_miner.git
     * [new branch]      master -> master
    Branch 'master' set up to track remote branch 'master' from 'origin'.


Offline hacking via the dangerous method
----------------------------------------

.. raw:: html

    <div style="background-color:yellow;float:right;margin:1px"
        ><a href="https://youtu.be/4sDgpOdOGFI?t=370"><video autoplay muted loop
        style="width: 300px; height: 168px;"> <source
        src="../../../i/omg_blockchain.mp4" type="video/mp4"
        /><img src="../../../i/omg_blockchain.gif" width=300 height=168></video></a></div>


And there you go, our first friendly steps towards blockchain investors. A few
minutes after pushing this repo we hear the phone ringing: investors are all
lined up to pay zillions, but they want to have a personal presentation in
some far away place which requires travelling by airplane. Minutes before
embarking the investors call and request a change. Oh noes, now you have to
work hard on the plane without internet. Once the airplane is off the ground
you furiously start changing the library repository to add a new function::

    [/tmp/gsm_miner(master)]$ cd /tmp/gsm_lib_module/

    [/tmp/gsm_lib_module(master)]$ git co -b happy_investors
    Switched to a new branch 'happy_investors'

    [/tmp/gsm_lib_module(happy_investors)]$ vim lib_module.py

    [/tmp/gsm_lib_module(happy_investors)]$ cat lib_module.py
    def say_hello_lib():
        print("Hello lib")

    def welcome_zillions():
        print("send moneys")

    if __name__ == "__main__":
        say_hello_lib()

    [/tmp/gsm_lib_module(happy_investors)]$ vim __init__.py

    [/tmp/gsm_lib_module(happy_investors)]$ cat __init__.py
    from lib_module import *

    [/tmp/gsm_lib_module(happy_investors)]$ git commit -av -m "One step closer to nirvana"
    [happy_investors da0578a] One step closer to nirvana
     2 files changed, 4 insertions(+), 1 deletion(-)

Now the repository is changed locally, but how are we going to reference that
commit without being able to push it? There are two ways, so for the
convenience of the tutorial let's create a copy of the main repository before
touching it so we can do both methods and compare. The first method is easy but
potentially dangerous::

    [~]$ cd /tmp

    [/tmp]$ cp -r gsm_miner gsm_miner_2

    [/tmp]$ cd gsm_miner

    [/tmp/gsm_miner(master)]$ cat .gitmodules
    [submodule "gsm_lib_module"]
        path = gsm_lib_module
        url = https://gitlab.com/gradha/gsm_lib_module.git

    [/tmp/gsm_miner(master)]$ vim .gitmodules

    [/tmp/gsm_miner(master)]$ cat .gitmodules
    [submodule "gsm_lib_module"]
        path = gsm_lib_module
        url = file:///tmp/gsm_lib_module

    [/tmp/gsm_miner(master)]$ git submodule sync
    Synchronizing submodule url for 'gsm_lib_module'

    [/tmp/gsm_miner(master)]$ cd gsm_lib_module/

    [/tmp/gsm_miner/gsm_lib_module(master)]$ git remote -v
    origin	file:///tmp/gsm_lib_module (fetch)
    origin	file:///tmp/gsm_lib_module (push)

    [/tmp/gsm_miner/gsm_lib_module(master)]$ git pull
    remote: Counting objects: 4, done.
    remote: Compressing objects: 100% (3/3), done.
    remote: Total 4 (delta 0), reused 0 (delta 0)
    Unpacking objects: 100% (4/4), done.
    From file:///tmp/gsm_lib_module
     * [new branch]      happy_investors -> origin/happy_investors
    Already up to date.

    [/tmp/gsm_miner/gsm_lib_module(master)]$ git checkout happy_investors
    Branch 'happy_investors' set up to track remote branch 'happy_investors' from 'origin'.
    Switched to a new branch 'happy_investors'

    [/tmp/gsm_miner/gsm_lib_module(happy_investors)]$ cd ..

    [/tmp/gsm_miner(master)]$ vim program.py

    [/tmp/gsm_miner(master)]$ cat program.py
    import gsm_lib_module

    def main():
        print("Running main module")
        gsm_lib_module.say_hello_lib()
        gsm_lib_module.welcome_zillions()

    if __name__ == "__main__":
        main()

    [/tmp/gsm_miner(master)]$ python program.py
    Running main module
    Hello lib
    send moneys

    [/tmp/gsm_miner(master)]$ git status
    On branch master
    Your branch is up to date with 'origin/master'.

    Changes not staged for commit:
      (use "git add <file>..." to update what will be committed)
      (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   .gitmodules
        modified:   gsm_lib_module (new commits)
        modified:   program.py

    no changes added to commit (use "git add" and/or "git commit -a")

    [/tmp/gsm_miner(master)]$ git add gsm_lib_module program.py

    [/tmp/gsm_miner(master)]$ git commit -m "I'm leet"
    [master 2e653f5] I'm leet
     2 files changed, 2 insertions(+), 1 deletion(-)

    [/tmp/gsm_miner(master)]$ git show
    commit 2e653f562c69cdaf05c6b7c18655a59cbaf742fa (HEAD -> master)
    Author: Grzegorz Adam Hankiewicz <gradha@imap.cc>
    Date:   Sun Nov 18 22:52:00 2018 +0100

        I'm leet

    diff --git a/gsm_lib_module b/gsm_lib_module
    index ee19c05..da0578a 160000
    --- a/gsm_lib_module
    +++ b/gsm_lib_module
    @@ -1 +1 @@
    -Subproject commit ee19c0528e5ba8d375362ec557b4126ee916ce0d
    +Subproject commit da0578a23ac4823a4164ebd37d1500f777e24128
    diff --git a/program.py b/program.py
    index 4b77e2b..c278166 100644
    --- a/program.py
    +++ b/program.py
    @@ -3,6 +3,7 @@ import gsm_lib_module
     def main():
         print("Running main module")
         gsm_lib_module.say_hello_lib()
    +    gsm_lib_module.welcome_zillions()

     if __name__ == "__main__":
         main()

OK, so what have we done here? The first step is to modify the ``.gitmodules``
file and change the http URL with a local path. The ``git submodule sync``
takes the contents of ``.gitmodules`` and does whatever sorcery is needed to
make the repository point to that local path instead of the internet. Next, as
any programmer would do, we enter the submodule, check that it points to our
local file, and pull changes in order to switch the submodule to the commit of
the new branch not available online yet.

The dangerous part is changing files inside ``gsm_miner`` carefully, we want to
commit everything **except** the ``.gitmodules`` file. If we were to include
this file in a commit and push it to the public, **everybody** would get those
changes and their online URL would be replaced by a path they likely won't have
and thus break the program. Zillions of investment would be lost.  Still, if
you are careful avoiding to include the ``.gitmodules`` file this is a valid
strategy. Once online, we could discard the local changes to ``.gitmodules``,
run ``git submodule sync`` and continue as if we had been all the time online.

.. raw:: html

    <center><a href="http://dijkcrayon.tistory.com/478"
        ><img src="../../../i/suspicious_choa.jpg"
        alt="Wait a second, why do I need to ignore changes to a file tracked by git?"
        style="width:100%;max-width:600px" align="center"
        hspace="8pt" vspace="8pt"></a></center>


Offline hacking via the icky method
-----------------------------------

Let's see an alternate way of doing the same without the dangers of commiting
weird paths to our repository. The ugly part here is that we need to change the
repository URL in *internal* configuration files which are only visible to us,
and changing ``.git`` internal files is always icky::

    [~]$ cd /tmp

    [/tmp]$ cd gsm_miner_2/

    [/tmp/gsm_miner_2(master)]$ cat .git/config
    [core]
        repositoryformatversion = 0
        filemode = true
        bare = false
        logallrefupdates = true
        ignorecase = true
        precomposeunicode = true
    [branch "master"]
    [submodule "gsm_lib_module"]
        url = https://gitlab.com/gradha/gsm_lib_module.git
        active = true
    [remote "origin"]
        url = git@gitlab.com:gradha/gsm_miner.git
        fetch = +refs/heads/*:refs/remotes/origin/*
    [branch "master"]
        remote = origin
        merge = refs/heads/master

    [/tmp/gsm_miner_2(master)]$ vim .git/config

    [/tmp/gsm_miner_2(master)]$ cat .git/config
    [core]
        repositoryformatversion = 0
        filemode = true
        bare = false
        logallrefupdates = true
        ignorecase = true
        precomposeunicode = true
    [branch "master"]
    [submodule "gsm_lib_module"]
        url = file:///tmp/gsm_lib_module
        active = true
    [remote "origin"]
        url = git@gitlab.com:gradha/gsm_miner.git
        fetch = +refs/heads/*:refs/remotes/origin/*
    [branch "master"]
        remote = origin
        merge = refs/heads/master

    [/tmp/gsm_miner_2(master)]$ rm -Rf .git/modules/gsm_lib_module

    [/tmp/gsm_miner_2(master)]$ rm -R gsm_lib_module/

    [/tmp/gsm_miner_2(master)]$ git submodule init

    [/tmp/gsm_miner_2(master)]$ git submodule update
    Cloning into '/private/tmp/gsm_miner_2/gsm_lib_module'...
    Submodule path 'gsm_lib_module': checked out 'ee19c0528e5ba8d375362ec557b4126ee916ce0d'

    [/tmp/gsm_miner_2(master)]$ cd gsm_lib_module/

    [/tmp/gsm_miner_2/gsm_lib_module((ee19c05...))]$ git checkout happy_investors
    Previous HEAD position was ee19c05 Blockchain library
    Switched to branch 'happy_investors'
    Your branch is up to date with 'origin/happy_investors'.

    [/tmp/gsm_miner_2/gsm_lib_module(happy_investors)]$ cd ..

    [/tmp/gsm_miner_2(master)]$ git status
    On branch master
    Your branch is up to date with 'origin/master'.

    Changes not staged for commit:
      (use "git add <file>..." to update what will be committed)
      (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   gsm_lib_module (new commits)

    no changes added to commit (use "git add" and/or "git commit -a")

I'll spare you the rest of the commands to replicate the whole example since
they are the same. Note that we have just achieved our goal, a ``git status``
command doesn't show any other changes than the submodule change, so we can't
propagate publicly any incorrect submodule URL. Instead of touching
``.gitmodules`` we did change the ``.git/config`` file to make it point to our
local file path.  After that, we removed both the module directory and its
cached version inside ``.git/modules``. Removing the cache is crucial,
otherwise the next submodule commands (``init`` and ``update``) would use this
cache, which itself points to the online URL and does not contain changes we
recently made offline. By deleting the cached module we force git to fetch it
from our local path. This method is ickier because we have to touch more files
and directories internal to ``.git``, but on the other hand we can replace a
reference URL with whatever we want and not worry about messing up other
people's repositories with careless changes.


Conclusions and relative paths FTW!
-----------------------------------

Both of these ways to replace the source of a submodule work for you locally.
If somebody deleted a repository used as a submodule somewhere else, you would
use the first method (changing ``.gitmodules``) so that everybody else can have
an updated version pointing to some new URL. But if you have to work with some
repository and the network is bad, or there are firewall rules preventing the
connection, maybe copying data through USBs and using the second method to
refer to a local repository can save the day.

.. raw:: html

    <center><a href="http://www.idol-grapher.com/1780"
        ><img src="../../../i/hopefull_yerin.jpg"
        alt="I dream of a day when git will be user friendly, will I be alive to see it myself?"
        style="width:100%;max-width:600px" align="center"
        hspace="8pt" vspace="8pt"></a></center>

While researching the commands and looking at how other people went around
tweaking their repositories I found a `very interesting piece about using
relative paths instead of full paths for submodules
<http://blog.tremily.us/posts/Relative_submodules/>`_. The only practical
difference for the previous examples would be the way to acquire the external
submodule using a relative path, which has to be done **after** we specify the
remote origin::

    [~]$ cd /tmp

    [/tmp]$ mkdir gsm_miner_relative

    [/tmp]$ cd gsm_miner_relative

    [/tmp/gsm_miner_relative]$ vim .gitignore

    [/tmp/gsm_miner_relative]$ git init
    Initialized empty Git repository in /private/tmp/gsm_miner_relative/.git/

    [/tmp/gsm_miner_relative(master)]$ git add .gitignore

    [/tmp/gsm_miner_relative(master)]$ git commit -av -m "Starting repository."
    [master (root-commit) 826cac6] Starting repository.
     1 file changed, 3 insertions(+)
     create mode 100644 .gitignore

    [/tmp/gsm_miner_relative(master)]$ git remote add origin git@gitlab.com:gradha/gsm_miner_relative.git

    [/tmp/gsm_miner_relative(master)]$ git submodule add ../gsm_lib_module
    Cloning into '/private/tmp/gsm_miner_relative/gsm_lib_module'...
    remote: Enumerating objects: 10, done.
    remote: Counting objects: 100% (10/10), done.
    remote: Compressing objects: 100% (7/7), done.
    remote: Total 10 (delta 2), reused 0 (delta 0)
    Receiving objects: 100% (10/10), done.
    Resolving deltas: 100% (2/2), done.

    [/tmp/gsm_miner_relative(master)]$ git commit -av -m "Using relative paths FTW"
    [master 3e1d047] Using relative paths FTW
     2 files changed, 4 insertions(+)
     create mode 100644 .gitmodules
     create mode 160000 gsm_lib_module

    [/tmp/gsm_miner_relative(master)]$ git push --set-upstream origin master
    Counting objects: 6, done.
    Delta compression using up to 8 threads.
    Compressing objects: 100% (4/4), done.
    Writing objects: 100% (6/6), 600 bytes | 600.00 KiB/s, done.
    Total 6 (delta 0), reused 0 (delta 0)
    To gitlab.com:gradha/gsm_miner_relative.git
     * [new branch]      master -> master
    Branch 'master' set up to track remote branch 'master' from 'origin'.

Once the origin is set as remote, even before pushing changes, the submodule
command works with the relative URL specification. Another cool feature `as the
source article states <http://blog.tremily.us/posts/Relative_submodules/>`_ is
that you don't have to worry about adding the submodule using a specific
protocol. Usually people *mess* things by using ssh instead of http in their
submodule absolute URL.  Everything works **for them**, but won't for others,
since they don't have write access to those repositories. This is also the
mentioned drawback in the article: if you fork a repository you need to fork
the submodules too. Or you can use the lessons learned here about replacing the
URLs of submodules to checkout just one module and make others point to online
public URLs instead of relative paths. But if you **can** fork a project, why
wouldn't you be able to fork its relative submodules?

In any case I like the idea of relative paths, I'll play with it in future
projects and see how it goes.

::
    $ nimble search ouroboros
          Error No package found.

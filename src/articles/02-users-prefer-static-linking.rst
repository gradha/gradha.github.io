---
title: Users prefer static linking
pubdate: 2013-08-03 13:31
moddate: 2016-12-26 23:44
tags: nim, static linking, user experience
---

Users prefer static linking
===========================

What is static linking
----------------------

**UPDATE**: Maybe static linking `is not really what the world needs
<../../2016/12/static-vs-dynamic-linking-is-the-wrong-discussion.html>`_.

Users prefer static linking. That is, if software users would
actually know what static linking is. Most users don't know anything
about software, how it is built, or how much time you pour into it,
but they know one thing: if it works, they expect it to keep working.

That's where the static linking is important. When a program is
compiled a *binary* is generated. The binary can have dynamic
dependencies, which means that it relies on external code that is
loaded every time the binary is loaded into memory to be executed.
On the other hand, a statically linked binary will *copy* all (or
some) of the external code it requires into the final binary itself.

The advantage of static linking is that you can copy the binary to
another system and it will keep running, something which may not
happen if the other system environment doesn't also have the same
external library installed. The cost to pay for this is increased
binary size, and there are also other drawbacks like the operating
system not being able to share the library between processes and
having duplicate instances of the same code in memory during
execution.

Mainstream consumer operating systems (Windows, Linux, OS X) provide
a big set of shared libraries, allowing programmers to not have to
care distributing their own copy with the program. But that soon
started to be a problem: different versions of each operating system
and/or library could be problematic for the programs. This is usually
known as `DLL Hell <https://en.wikipedia.org/wiki/DLL_Hell>`_, where
installation of program A on the end user machine brings in version
1 of a shared library, and installation of program B brings in an
incompatible version 2 of that same shared library.

Due to poor DLL versioning or programmer carelessness the end user
system becomes unstable. The best is when it actually crashes,
because end users *notice* there is something wrong. The problem
is when the programs don't crash immediately, they may crash later,
at random or specific times, or behave in not completely correct
behaviour, but not exactly right.

Nowadays even bigger culprits of dynamic linking are dynamic or
interpreted languages. Instead of producing compiled code, interpreted
languages like `Python <http://www.python.org>`_ or `Ruby
<http://www.ruby-lang.org>`_ are transformed into machine instructions
each time they are run. Now they don't only depend on the availability
of the dynamic libraries they require, they also depend on the
version of the interpreter. If you try to run a script written for
say Python 2.5, it won't work on Python 3 because of language
incompatibilities. This ends up creating a divide between programmers
and affects end users too.

If you thought your problems are only here, don't look at operating
system upgrades, the main reason people are *scared to death* to
upgrade their system.  If you know of a computer end user who is
not scared to death of upgrades it is only because he hasn't suffered
the experience of *upgrading* the machine to only find out (sometimes
weeks later) that a critical program stopped working because it is
incompatible with the new version of the operating system. This
causes pain, gnashing of teeth and hatred towards computers and/or
programmers.


Levels of portability
---------------------

The situations explained above don't actually relate all to static
linking, or can't be applied at all, since there is no concept of
static linking for interpreted languages. So maybe at this point
we should rephrase the term of static linking for the end user as
a general problem of portability. We also need to consider different
levels of portability, for instance:

* The user installed some software, and it works fine. The operating
  systems has the feature of multiple users and only the user who
  installed the software can run the program despite it being
  accessible to other users. Maybe the problem is the installation
  copied critical files to the user's private directories which are
  not available to the other users.

* The user copies the program to another machine, apparently using
  the same operating system version. However, it won't run at all.
  Maybe the *major* operating system version is the same, but
  sometimes operating systems have different minor versions, maybe
  one was upgraded to the latest security patch and this breaks the
  program's behaviour.

* The user copies the program to another machine or upgrades the
  operating system. The program won't run at all, sometimes without
  giving any useful explanation.

* The user wants to run the software in a cybercafe, or is otherwise
  somewhere else on lent hardware. The user copies all program files
  to an USB stick, but surprisingly it doesn't run there.  Why?
  Even though there are projects to create `portable versions of
  applications <http://portableapps.com>`_ most programs don't
  expect to be run in such a fashion. Also, even if your spreadsheet
  software runs you don't want it to leave your bank details on a
  public computer at a cybercafe just because it thought for
  convenience that you will always have a private user data folder
  on the hard drive.

More different situations could be described, but one thing to note
is a program can fall into several of these situations at the same
time, and it mostly depends on two factors: technologies used and
programmer's interest in portability. Yes, portability is a feature
decided by programmers upon their end users. And unfortunately few
people care.


The solution
------------

The solution for portability is simple: you copy, bundle, or embed
whatever your program needs into your binary. For instance, Windows
programs may want to avoid writing into the registry so that copying
the folder where the software was installed is enough to copy
everything to a different machine and run it there.

On OS X this is abstracted to the user through the use of `application
bundles <https://en.wikipedia.org/wiki/Application_bundle>`_. These
are normal directories with a special structure the operating system
recognizes and treats uniformly as a single entity. The Finder on
OS X won't allow you to copy only part of the bundle's directory
somewhere else, and should it fail, it will delete the incomplete
bundle. Even if it is left there broken, the system wont run it and
will likely draw a translucent stop sign on its icon.

Linux… Linux users usually don't care. They brag about sophisticate
software management programs (oh, the meta) and tell end users they
are crazy because they don't want to learn how to use it or search
the net for solutions to a dependency, which can be solved, but
requires some obscure option/command line switch to work.

Mobile software stores have adopted the bundle paradigm: they include
everything required to run except the basic libraries provided by
the system which are (in theory) guaranteed to be the same on all
future OS versions. This allows for example software written for
the iPhone 3G to still run on the iPhone 5 without updates.

Note that bundling everything together still requires the program
to be *aware* of being run in this kind of environment. Fortunately
for end users the strict rules for iOS and Android are creating
more awareness towards the usual *sandboxes*, so much in fact that
OS X desktop users already have an equivalent app store with
*sandboxing* and Windows seems to be following suit.


Software proud to be portable
-----------------------------

There are not many developer oriented tools which are written with
portability in mind. The authors of `Sqlite <https://sqlite.org>`_
and `Fossil <http://fossil-scm.org/index.html/doc/trunk/www/index.wiki>`_
are one exceptional case. They aim for the highest level of
portability: a single binary which can be copied anywhere and it
works.

Nothing particularly new, but worth of appraise. Long forgotten
MSDOS programmers also developed funny *tricks* to provide single
binary portability (remember the times when having a hard disk was
rare?). The most notable one was appending additional resources to
the binary itself. The operating system would load the whole binary
into memory but will ignore the extraneous trailing data. Instead,
the application could read it to avoid littering the disk with extra
files.

Surprisingly this technique still works on today's systems. Even
more, programs like `UPX <http://upx.sourceforge.net>`_ which
compress binaries also know how to handle trailing data and are
known to work with binary appending tools, like the one provided
by the `C game programming library Allegro
<http://alleg.sourceforge.net>`_.

However, USB level portability is hard to find for most programming
languages compilers and interpreters. The closest may be the `Nim
programming language <http://nim-lang.org>`_, since it compiles
everything into a single Nim binary, which can be run everywhere.

The problem is, will it work? Compiling most source code will require
using modules from the standard library. But where are these?
Scattered somewhere else. So while it is true that Nim produces
a statically linked contained binary, it is effectively not portable
if for 99% of its usage it depends on external files. Another
example, you could be using different Nim compiler versions for
testing, and one works with a specific version of the standard
library, but a previous compiled binary won't work due to changes
in the language. This requires you to maintain different versions
of the standard library module tree, and make sure to point to the
correct one with each binary if you actually need to switch.

Certainly developers are special *power* users, and they are expected
to know how to install tool dependencies, search the net for obscure
incantations of poorly known commands, and are usually resilient
to repeated failure, with a special knack for banging their head
against a wall until they figure out what is wrong.

However, couldn't we all be nice and provide 100% portable tools
too? Why do we provide portability to end users yet again and again
we torture ourselves with DLL Hell? Do we enjoy it so much?

**UPDATE**: Maybe static linking `is not really what the world needs
<../../2016/12/static-vs-dynamic-linking-is-the-wrong-discussion.html>`_.

```nimrod
$ nim c forum.nim
$ ./forum
could not load: libcairo.dylib
```

---
title: Goodbye Nim, and good luck
pubDate: 2015-02-04 23:23
modDate: 2015-02-04 23:23
tags: languages, programming, nim, nimrod
---

Goodbye Nim, and good luck
==========================

In 2012 I learned about the Nimrod programming language, now renamed to `Nim
<http://nim-lang.org>`_. I found Nim because I was looking for higher level
programming languages which would compile to C, so I could use the generated
code everywhere. Like Java. And I enjoyed learning it.

I did spend a big chunk of time exploring the possibilities of applying Nim to
my day job, which is writing mobile apps. I wrote first `Seohtracker for iOS
<https://github.com/gradha/seohtracker-ios>`_ and later `Seohtracker for OSX
<https://github.com/gradha/seohtracker-mac>`_ as proof of code reuse.
Unfortunately I started to `find troubles
<../../2014/03/nimrod-for-cross-platform-software.html>`_ with the language
implementation. I also slowly realized that no matter how fantastic the
language implementation could be, Nim is designed to use soft realtime GC on
thread local heaps. This means that a thread cannot touch the memory of another
thread. If you add to this the necessary level of indirection of calling Nim
from a different programming language (or vice versa), the amount of barriers
to jump over to do what in other **unsafe** languages is just accessing a
variable starts to pile up.

At that point that I realized that from all the amount of software written in
Nim there were two kinds of software barely explored: GUIs and multithreading.
It's not difficult to `read in the Nim forums <http://forum.nim-lang.org>`_ how
people are using one or the other, either using GTK for things like `Aporia
<https://github.com/nim-lang/Aporia>`_ or creating `raytracers which scale up
in performance <http://forum.nim-lang.org/t/167>`_. But they are mostly single
threaded with one or two callbacks here, or they don't share any state. It's
the intersection of both which is lacking. And this intersection seems to
requires you to ignore all type and memory safety to make your own globals or
shared memory for communicating. I'd love to be proved wrong, but all the
questions I've found from other programmers attempting to do this are met with
vague "maybe" answers or suggestions which read more like workarounds an
invisible elephant.

People are finding the GC is not really wanted for certain scenarios, and are
starting to wish for at least a minimal standard library which uses manual
memory handling so that Nim can be used without that wonderful GC. Would this
kind of project repeat history like D's Phobos vs Tango but with an even
smaller community? I've toyed with this idea too, but there is no point in
pushing something towards something it will never be. Of course I'll keep using
Nim as I'm using now, to replace most of my toy Python code. But I can't see
myself using Nim for anything serious in the future when so many alternatives
are already delivering.

Since I started this blog with the purpose of writing articles about Nim and
taking potshots at other programming languages from the safety of a random
troll, I don't think I'll write anything more here. All the nim software I've
created also has an expiration date: Nim 1.0. I've already spent the last weeks
cleaning and upgrading the code I had working with 0.9.6 to work with 0.10.2,
but there are still many deprecated warnings left which will make it again
impossible to compile with 1.0, whenever it happens.

At least I'll leave those repositories up in case somebody wants to pick them
up. Good luck, Nim programmers. I'll keep watching from a distance.

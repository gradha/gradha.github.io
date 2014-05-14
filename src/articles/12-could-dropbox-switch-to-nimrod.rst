---
title: Could Dropbox switch to Nimrod?
pubDate: 2014-04-04 20:12
modDate: 2014-04-04 20:19
tags: programming,languages,python,nimrod,dropbox
---

Could Dropbox switch to Nimrod?
===============================

More interesting changes have been announced in the language arena `just a few
days after I wrote my opinion on Facebook announcing the Hack programming
language
<../03/the-sweet-trap-of-dynamic-languages-and-development-time.html>`_. So
rather than a longish useless rant, this is more like an appendix to that
article. The interesting things announced were:

* `Microsoft announces .NET Native
  <http://blogs.msdn.com/b/dotnet/archive/2014/04/02/announcing-net-native-preview.aspx>`_,
  which essentially compiles C# with their C++ backend.
* `Dropbox announces Pyston, a JIT-based Python implementation
  <https://tech.dropbox.com/2014/04/introducing-pyston-an-upcoming-jit-based-python-implementation/>`_. 

Both of these announces highlight that anything dynamic has trouble in the
*real world* out there. Scaling servers is cool, but not having to throw
millions at hardware and still meet your goals is even better. The perspective
for both companies is different, though. Microsoft is likely targeting
*embedded* developers, aka, writing C# code for Windows Phone or Xbox and keep
60 frames per second while consuming the minimum possible amount of resources.
On the other hand, the Dropbox announcement is particularly interesting:

    *"After some abandoned experiments with static compilation, we looked
    around and saw how successfully JIT techniques are being applied in the
    JavaScript space[...]"*

This is really intriguing. Static compilation tends to solve the performance
problems, but might introduce other development downsides. Other commenters of
the blog post itself mention several alternatives to statically compiling
Python, as in *"did you try this? why isn't it good?"*.  Many of them have
performance limits imposed by the language: you either can't optimize a dynamic
language  *all the way* compared to other statically compiled languages, or you
have to restrict yourself to a subset of Python or modify it, which depending
on how you do you may need to throw away your existing code.

But instead of going the way of Facebook and adding optional static typing they
are instead keeping the dynamic nature of the language and instead looking at
providing *type speculation*.  Based on the blog post description of *type
speculation*, you can likely understand more by watching the Strange Loop talk
`Why Ruby Isn't Slow <http://www.infoq.com/presentations/ruby-performance>`_ by
`Alex Gaynor <http://alexgaynor.net>`_. Really nice talk, it mentions the
`horrible RPython implementation <https://code.google.com/p/rpython/>`_ (Alex's
words, not mine) which allows defining these *probabilistic* hints for the
optimizer, like: *"well, this property is now a string, and it is 99% likely
going to be a string all the time, so maybe you should actually ignore type
checks and indirections and stuff and directly access it like a string"*. If
you are interested in dynamic languages evolution and optimization, you can
also watch `Fast and Dynamic
<http://www.infoq.com/presentations/dynamic-performance>`_ by `Maxime
Chevalier-Boisvert <https://pointersgonewild.wordpress.com>`_.

Of course I would propose using the `Nimrod programming language
<http://nimrod-lang.org>`_ to any Python programmer looking for a more
performant, saner language. But Dropbox didn't start yesterday to write code,
and surely they have tons of code. They must have considered that keeping with
Python and implementing a faster interpreter is more cost effective than
switching to a different language. Don't think just in terms of rewriting code
but also in retraining their workforce or hiring people with practical previous
experience.

So unfortunately Nimrod is not a viable option for companies like Dropbox. Not
Nimrod, not any other language. Just like I concluded in `my previous blog post
<../03/the-sweet-trap-of-dynamic-languages-and-development-time.html>`_, the
Dropbox team has *succeeded* with Python, and now their success is *killing*
them.  Developing a faster interpreter for Python is not a trivial matter, or
it would have already been done, so one can only hope that the Dropbox
developers **really** know what they are doing starting `Pyston
<https://github.com/dropbox/pyston>`_. Or maybe they have tons of money to
burn, which offsets nearly any worries a normal programmer has about decision
failures.

::
$ nimrod c -r bank_savings.nim
Traceback (most recent call last)
bank_savings.nim(135)    bank_savings
bank_savings.nim(107)    end_of_month
bank_savings.nim(79)     pay_rent
SIGSEGV: Illegal storage access. (Attempt to read from nil?)
Error: execution of an external program failed

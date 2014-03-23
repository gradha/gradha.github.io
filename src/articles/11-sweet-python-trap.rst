---
title: The sweet trap of dynamic languages and development time
date: 2014-03-23 07:26
tags: programming,languages,python
---

The sweet trap of dynamic languages and development time
========================================================

Recently `Facebook announced Hack, a new programming language for HHVM
<https://code.facebook.com/posts/264544830379293/hack-a-new-programming-language-for-hhvm>`_.
You can read the post yourself, but the summary is they are adding optional
static typing to the `PHP <http://php.net/>`_ language, transforming it in the
process. The concept is not exactly new, if you like the `Python programming
language <https://www.python.org>`_ but require more performance, you can
migrate your code to `Cython <http://cython.org>`_. In both Hack and Cython,
final performance is important. If your php-like web framework is 100 times
faster than `Ruby on rails <http://rubyonrails.org>`_, it means that when you
want to scale you need 1/100th of the hardware resources. Anything multiplied
by 100 in the scale of Facebook is a lot of money. It's a deal even if it was
only 10 times better.

.. raw:: html

    <img
        src="../../../i/python_trap.jpg"
        alt="Admiral Ackbar knows where this is going"
        style="width:100%;max-width:600px" align="right"
        width="600" height="750"
        hspace="8pt" vspace="8pt">

I know Python very well, and I know Cython as well because I searched for it
when I realised how piss poor Python is in terms of computation. If you read
Cython's submitted claims of *"my program went faster by 100 times!"*, well,
they might be true. In my particular case I was processing graphic images with
the `Python Imaging Library <http://www.pythonware.com/products/pil/>`_ and
required pixel buffer access. Switching to Cython made my little script change
from taking 15 minutes to 30 seconds just by virtue of adding a few type
definitions here and there.

At that point I really felt back stabbed. I really liked the language: it was
easy to write, fast to develop, source code looked very good. But it failed to
deliver. With time, maintaining larger Python source code bases I realized
dynamic languages have other traps, like refactoring time and necessary unit
testing afterwards, higher quality requirements for documentation because the
language interface tells you nothing (oh, give me an integer, or a string, or
whatever you want, I'll just crash and burn later!).

In a statically compiled language if you change the type of an object you get a
horrible cascade of never ending errors telling all the places where things
break. In a dynamic language, may God have mercy on your soul because you need
to track all those places yourself, and usually search and replace does not
find everything and/or gives false positives). And don't forget then to test if
you actually changed the correct bits.


The trap
========

Using a dynamic language is like `the dark side of the force
<http://starwars.wikia.com/wiki/Dark_side_of_the_Force>`_. Always luring,
always tempting. It's easy! It's fast! It's simple! But when your software
starts to grow, and you start adding new people to a team, the dark side
crumbles. Suddenly you start devoting an increasingly larger percentage of time
to unit testing and fixing your own mistakes. Mistakes which could have been
caught if the language didn't make them so easy to do. Mistakes which happen
because the API you wrote, you wrote it *for yourself*, and when somebody else
looks at it, he may have a different opinion on how to use it. Did you write
proper documentation? Did you write unit testing for all logic paths? Did you
check all parameter inputs to see if they are the correct type?

Much of this is done by a statically compiled language compiler, so instead of
unit testing if you are passing a string where you expect there to be an
integer, you can unit test real actions done by the user. It's no coincidence
that if you look at programming languages, the more unit testing a programming
community does (and even prides itself for doing it!) the worse it is at being
statically analyzed. This kind of unit testing is really a band aid for an ill
language you should not be using. Why require programmers do trivial unit
testing when the machine could do it for you?

But if you go by today's gold standard of general purpose statically compiled
language (aka C++), you can find `enough dissent
<http://yosefk.com/c++fqa/defective.html>`_, and rightly so. Languages like
Java or C# improve over C++, but generally people use them because there
doesn't seem to be something else better available, rather than because they
like the language. There also appears to be a `feeling of superiority among
people using C++ <http://www.yosefk.com/blog/c11-fqa-anyone.html>`_ which may
partly explain why C++ programmers are reluctant to criticise their own
language.

Users of Python and Ruby will quickly point out that just setting up most
statically compiled language to produce a Hello World example is painful. Well,
maybe we shouldn't be measuring the usefulness of a programming language by how
fast we can write useless bits of software. And that's what companies like
Facebook are doing. The programming language is useless information to an end
user, they only care about the final result. And if their web page takes 40
seconds to load, they will likely go somewhere else. Dynamic languages are not
delivering to Facebook.


The search for a middle ground
==============================

Languages like Hack and Cython are a middle ground compromise, and they have
their niche. Can't we do better if we start from scratch? That's what the
`Nimrod programming language <http://nimrod-lang.org>`_ does. 


**Disclaimer**: Even before reaching release 1.0 Nimrod already shows some
little mistakes which confuse new users because nothing is perfect and
everything evolves. The current convention for procs is to be named
initSomething if they initialise an object on the stack, and newSomething if
they initialise an object on the heap. The ``newStringOfCap`` proc does **not**
return a reference to a string type but returns the string directly.

I wonder then, if Nimrod is so good and has *the power of staticness* by its
side, couldn't you write a static analyzer to replace the old usage by the new
one? Time will see.

convention of the standard library. When you allocate something 




.. raw:: html
    </td></tr></table></small>

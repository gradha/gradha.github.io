---
title: Whitespace goto fail
pubDate: 2015-04-18 00:37
modDate: 2015-04-18 00:37
tags: languages, programming, java, design
---

Whitespace goto fail
====================

Recently I fixed the following interesting code in an Android application I
wrote. According to source control it had *survived* undetected for about eight
months until it manifested as a runtime crash:

```java
…
if (null == savedInstanceState) {
        if (null != this.item && null != this.item.url)
                set_sparta_kook(this.item.url);
                visible_web().loadUrl(this.item.url);
} else {
        visible_web().restoreState(savedInstanceState);
…
```

The culprit of the bug was of course the **addition** of the `set_sparta_kook()
<https://www.google.es/search?q=sparta+kook&tbm=isch>`_ call to the previously
existing lines of perfectly working code. Can you see now what the problem was?
Yes, lack of beloved braces. Here's the fixed code:

```java
…
if (null == savedInstanceState) {
        if (null != this.item && null != this.item.url) {
                set_sparta_kook(this.item.url);
                visible_web().loadUrl(this.item.url);
        }
} else {
        visible_web().restoreState(savedInstanceState);
…
```

Welcome to a variant of `goto fail
<http://arstechnica.com/security/2014/02/extremely-critical-crypto-flaw-in-ios-may-also-affect-fully-patched-macs/>`_.
It's not the first time I've written such bugs, but they don't come often. I
don't think I've made more than five in my whole life. Still, far too many for
my taste.

What was particularly interesting is not how I could write this (distractions
or tiredness can explain pretty much everything) but how I **could not fix**
this immediately despite reviewing it carefully. Let me explain: it took me
several minutes of looking at the source code, actually not figuring out what
was happening and then using a debugger to step through the lines and think
"*wait a second, why is the program execution running through*
``visible_web().loadUrl(this.item.url);`` *in first place when the condition
should be preventing that?*".

I'm so used by now to reading properly indented code that no matter how many
times I looked at this code I would not catch the missing braces. The typical
*patch* to such problems is of course a coding convention. You can see this
reflected as one of the promoted comments in `the article I linked to
<http://arstechnica.com/security/2014/02/extremely-critical-crypto-flaw-in-ios-may-also-affect-fully-patched-macs/>`_
earlier:

    **a_v_s** Ars Scholae Palatinae

    This is one of the reasons I always use {} even with single statement conditionals.

    …

True. But you know what else could have prevented this bug without requiring a
horrendous coding convention difficult to validate/enforce? Having a language
which doesn't use braces and instead uses whitespace indentation like `Eero
<http://eerolanguage.org>`_ or `Nim <http://nim-lang.org>`_ do.

.. raw:: html

    <center>
    <a href="http://dijkcrayon.tistory.com/363"><img
        src="../../../i/whitespace_reactions.jpg"
        alt="At first I was like…"
        style="width:100%;max-width:750px" align="center"
        hspace="8pt" vspace="8pt"></a>
    </center>


Syntax anachronisms
-------------------

Braces, or just about any other start/end block delimiter, are an anachronism
and only add clutter and useless bike shedding. The key to understanding this
is how I wasn't able to understand the actual meaning of the code which is
pretty obvious to the compiler. After years developing, braces (or whatever you
have in most of the programming languages designed without taste) are simply
noise.  They don't add any value to the source code. They are just a tedious
necessity for the compiler, because frankly, humans **won't use them**. If you
remember the first time you drove a car vs how you drive it several years later
the difference is the same: the first time you pay attention to everything.
Not only everything is new (oh, a vertical sign! Hi!) but you actually
paid extreme attention because a mistake could lead to a terrible error. Years
later you can concentrate only on the important things and don't freak out at
every little detail you can see behind the driving wheel.

Unfortunately most people defending programming languages with braces don't get
it and instead provide lame arguments. My favourite lame contra argument is
that you can't easily copy/paste code between windows, web browsers, or
Notepad, I guess, because the indentation will be messed up. It highly amuses
me how often this argument comes up in religious battles because the people
backing it must be using programming tools from the past, where automatic
indentation is such an impossible technical feat. Or maybe programmers able to
**only** copy/paste code really need these crutches, since they will leave the
source code in a state which compiles but is unreadable to anybody who is not a
compiler.

This argument also forgets another simple fact: it's highly unlikely that
copying and pasting code somewhere else won't require changes **anyway**. Maybe
you will need to change variable names, or remove some lines you don't need. Or
if you actually care about source code, you **will** indent the code to
**your** coding convention, modify the symbols to be CamelCase or snake_case,
change private/instance variables to have a different prefix (``m``, ``_``,
``m_``, ``F``, …), etc. Whatever lines of code go into any of my source files,
even those which come from my own projects, have to pass an initial visual
style inspection. And in the inspection I performed I simply forgot about the
braces. Why? Because they are useless to human eyes, completely discard able.

You could really hear my facepalm in the whole building when I read on a forum
discussion that somebody preferred programming languages with braces because
their blog system screws up formatting for literal blocks. Seriously, if you
come up with such quality arguments you should be neutered to prevent lowering
humanity's intelligence average with your offspring (and the developers of your
blog tools too).


Conclusion
----------

Language designers should know better that adding braces for code blocks that
are going to be indented anyway due to code conventions is detrimental because
they distract programmers with a needless task, but we can still see new
languages enforcing braces (like `Kotlin <http://kotlinlang.org>`_ or `Swift
<https://developer.apple.com/swift/>`_). I suspect the real reason why these
new languages keep them is to appease the hordes of users of the language they
try to replace. It is such a shame we have so much trouble accepting change,
even when it is for the better.

Remember, the argument for *having* braces is that you are `such a horrible
person <https://www.youtube.com/watch?v=Yy3dIicSI_0>`_ that you will never
indent or care about the style of your code and therefore prefer to have a
crutch that frees you from having taste, and lets you dump foreign code into
your own to leave it however it falls.


.. raw:: html

    <center>
    <a href="http://xkcd.com/1513/"><img
        src="../../../i/xkcd_code_quality.png"
        alt="At first I was like…"
        style="width:100%;max-width:740px" align="center"
        hspace="8pt" vspace="8pt"></a>
    </center>

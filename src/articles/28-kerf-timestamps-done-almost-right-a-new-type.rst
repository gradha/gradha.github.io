---
title: Kerf timestamps done almost right: a new type?
pubdate: 2016-02-29 22:41
moddate: 2016-02-29 22:41
tags: design, nim, java, cpp, languages, kerf, programming, swift
---

Kerf timestamps done almost right: a new type?
==============================================

Intro
-----

Scott Locklin writes in his `Timestamps done right article
<https://scottlocklin.wordpress.com/2016/01/19/timestamps-done-right/>`_ (`also
crossposted to the Kerf blog
<https://getkerf.wordpress.com/2016/01/19/timestamps-done-right/>`_) about how
timestamps are implemented in `Kerf, a comercial closed source columnar tick
database and time-series language for Linux/OSX/BSD/iOS/Android
<https://github.com/kevinlawler/kerf>`_.  After an emotional fallacy, which
doesn't have anything to do with language design, Scott explains the timestamp
features of Kerf via several examples comparing them mostly to the `R
programming language <https://www.r-project.org>`_.  The article finishes with
lessons for future language authors which rather than followed should be
avoided. In order to demonstrate this, Kerf's *precious* timestamp features
will be implemented in several programming languages: Nim, C++, Swift, and even
Java (`source available for all of them at GitHub
<https://github.com/gradha/kerf_timestamps_done_almost_right>`_).

After this exploration it should be clear to you that implementing timestamps
right in the core of the language is more of a pet feature than a logical
reasonable design decision for a generic language. On the other hand it's
perfectly fine for a closed source language sold to a niche in order to attract
those wallet heavy paying users. Scott's article also highlights being able to
write SQL and JSON-like syntax in Kerf.  These articles won't go (much) into
those features which have their own merit and are completely separate from
timestamps being a core language type.

.. raw:: html

    <br clear="right"><center>
    <a href="http://www.castlegeekskull.com/2011/09/list-of-star-wars-episode-iv-new-hope.html"><img
        src="../../../i/kerf_language_wars.jpg"
        alt="Language wars, timestamps: a new hope"
        style="width:100%;max-width:750px" align="center"
        hspace="8pt" vspace="8pt"></a>
    </center>


The fallacy
-----------

The case presented to introduce timestamps being a core type is so ridiculous
that I can't resist quoting it full (the bold highlighting is mine):

.. raw:: html
    <blockquote><em>

Consider the case where you have a bunch of 5 minute power meter readings
(say, from a factory) with timestamps. You’re probably storing your data in
a database somewhere, because it won’t fit into memory in R. Every time you
query your data for a useful chunk, you have to parse the stamps in the
chunk into a useful type; timeDate in the case of R. Because the guys who
wrote R didn’t think to include a useful timestamp data type, the DB
package doesn’t know about timeDate (it is an add on package), and so each
timestamp for each query has to be parsed. This seems trivial, but a
machine learning gizmo I built was entirely performance bound by this
process. **Instead of parsing the timestamps once in an efficient way into
the database, and passing the timestamp type around as if it were an int or
a float, you end up parsing them every time you run the forecast, and in a
fairly inefficient way**. I don’t know of any programming languages other
than Kerf which get this right. I mean, **just try it in Java**.

.. raw:: html
    </em></blockquote>

Nothing triggers so much my *bullshit-o-meter* as the random jab at Java out of
nowhere. The Java language has many troubles of its own, and I am also ready to
jump in the pitchfork line along with Scott, who clearly `has seen Java things
enough to freak him out <https://www.youtube.com/watch?v=ZTzA_xesrL8>`_, but
reading a timestamp from a database column and storing it somewhere as a long
type is not a problem (if you can stomach the lack of types, of course).
However I'll leave that for a later time, in the meantime let's try to dissect
the quote because the hypothetical problem is too vague.  There are several
possible issues I can think of:

1. Somebody sucks at database design and decided to store timestamps as `ISO
   strings <https://en.wikipedia.org/wiki/ISO_8601>`_ (or something scarier)
   into the database and this is somehow a problem of the programming language
   because you have to revert the damage during reads.
2. R's timeDate library was designed for calendar conversions rather than raw
   timestamp efficiency and instead of passing an integer like type around they
   use a heavier object structure requiring some expensive calendar calculation
   and extra memory allocations just to *read* a row from the database.
3. The database stored somewhere for this operation doesn't fit in memory, but
   neither does it fit on any of your hard drives, or maybe it contains
   protected sensitive data, so you can't make a copy where you transform the
   problematic data into something optimal for your use case.
4. The database is *live* and you can't write a daemon which listens to
   insertions and does the heavy massaging storing the result somewhere else
   (could be a as simple as a database trigger).
5. All of the above.

None of the issues here feel to me like a problem with R (I hope, since I know
nothing about R, maybe it really sucks?) and more with other factors outside of
the language domain and into the practical/political domain.

In any case we get a hint of the *expected correct* way of dealing with
timestamps in the fragment "*..passing the timestamp type around as if it were
an int or a float..*". What is suggested here is that timestamps should be
stored in the database as plain 32/64 bit integer types, and they should also
be stored as such in memory, as plain value types which are compact,
performant, and avoid any heavy parsing or memory allocations during
serialization.  The following articles will implement such a timestamp type in
generic programming languages, thus proving that a language with a good base
foundation allowing custom extension is much more important than a language
with timestamps as a core type, because you can never please everybody, and
just like Scott dislikes R's timeDate you can surely find somebody on earth who
thinks storing and keeping dates as raw timestamps sucks (for their use case).


Analyzing Kerf's timestamp features
-----------------------------------

.. raw:: html
    <a href="http://www.all-idol.com/1609"><img
        src="../../../i/kerf_analwhat.jpg"
        alt="Analwhat?"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>

From the previous paragraphs we already know that one of the *gold standards*
of timestamps is to have a compact value type. We could use `libc's time()
function <http://linux.die.net/man/2/time>`_ to store the time as the number of
seconds since the Epoch. This would be stored as a 32bit integer value and we
would be done. Would we? Unfortunately not. If we store the number of seconds
as a plain integer we can do any number of atrocities to it, like adding apples
to it and dividing by the number of remaining honest politicians in the world:

```c
int the_current_time = time(0);
int apples_in_kitchen = 4;
int honest_politicians = 0;
printf("Welcome to the Kerf apocalypse.\n");
printf("Remaining seconds till enlightenment %d\n",
    (the_current_time + apples_in_kitchen) /
        honest_politicians);
```

Examples like these are very well known in programming circles, and the lack of
proper type checking is usually attributed to failures like the `Mars climate
orbiter crashing in 1999
<https://en.wikipedia.org/wiki/Mars_Climate_Orbiter#Cause_of_failure>`_ wasting
a lot of money, and proving that the reward for being an engineer is infinitely
small compared to the risk and eventual humiliation by the public if something
goes just a little bit wrong. In short, a function somewhere in the whole
software provided the value in a unit scale different to the one expected by
the caller. To prevent such programming mistakes and catch them at compilation
time we need languages which feature strong typing, and more importantly allow
us to define our own primitive value types which **disallow** being mixed with
others. For instance, we could tell the programming language that *this integer
right here* is *not really* a plain integer, but a *special* integer, and
therefore the compiler would disallow us to add apples to its value or divide
it by politicians.

With regards to storage size Kerf opts to store timestamps internally as UTC at
nanosecond granularity, so they are 64bit values. The `manual reference
<https://github.com/kevinlawler/kerf/tree/master/manual>`_ mentions
"*Timestamps are currently valid through 2262.04.11*". Some quick calculations in a Python interpreter session corroborate this:

```none
In : 2 ** 63 / (60 * 60 * 24 * 365 * 1000000000)
Out: 292L

In : 1970 + 292
Out: 2262
```

The first line tests that if we power 2 to 63 and divide it by the number of
nanoseconds in a year we get a range of 292 years. If we add that to the
typical Unix Epoch we get the 2262 year limit mentioned in the reference
manual.  So timestamps are signed 64 bit values, leaving 63 useful bits for the
range.  The Kerf examples also show that timestamps can have a differential
representation and a calendar representation. Since negative times make no
sense, it is possible that the highest bit is used to differentiate internally
between calendar and differential types. But we can use the type system to
*store* the difference.

Another feature we need to implement Kerf's timestamp type is nice syntax
sugar: operator overloading and custom literals. Here are some Kerf examples:

```none
KeRF> 2015.01.01 + 2m + 1d
  2015.03.02
KeRF> 2015.01.01 + 2m1d
  2015.03.02
KeRF> 2015.01.01 - 1h1i1s
  2014.12.31T22:58:59.000
```

There are more complex examples in the article and manual, but this is enough
to see that the custom literals allow users to instantiate months, minutes,
days, and other time units directly. The operator overloading allows us to
elegantly combine mathematical operations which make sense on the types.
Compared to the initial C `time() <http://linux.die.net/man/2/time>`_
example you can see in all lines that a calendar like timestamp is being added
to a time differential and it produces another calendar type.  Differential
values can be combined too. Most probably you won't be able to add apples (or
plain integers) to a timestamp, the language will prevent you from doing this.
Like magic.

Summary
-------

In order to implement Kerf timestamps we will need the following requirement
shopping list:

1. Value type semantics with strong typing to avoid mistakes.
2. Instancing types on the stack to avoid slow heap memory allocations and
   alleviate manual memory handling or garbage collector pressure.
3. Custom literals for easier construction of such types.
4. Operator overloading to implement all possible custom operations.

As mentioned earlier we will be doing this in Nim, C++, Swift and Java. So
fasten your seatbelts until we reach our conclusion. The only difference
between these implementations and Kerf's will be that I'm not going to
implement the whole precise time calculation operations because they are a
pain, and they are not necessary to prove that hard coding the timestamp into a
language is unneeded. Neither will I implement the full range of string format
parsing found in the Kerf manual. Hence the *almost* in the titles, don't
expect a `perfect bug-compatible clone
<http://code.google.com/p/android/issues/detail?id=13830>`_ of Kerf at the end.

And finally, I'm prone to mistakes, so don't laugh too hard if I end up adding
knifes to politicians by mistake…

::
    $ ./politicians_eating_timely_fruit.exe
    Welcome to the Kerf apocalypse.
    Floating point exception: 8

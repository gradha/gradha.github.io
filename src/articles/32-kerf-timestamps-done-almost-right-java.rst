---
title: Kerf timestamps done almost right: WTF… Java?
pubdate: 2016-03-06 23:53
moddate: 2016-03-06 23:53
tags: design, nim, java, cpp, languages, kerf, programming, swift
---

Kerf timestamps done almost right: WTF… Java?
=============================================

In the `first chapter of the series
<kerf-timestamps-done-almost-right-a-new-type.html>`_ we reached the conclusion
that to implement Kerf's timestamp types we need the following features from a
programming language:

1. Value type semantics with strong typing to avoid mistakes.
2. Instancing types on the stack to avoid slow heap memory allocations and
   alleviate manual memory handling or garbage collector pressure.
3. Custom literals for easier construction of such types.
4. Operator overloading to implement all possible custom operations.
5. Generics are not necessary but help with implementation.

.. raw:: html

    <table border="1" bgcolor="#cccccc"><tr><td style="vertical-align: middle;"
    ><b>META NAVIGATION START</b>
    <p>This is a really long article (<a
    href="http://www.amazon.com/Beginning-Programming-Java-Dummies-Barry/dp/1118407814"
    >Buy Java for Dummies!</a>) which has
    been split in different chapters because it is (<a
    href="http://www.amazon.com/Beginning-Programming-Java-Dummies-Barry/dp/1118407814"
    >Java for dummies on sale!</a>) unsuitable for today's average attention span
    and lets me
    maximize (<a href="http://www.amazon.com/Beginning-Programming-Java-Dummies-Barry/dp/1118407814"
    >Get Java for Dummies now!</a>) page ads.
    <p><b>META NAVIGATION END</b>
    </td><td nowrap>
    <ol>
    <li><a href="kerf-timestamps-done-almost-right-a-new-type.html">a new type?</a>
    <li><a href="kerf-timestamps-done-almost-right-nim.html">Nim</a>
    <li><a href="kerf-timestamps-done-almost-right-c-plus--plus-.html">C++</a>
    <li><a href="kerf-timestamps-done-almost-right-swift.html">Swift</a>
    <li>WTF… Java? <b>You are here!</b>
    <li><a href="kerf-timestamps-done-almost-right-conclusions.html">conclusions</a>
    </ol></td></tr></table>


`Java <https://en.wikipedia.org/wiki/Java_(programming_language)>`_ is a
general-purpose computer programming language that is concurrent, class-based,
object-oriented, and specifically designed to have as few implementation
dependencies as possible.  Java was originally designed for interactive
television, but it was too advanced for the digital cable television industry
at the time. There were five primary goals in the creation of the Java
language, and unfortunately none of them cared about extending the language
with custom types. This is what we actually get with Java:

1. Java has strong typing but value type semantics are limited to primitive
   types (immutable objects don't count, they are artificial).
2. Java doesn't allow instancing non native types on the stack. All user
   defined types have to be on the heap because they are classes.
3. Java doesn't have custom literals.
4. Java doesn't have operator overloading, that's obscene!
5. Generics are possible, but only for objects, which defeats all our purposes
   of having an efficient timestamp type like the one we want.

At least that was quick, wasn't it?


My problems with Java
---------------------

My employer pays me money to write Java code, and that makes me happy. I
couldn't care less what I'm programming with if I get money in exchange.
However, for personal projects you will never see me using Java. My main
problem with Java is that it stops pretending to be a tool and tries to be a
religion, the religion of Object Oriented Programming (OOP). According to
Wikipedia the first of the five primary goals in the creation of the Java
language was:

    It must be "simple, object-oriented, and familiar".

.. raw:: html

    <div style="float:right;margin:1px"
        ><a href="http://aaronsanimals.com/gifs/"><video
        autoplay muted loop
        style="width: 300px; height: 168px;"> <source
        src="../../../i/shitposting_time.mp4" type="video/mp4"
        />No silly animated videos, good for you!</video></a></div>


An oxymoron right from the beginning, object orientation is not simple when you
have to deal with `multiple inheritance
<http://stackoverflow.com/questions/225929/what-is-the-exact-problem-with-multiple-inheritance>`_.
Rather than perceiving that the `diamond problem
<https://en.wikipedia.org/wiki/Multiple_inheritance#The_diamond_problem>`_ is
one of the results of complexity, the decision was to sweep the problem under
the carpet by not allowing multiple inheritance and looking in another
direction. Only you still have the problem that `everything has to be a fucking
object
<http://programmingisterrible.com/post/40453884799/what-language-should-i-learn-first>`_.
But then no, primitive types are not an object. So which is which? And there
starts the automatic boxing and unboxing of objects, and the feeling of not
grasping something when beginners see there is a ``long`` and there is a
``Long``, and they don't mean the same thing, one can even be ``null``!

At some point Java *dropped the ball* for improving. That happens when the
people in charge of improving it say something like "*Fuck it, let's not
improve this any more (because it is too damn hard to do properly) and instead
provide an external mechanism to extend the language because it's dark and I
want to go home watch some telly*". The officially sanctioned method to extend
Java are `annotations <https://en.wikipedia.org/wiki/Java_annotation>`_, which
extend the language with metadata that can be processed by compiler plugins.
At least the plugin compilers processing the annotations are in Java, so they
should run on every platform, unlike `Go's random external tools
<http://blog.golang.org/generate>`_ which might be implemented in `Brainfuck
<https://en.wikipedia.org/wiki/Brainfuck>`_. On the other hand, since those
plugins **are** in Java they are going to be a pain to implement. Yuck, back at
you!

.. raw:: html

    <a href="http://aaronsanimals.com/gifs/"><div
        style="float:right;margin:1px"><video
        autoplay muted loop
        style="width: 250px; height: 250px;"> <source
        src="../../../i/youre_fat.mp4" type="video/mp4"
        />No silly animated videos, good for you!</video></div></a>

Have you tried to write Java with a simple editor, like people sometimes do for
languages like C, Pascal, Haskell, Ruby or Python? These languages can benefit
from IDEs, but they are not required, especially for small programs. On the
other hand nearly everything in Java requires a full blown IDE to preserve your
sanity. That's why Java today means an IDE: Eclipse, Android Studio, and others
offer different helpers and additional tools to *mitigate the pain* of the
language. The language itself starts being so unmanageable that you require
special tools to use it (oh, wait, I feel the call of XML). By the way, I'm
insane, so I coded all these examples with `Vim <http://www.vim.org>`_, even
the Java one.

What we end up with is a simple language with attached external complexities
which will never go away because it was decided that they are not to be solved
by the core language.


From the ashes rises the Hero
-----------------------------

You might be correctly asking yourself, if I dislike Java so much, and it
doesn't even satisfy the requirement list to implement a timestamp type, why
bother? Well, for one `Scott was punching Java
<https://scottlocklin.wordpress.com/2016/01/19/timestamps-done-right/>`_, which
is like punching a handicapped person, and even I have a `special place in my
heart for handicapped people <http://www.katawa-shoujo.com>`_. But you know,
sometimes against all that adversity `people simply push forward and do the
best they can <https://www.youtube.com/watch?v=mwbuqzd8UyU>`_, even when they
know that `haters gonna hate, because that's what haters do
<https://www.reddit.com/r/gifs/comments/2tzqkz/a_guy_in_a_wheelchair_doing_vertical_pushups>`_.

The people behind `The Checker Framework
<http://types.cs.washington.edu/checker-framework/>`_ push the language in
better directions. Through those annotations and a compiler plugin you can
improve Java's type system. In fact, this external annotation based type system
is not limited to native types or objects, both can be treated equally, as they
would in a sane language. What we will do is modify the `encryption checker
tutorial
<http://types.cs.washington.edu/checker-framework/tutorial/webpages/encryption-checker-cmd.html>`_
to serve our purpose. In this tutorial you learn how to write annotations that
prevent you from mixing strings with plain text content with methods requiring
strings with encrypted content. Sounds familiar? Yes! That's very much like
using a distinct type to prevent mixing two variables backed by the same binary
representation. The only thing that we need to do is modify the annotation
hierarchy, by default the tutorial allows one to pass encrypted strings to non
encrypted methods. By changing the hierarchy we can effectively make methods
which accept exclusively one annotated type or the other, allowing us to have
longs which are *not really* longs, but special timestamp types.

Not everything is perfect, of course. Since the checker framework is external
to the language itself, even if we annotate types the *raw* compiler is unable
to see them. The biggest drawback of this is that we **can't overload methods
based on the annotation type**, at the time the compiler resolves the
overloading the annotations are ignored. And since we are using native types
and not objects, we have to write static methods, so we end up with an
effective C dialect where we *overload* through prefixes in the method names.

So you see, this is going to be ugly, but at this point it's an exercise in
seeing how far we can reach with Java's crippled type system and other
limitations. Because we can.


Patching the language with annotations
--------------------------------------

.. raw:: html
    <a href="http://spdstudio.tistory.com/3274"><img
        src="../../../i/kerf_pain.jpg"
        alt="Pain, surely you jest? You haven't attempted to walk in my high heels for a few hours, have you?"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>

The `Java code you can get from GitHub
<https://github.com/gradha/kerf_timestamps_done_almost_right/tree/master/java>`_
might not compile for you without additional setup help, which is a little
painful. Remember that we are using external tools, so you need to follow the
`Checker Framework's installation instructions
<http://types.cs.washington.edu/checker-framework/current/checker-framework-manual.html#installation>`_.
And then you need to compile the source code with additional parameters that
invoke the necessary checker plugins. I use myself Nim's `nake tool
<https://github.com/fowlmouth/nake>`_ to automate build tasks, and as you can
see in the nakefile, the `java build instructions are the most complex of all
platforms
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/nakefile.nim#L32-L45>`_.
On top of `having to compile with extra switches
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/nakefile.nim#L10-L17>`_,
files that you don't specify explicitly on the command line **won't be
checked**. So I ended up scanning all files and passing them explicitly to the
compiler to make sure everything is type checked properly.  The first thing we
do is create the annotations that we will be using:

1. `Base
   <https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/myqual/Base.java>`_
   will be the top of our annotation hierarchy. We won't be using it directly,
   it is there to provide separation between siblings.
2. `Plain
   <https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/myqual/Plain.java>`_
   is the annotation which will be *implicit* for any long type. This means
   that if we don't write an annotation, the Checker Framework will presume
   this annotation for any long. This will prevent us from mixing plain longs
   with annotated longs.
3. The `Nano
   <https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/myqual/Nano.java>`_
   and `Stamp
   <https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/myqual/Stamp.java>`_
   annotations are there to differentiate our new pseudo variants of the native
   long type.

The actual implementation of these new virtual types will be done in the
`NanoUtils
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/abomination/NanoUtils.java>`_
and `StampUtils
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/abomination/StampUtils.java>`_
classes. These classes don't create any objects, they just group together
static methods which will handle our annotated primitive longs. They are
grouped inside a separate package (`abomination
<https://github.com/gradha/kerf_timestamps_done_almost_right/tree/master/java/abomination>`_)
because if we placed it at the level of the `Units.java file
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/Units.java>`_
used to exercise the Kerf blog examples we would not be able to use ``import
static foo.*`` which shortens a lot the unnecessary object orientation.

The typical `constants and literal pseudo constructors don't look too bad <https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/abomination/NanoUtils.java#L12-L29>`_:

```java
public static final @Nano long uNano = (@Nano long)1;
public static final @Nano long uSecond = mul(uNano, 1000000000);
public static final @Nano long uMinute = mul(uSecond, 60);
public static final @Nano long uHour = mul(uMinute, 60);
public static final @Nano long uDay = mul(24, uHour);
public static final @Nano long uMonth = mul(30, uDay);
public static final @Nano long uYear = mul(uDay, 365);

// Conversion procs to help with math annotation conversions.
public static @Nano long Nano(int x) { return (@Nano long) x; }
public static @Nano long Nano(Long x) { return (@Nano long) x; }
public static @Nano long ns(int x) { return (@Nano long) x; }
public static @Nano long s(int x) { return (@Nano long) x * uSecond; }
public static @Nano long i(int x) { return (@Nano long) x * uMinute; }
public static @Nano long h(int x) { return (@Nano long) x * uHour; }
public static @Nano long d(int x) { return (@Nano long) x * uDay; }
public static @Nano long m(int x) { return (@Nano long) x * uMonth; }
public static @Nano long y(int x) { return (@Nano long) x * uYear; }
```

As you can see the verbosity of Java itself is not enough so we add the
``@Nano`` annotations where we need them, usually with casts for mathematical
operations. As mentioned above we won't have the luxury of method overloading,
so we have to `manually prefix methods that could clash with our future @Stamp
annotation
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/abomination/NanoUtils.java#L31-L60>`_:

```java
public static Long nbox(@Nano long x) {
	return Long.valueOf((@Plain long)x);
}

// …

public static @Nano long nadd(@Nano long x, int y) {
	return (@Nano long)x + (@Nano long)y;
}
public static @Nano long nadd(int x, @Nano long y) {
	return (@Nano long)x + (@Nano long)y;
}
public static @Nano long nadd(@Nano long x, @Nano long y) {
	return x + y;
}
public static @Nano long sub(@Nano long x, @Nano long y) {
	return x - y;
}
public static @Nano long madd(@Nano long... values) {
	@Nano long result = values[0];
	for (int f = 1; f < values.length; f++) {
		result = nadd(result, values[f]);
	}
	return result;
}
```

I decided to prefix the ``@Nano`` related methods with a small ``n``. Later for
the examples I found myself using an absurd amount of method calls, so I added
a ``madd`` method supporting variadic arguments to reduce the clutter. After
the initial shock of annotations and lack of overloading `the rest of the code
just flows normally without any trouble
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/abomination/NanoUtils.java#L62-L171>`_
to reach the `self unit test code at the end
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/abomination/NanoUtils.java#L177-L196>`_:

```java
echo("Testing seconds operations:");
echo(nStr(Nano(500)) + " = " + nStr(ns(500)));
echo(nStr(uSecond) + " = " + nStr(s(1)));
echo(nStr(uMinute + uSecond + (@Nano long) 500) +
	" = " + nStr(i(1) + s(1) + ns(500)));
echo(nStr(uHour) + " = " + nStr(h(1)));
echo(nStr(h(1) + i(23) + s(45)) + " = "
	+ nStr(composedDifference) + " = " + composedString);
echo(nStr(uDay) + " = " + nStr(d(1)));
echo(nStr(uYear) + " = " + nStr(y(1)));
echo(nStr(uYear - d(1)));

@Nano long a = composedDifference + y(3) + m(6) + d(4) + ns(12987);
echo("total " + nStr(a));
echo("\tyear " + nYear(a));
echo("\tmonth " + nMonth(a));
echo("\tday " + nDay(a));
echo("\thour " + nHour(a));
echo("\tminute " + nMinute(a));
echo("\tsecond " + nSecond(a));
```

The ``echo()`` function is just a `wrapper around System.out.println()
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/extra/Out.java#L6>`_.
In Nim we had automatic type conversion for ``echo()``. In C++ we could
overload the ``<<`` operator, and in Swift we could make our types adopt the
``CustomStringConvertible`` protocol. In Java land we only have `chemical burns
everywhere <https://www.youtube.com/watch?v=zvtUrjfnSnA>`_ and thus have to
convert manually our custom longs with ``nStr()``, which is our hypothetical
``.toString()`` method. If we didn't use that Java would use the default
``Long.toString(foo)`` method, and we would be forced out of our type happy
alternative world into the real cold reality.

Having gone through this the `StampUtils.java file
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/abomination/StampUtils.java>`_
doesn't seem appealing enough to review. The only missing odd bits are the
previously mentioned but not described `nbox() method
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/abomination/NanoUtils.java#L31-L33>`_
and the equivalent ``@Stamp`` related `sbox() method
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/abomination/StampUtils.java#L122-L124>`_.
What are these for? They are for the new Java 8 stream operations used in the `final Units.java file <https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/Units.java#L29-L42>`_:

```java
List<Long> values = IntStream.range(0, 10)
	.boxed()
	.map(intStep -> nbox(mul(
		madd(m(1), d(1), h(1), i(15), s(17)),
		(int)intStep)))
	.map(longNano -> sbox(sadd(Date("2012.01.01"), Nano(longNano))))
	.collect(Collectors.toList());

echo("Example 4: @[" + values.stream()
	.map(longStamp -> sStr(Stamp(longStamp)))
	.collect(Collectors.joining(", ")) + "]");
```

The fourth Kerf example uses functional like mapping, and this can be done with
some pain with Java 8 streams. Unfortunately by emulating functional mapping
calls we have **already lost the bet**: just like templates, Java 8 streams
don't work on primitive types and require boxing and unboxing. That's what
those mysterious ``nbox()`` and ``sbox()`` methods were for, since the only way
to work with streams is to upgrade from the ``long`` to the ``Long`` type. And
the reason we have *lost* is that instead of using native types we would be
better off using real class objects, even though we wouldn't have then the
performance and memory efficiency of value types. The last attempt at
extracting the calendar components from a list containing those ``Long``
objects is `particularly painful to watch
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/java/Units.java#L44-L50>`_:

```java
echo("Example 5: b[week]: @[" + values.stream()
	.map(longStamp -> String.valueOf(sWeek(Stamp(longStamp))))
	.collect(Collectors.joining(", ")) + "]");

echo("Example 5: b[second]: @[" + values.stream()
	.map(longStamp -> String.valueOf(sSecond(Stamp(longStamp))))
	.collect(Collectors.joining(", ")) + "]");
```

Unfortunately we can't replicate Kerf's timestamp type to any reasonable degree
without compromising the syntax and the performance for real usage code despite
our initial promising attempt.  Fuck you Java, and fuck you **forced** object
orientation. I'll keep this in mind when I `evaluate the results of all
implementations in the last article
<kerf-timestamps-done-almost-right-conclusions.html>`_.

.. raw:: html

    <br clear="right"><center>
    <a href="http://www.idol-grapher.com/1768"><img
        src="../../../i/kerf_enough.jpg"
        alt="That's it, enough Java for my whole life"
        style="width:100%;max-width:600px" align="center"
        hspace="8pt" vspace="8pt"></a>
    </center>

---
title: Swift string interpolation with Nimrod macros
pubDate: 2014-11-12 00:40
modDate: 2014-11-12 00:40
tags: nimrod, programming, languages, swift
---

Swift string interpolation with Nimrod macros
=============================================

Just like `the Go programming language <http://golang.org>`_ had initially a
lot of marketing pull due to the fame of the authors and company behind the
language, growing in popularity you can hear about `Swift
<https://developer.apple.com/swift/>`_, Apple's new programming language for
iOS and OSX, which probably makes it the financially most backed up hipster
language. It is *sort of* hipster because nobody outside of iOS and OSX will
want to touch it, and Apple has demonstrated to put serious money behind it
(hiring `Chris Lattner <https://en.wikipedia.org/wiki/Chris_Lattner>`_) and
will likely continue to do so. Not even Apple wants to keep programming in a
crap language like Objective-C forever. And Google, I'm still waiting for you
to ditch the abomination known as Java. Please (*crosses fingers*).

Swift source code looks seriously close to `Nimrod <http://nimrod-lang.org>`_,
just like its feature set.  Most notably the syntax keeps braces for those
still clinging to them, and retains Objective-C's named parameter madness for
interoperability. But other than that it is remarkable how sometimes I actually
forget I'm reading Swift code and think "*oh, that Nimrod code is weird, how
can it compile*?". One of the things I noticed after reading some tutorials was
that Swift provides an `interesting string interpolation feature
<https://developer.apple.com/library/ios/documentation/Swift/Conceptual/Swift_Programming_Language/StringsAndCharacters.html>`_:


.. code-block:: c

    let multiplier = 3
    let message = "\(multiplier) times 2.5 is \(Double(multiplier) * 2.5)"
    // message is "3 times 2.5 is 7.5"

The equivalent code in Nimrod could be:

.. code-block:: Nimrod

    const
      multiplier = 3
      message = $multiplier & " times 2.5 is " & $(multiplier * 2.5)
      # message is "3 times 2.5 is 7.5"

It is not that much different but it certainly reduces some sigil clutter. I
think the syntax to embed a single variable is awkward because you need to add
the closing parenthesis, but then, just like Python mantra goes, `explicit is
better than implicit <http://legacy.python.org/dev/peps/pep-0020/>`_. Maybe.

Nimrod has one serious advantage over Swift, it has `macros
<http://nimrod-lang.org/tut2.html#macros>`_. The question is, can we *steal*
Swift's string static interpolation feature ourselves? Of course, it's actually
fairly easy. Just like when `I stole Objective-C properties
<../06/dirrty-objects-in-dirrty-nimrod.html>`_ and later `made them really sexy
<../10/adding-objectivec-properties-to-nimrod-objects-with-macros.html>`_, we
will again stomp on the dead bodies of our enemies. Ra ra ra!


The heist
=========

As for any other macro we want to write in Nimrod, it is best to first figure
out what AST is Nimrod producing for perfectly valid code, then try to generate
it as closely as possible. We want to create a compilation time proc which will
replace a single string literal into a series of concatenations which can be
coalesced by the compiler not wasting a single CPU cycle at runtime. Let's dump
the AST of the previous Nimrod snippet:

.. code-block:: nimrod

    import macros
    
    dumpTree:
      $multiplier & " times 2.5 is " & $(multiplier * 2.5)

If we compile this we will get this output::

    StmtList
      Infix
        Ident !"&"
        Infix
          Ident !"&"
          Prefix
            Ident !"$"
            Ident !"multiplier"
          StrLit  times 2.5 is 
        Prefix
          Ident !"$"
          Par
            Infix
              Ident !"*"
              Ident !"multiplier"
              FloatLit 2.5

Fairly easy, when the ``$`` operator is applied, we only need to wrap the
identifier inside a ``Prefix`` node. For the concatenations we have a recursive
tree of ``Infix`` nodes. The multiplication expression is wrapped inside a
``Par`` node.

Now the only thing left for us is to parse the string literal and figure out
which parts are text and which parts are variables or expressions. We can't use
Swift's escape parenthesis notation because we are not modifying Nimrod's
`string literals <http://nimrod-lang.org/manual.html#string-literals>`_, they
come with the language. What else can we do? In Nimrod there is runtime string
interpolation using `strutils.%() operator
<http://nimrod-lang.org/strutils.html#%,string,openArray[string]>`_. The
``strutils`` module uses internally the `parseutils module
<http://nimrod-lang.org/parseutils.html>`_, and luckily we can use directly the
`interpolatedFragments()
<http://nimrod-lang.org/parseutils.html#interpolatedFragments.i,string>`_
iterator for our macro. Isn't it nice when most of the code we have to write is
already provided?

.. raw:: html

    <center><a href="http://darkablaxx.tistory.com/69"><img
        src="../../../i/lime-knows-about-macros.jpg"
        alt="Some kpop idols know things you wouldn't believe"
        style="width:100%;max-width:600px"
        hspace="8pt" vspace="8pt"></a></center><br>


The code
========

I did warn you, here are the complete 20 lines of code to implement this
feature **and** test it too:

.. code-block:: nimrod

    import macros, parseutils, sequtils
    
    macro i(text: string{lit}): expr =
      var nodes: seq[PNimrodNode] = @[]
      # Parse string literal into "stuff".
      for k, v in text.strVal.interpolatedFragments:
        if k == ikStr or k == ikDollar:
          nodes.add(newLit(v))
        else:
          nodes.add(parseExpr("$(" & v & ")"))
      # Fold individual nodes into a statement list.
      result = newNimNode(nnkStmtList).add(
        foldr(nodes, a.infix("&", b)))
    
    const
      multiplier = 3
      message = i"$multiplier times 2.5 is ${multiplier * 2.5}"
    
    echo message
    # --> 3 times 2.5 is 7.5

Just like `db_sqlite's raw string literal modifier
<http://nimrod-lang.org/db_sqlite.html#sql,string>`_ we have implemented here
the ``i`` macro and use it to prefix the string literals we want to *upgrade*
with string interpolation. Also, since we are withing Nimrod's string parsing
rules, the interpolation is done with the ``$`` character which allows both
braced and standalone versions, less backslash typing.

The macro is divided in two parts, parsing the string literal and generating
the tree of infix/prefix nodes representing string concatenation. For the
string parsing we simply add all strings (``ikStr``) and dollars (``ikDollar``)
as string literals (`newLit() <http://nimrod-lang.org/macros.html#newLit>`_).
For everything else we simply wrap the expressions inside a call to the ``$``
string conversion operator (just in case) and let `parseExpr()
<http://nimrod-lang.org/macros.html#parseExpr,string>`_ do its job.

The result of this conversion is stored as a sequence of ``PNimrodNode``
objects, which is a flat list. To convert it into the AST tree Nimrod expects
we use the `foldr() <http://nimrod-lang.org/sequtils.html#foldr.t,expr,expr>`_
template from the `sequtils <http://nimrod-lang.org/sequtils.html>`_ module.
``foldr`` accepts as first parameter the sequence of items we want to fold, and
as ``operation`` we apply the `infix()
<http://nimrod-lang.org/macros.html#infix,PNimrodNode,string,PNimrodNode>`_
helper from the `macros
<http://nimrod-lang.org/macros.html#infix,PNimrodNode,string,PNimrodNode>`_
module.

How can be sure this is all working and there is no runtime trickery behind our backs? The most simple way is to check `Nimrod's nimcache directory <http://nimrod-lang.org/nimrodc.html#generated-c-code-directory>`_ where it places the C code that later is compiled into a binary. In this case we have the following line:

.. code-block:: c

    …
    N_NOINLINE(void, HEX00_sequtilsDatInit)(void);
    N_NOINLINE(void, exInit)(void);
    N_NOINLINE(void, exDatInit)(void);
    STRING_LITERAL(TMP144, "3 times 2.5 is 7.5", 18);
    extern TFrame* frameptr_15442;
    …

There you have it, our macro has expanded the string literal into expressions,
and since the expression can be calculated at compile time it already appears
embedded in the C string literal. No runtime calculation of any type. Success!


Conclusion
==========

Stealing language features with macros is `very cool and gratifying
<https://www.youtube.com/watch?v=qEYOyZVWlzs>`_. But you need to look at other
languages too to see which features they have. Hopefully Swift programmers gain
interest in Nimrod, it would allow them to continue writing proper static code
for other platforms like Windows or Linux (`unlike the Swift trap
<https://ind.ie/phoenix/>`_) and open their minds to some fresh air. But it is
understandable that Swift still has to deal with a lot of old-timers clinging
to old practices. Maybe Swift 2.0 will also have macros, they are really neat
and allow you to extend whatever language you have with cool features not part
of the original spec.

::
    $ nimrod c -r swift.nim
    Hello future!

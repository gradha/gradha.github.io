---
title: Adding properties to Nimrod objects
pubDate: 2014-10-12 01:08
modDate: 2014-10-12 01:08
tags: nimrod, programming, languages, objc
---

Adding properties to Nimrod objects
===================================

The `Nimrod programming language <http://nimrod-lang.org>`_ allows one to use
`macros <http://nimrod-lang.org/manual.html#macros>`_ to extend the language.
In a `previous article <../06/dirrty-objects-in-dirrty-nimrod.html>`_ we were
guided by `Christina Aguilera
<https://en.wikipedia.org/wiki/Christina_Aguilera>`_ into adding Objective-C
like properties to the Nimrod programming language. However, the result, while
effective, looked quite spartan and low class, like `Christina's slutdrop
<https://en.wikipedia.org/wiki/File:Dirrty_Slutdrop.jpg>`_. Here is the code I
ended up with:

```nimrod
import utils

type
  Person = object of Dirrty
    Fname, Fsurname: string
    Fage: int

generateProperties(Person, name, string)
generateProperties(Person, surname, string)
generateProperties(Person, age, int)

proc test() =
  ## Exercise the setters and getters.
  var a: Person
  a.name = "Christina"
  echo "Is ", a.name, " dirrty? ", a.dirrty

when isMainModule: test()
```

This code has several issues on the long run:

1. The ``type`` definition is separate from the ``generateProperties`` calls.
   This means it is easy to *lose sync* between both.
2. There is much repeating of simple identifiers. Worse, because the type and
   the property generating macro is separate, one has to use the *implied*
   ``F`` prefix for instance variables being used as properties, and the non-F
   version for the property (or vice versa, should you write your macro the
   other way round). It is easy to get distracted and mess up one or the other
   and later get shocked by the compiler.
3. Just like with the identifiers, the type for each field is repeated too.
   This is just nonsense.

With Nimrod you can do better. And better than the obviousness of Christina's
slutdrop, I find `Ace of Angels' <https://en.wikipedia.org/wiki/AOA_(band)>`_
`miniskirt unzipping and ass shaking
<http://www.youtube.com/watch?v=q6f-LLM1H6U>`_ more tasteful and pleasant to
the eye (after all, at the moment I'm writing this Christina loses with
9.986.070 views to the 11.394.880 views of Ace of Angels, yet AOA's video has
existed for far less time). Following the steps of these Queens of teasing,
here is a quick peek at how the code will end up after we drive ourselves crazy
with some serious macro writing:

```nimrod
import utils

makeDirtyWithStyle:
  type
    Person = object of Dirrty
      dirty, name*, surname*: string
      clean, age*: int
      internalValue: float

proc test() =
  var a: Person
  a.name = "Christina"
  echo "Is ", a.name, " dirrty? ", a.dirrty

when isMainModule: test()
```

The roadmap ahead
=================

We can see by the previous teaser that we have gotten rid of the
``generateProperties`` macro completely. Yay! That code has been moved into the
``makeDirtyWithStyle`` macro. Instead of a call, what we are doing here is
`invoking our macro as a statement
<http://nimrod-lang.org/tut2.html#statement-macros>`_. Everything indented
after the colon will be passed in to the macro as its last parameter. How? As
an `abstract syntax tree <https://en.wikipedia.org/wiki/Abstract_syntax_tree>`_
or AST for short.

.. raw:: html

    <center><img
        src="../../../i/asts-asts-everywhere.jpg"
        alt="If you close your eyes hard you can sometimes see the ASTs"
        style="width:100%;max-width:600px"
        hspace="8pt" vspace="8pt"></center><br>



Our new version of the macro will still use the same `quasi-quoting
<http://nimrod-lang.org/macros.html#quote>`_ to generate the setter and getter
procs. However, before generating any code the macro will be able to traverse
the input AST and figure out itself what fields of the object are meant to be
used for the setter and getter. On top of that, it will automatically mangle
the fields to use the ``F`` prefix letter (similar to Objective-C prefixing
properties with an underscore in case you need to access them directly), and we
will simulate our own mini DSL through identifiers to fake language support to
specify which property setters need to mark the object's dirty flag as dirty or
not. You can see that in the example code through the words ``dirty`` and
``clean``.

The `Nimrod Tutorial <http://nimrod-lang.org/tut1.html>`_ has a `Building your
first macro <http://nimrod-lang.org/tut2.html#building-your-first-macro>`_
section. You are meant to have at least skimmed through that because I won't be
explaining all the basics, only the ones I'm interested in. Also, much of the
typical error handling code you find in macros won't be present for brevity.
What error handling code would be this? Well, as you can see we can now pass
any random Nimrod code to our macro, and it has to figure out how to treat it.
If the user makes any mistakes in the construct, rather than simply quitting or
aborting a helpful error message should be provided. That makes the code a lot
more verbose checking for all possible inputs.

Don't get scared now of the length of this blog post, it is all due to the
example code lines being repeated several times to make the text more
contextual. In any case I recommend you to either download the source code
(utils.nim and miniskirt.nim) or view them through GitHub, which I will use to
quickly point to the appropriate lines (see utils.nim and miniskirt.nim on
GitHub). The truth is that most of the macro is pretty simple, it has already
been explained and what is left as an exercise for the writer is to transform
words into code. I've always secretly wanted to be a compiler when I grew up!



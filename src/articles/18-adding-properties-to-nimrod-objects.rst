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
effective, it looked quite spartan and low class, like `Christina's slutdrop
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
   other way round).



---
title: Dirrty objects, in dirrty Nimrod
pubDate: 2014-06-07 20:23
modDate: 2014-10-12 22:55
tags: nimrod, programming, objc
---

Dirrty objects, in dirrty Nim
=============================

This article has been optimized for search engines by using the misspelled word
**dirrty**. If you came here looking for some hot girls, please go instead to
Youtube to watch `Christina Aguilera's Dirrty video
<https://www.youtube.com/watch?v=4Rg3sAb8Id8>`_ where she works it out. At the
moment of writing this article the video records 7.226.476 views, some more
won't hurt. For all the other boring people, welcome again to another technical
article only worth reading while you wait for the compiler to do its job (or
for your browser to render some JavaScript, if you are one of those hipster
types).

In what looks like a distant past, I used to write Objective-C code for the
iPhone. In one of the projects, a little client consuming JSON would fetch news
from a web server and cache them locally using SQLite. The code I initially
wrote worked fine for about 50 to 100 items, which was the expected workload.
Years later this code was moved to another project where the item requirement
jumped to over 600+ items and suddenly the user interface was all jerky. As if
you were using a cheap Android device instead of the silky smooth luxury car
the iPhone feels like (platform fanboys will be glad to know I replicated the
silky smooth experience on Android 2.1 devices with less computing power than a
cereal box).

Certainly 600 didn't seem an incredibly big number (though it was `twice as
Sparta <https://en.wikipedia.org/wiki/300_(comics)>`_, respekt man), so why was
it all slow suddenly?  Fortunately there were two things I could quickly do to
alleviate the problem and not look back:

1. SQL transactions.
2. Marking objects as `dirrty <https://en.wikipedia.org/wiki/Dirrty>`_.

Experienced Objective-C programmers with knowledge of `Core Data
<https://en.wikipedia.org/wiki/Core_Data>`_ will surely roll their eyes at this
point as both of these problems are handled automatically by the framework. The
SQL transactions is the obvious facepalm: using a database without taking care
of transactions is like pushing a bicycle instead of riding it. You have this
shiny thingy beside you which helps you and you are ignoring it. But after
placing a few BEGIN/COMMIT here and there the saving wasn't instant yet
(remember, you have to aim for perfect, always).

The 600+ item requirement didn't actually come from increased network traffic.
The server would still serve data in chunks of about 50 items. However, the
items would be cached locally until a certain expiration date and thus when new
items arrived the older ones were still there. That was the problem: the code
was blindly saving all the objects even when they had not changed at all.
That's where the **dirrty** flag comes, the code would mark any new or modified
object as **dirrty** and the SQLite saving code would skip the items without
this flag.  With these two new measures in place the client performed again
seemingly instantly and scrolling was fast again even on first generation
devices.


The reference Objective-C implementation
========================================

.. raw:: html

    <a href="https://en.wikipedia.org/wiki/File:Dirrty_Slutdrop.jpg"><img
        src="../../../i/wikipedia_slutdrop.jpg"
        alt="Christina doing the slutdrop"
        style="width:100%;max-width:750px" align="right"
        hspace="8pt" vspace="8pt"></a>

The implementation of the **dirrty** flag is not really hard at all, just
tedious. In Objective-C you tend to build your serialized objects around an
inheritance tree where the base class provides the basic serialization methods.
Subclasses can then call ``super`` and extend the serialization (in my case,
JSON dictionaries) with whatever new properties the parent class was not aware
of.

The first step is to create a data model super class which already contains the
**dirrty** flag. Then you provide setter/getters for properties. In Objective-C
setters/getters can be implemented by the compiler automatically through
``@property`` and ``@synthethize``. But you can also implement them yourself.
In my case I created the following C macros which would expand to setters
marking the **dirrty** flag:

.. raw:: html

    <br clear="right">

::

    #define SS_DIRRTY_ASSIGN_SETTER(NAME,TYPE,VAR) \
    	- (void)NAME:(TYPE)VAR { \
    		VAR ## _ = VAR; \
    		dirrty_ = YES; \
    	}

    #define SS_DIRRTY_RETAIN_SETTER(NAME,TYPE,VAR) \
    	- (void)NAME:(TYPE)VAR { \
    		[VAR retain]; \
    		[VAR ## _ release]; \
    		VAR ## _ = VAR; \
    		dirrty_ = YES; \
    	}

    // Actual later usage:
    SS_DIRRTY_RETAIN_SETTER(setBody, NSString*, body)
    SS_DIRRTY_RETAIN_SETTER(setFooter, NSString*, footer)

Not the prettiest code in the world, but works fine. There are two versions of
the macro, one for scalar values and another for objects which requires the
``retain/release`` dance. The last two lines would be seen in a subclass
implementation file where they would expand to a setter updating the
``dirrty_`` flag. In recent Objective-C versions the getter is generated by the
compiler, but we could add the getter generation to these macros as well for
ancient compiler compatibility.


Dirrtying Nim
=============

In the `Nim programming language <http://nim-lang.org>`_ we can replicate
the C macros with some improvements. Here is the code of a ``utils.nim`` file:

```nimrod
import macros

# Create a superclass with the dirrty flag.
type
  Dirrty* = object of TObject
    dirrty*: bool

macro generateProperties*(objType,
    varName, varType: expr): stmt =
  # Create identifiers from the parameters.
  let
    setter = !($varName & "=")
    iVar = !("F" & $varName)
    getter = !($varName)

  # Generate the code using quasiquoting.
  result = quote do:
    proc `setter`*(x: var `objType`,
        value: `varType`) {.inline.} =
      x.`iVar` = value
      x.dirrty = true

    proc `getter`*(x: var `objType`):
        `varType` {.inline.} =
      x.`iVar`
```

As scary as this code may look to any beginner in the language, the nice thing
is that you can put it aside in a separate file and not look at it ever again.
It is not very difficult to understand either. The first thing it does is
import the `macros module <http://nim-lang.org/macros.html>`_ which contains
many meta programming helpers. Then it defines a ``Dirrty`` base class which
includes the ``dirrty: bool`` field. User defined objects will inherit from the
class.

The second (scary) thing this code does is define the ``generateProperties``
macro. This macro accepts a user defined type, a variable name, and the type of
this variable. Then proceeds to create in the ``let`` block the names of the
setter, getter and instance variable that will be used to access the object.
This is done `converting the parameter Nim symbol to a string
<http://nim-lang.org/macros.html#$,PNimrodSymbol>`_, mangling the string,
then `constructing again an identifier from this new string
<http://nim-lang.org/macros.html#!,string>`_. Note how you can apply crazy
logic here depending on names of the variables, something which is hard or
impossible to do in C macros.

Once the identifiers are generated, using `quasi-quoting
<http://nim-lang.org/macros.html#quote>`_ we define a setter and getter proc
with the generated identifiers. The backticks are what will be replaced in the
final code, and all of this is assigned to the result of the macro, thus
generating the wanted code. Whenever this call is found, the Nim compiler
will generate the setter and getter for us. Now let's see a typical usage of
this macro:

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
The ``Person`` object defined here inherits from our ``Dirrty`` base class and
uses the `getter and setter convention
<http://nim-lang.org/tut2.html#properties>`_ of creating a *private*
variable with the **F** prefix. This variable can be accessed only from the
current unit. After the type declaration we invoke the ``generateProperties``
macro to *produce* at compilation time the setter and getter for each of the
fields.

What follows is a basic ``test`` proc which verifies our assumptions by
creating a ``Person`` object, then echoing to screen the state of the
**dirrty** flag after using the generated setter to name it **Christina**. You
can surely expect the result by now::

    Is Christina dirrty? true

.. raw:: html

    <center><img
        src="../../../i/christina_punch.jpg"
        alt="Hitting adversaries one macro at a time"
        style="width:100%;max-width:750px"
        hspace="8pt" vspace="8pt"></center><br>


Conclusion
==========

In these few lines of code we have not just solved the hypothetical problem of
marking automatically a flag in setter procs: we have actually implemented
Objective-C style properties. Let that sink in. Nim doesn't provide
properties, but instead it is flexible enough that it allows you, the end user
programmer, to define your own language constructs. And you know what happens
if you program in a language not flexible enough to stand the test of time?
Yes, you are `forced to switch to new incompatible languages
<https://developer.apple.com/swift/>`_. Otherwise you are stuck in the past.

Could advanced Nim meta programming improve this example further?  Could we
get rid of having to repeat the type of the field when creating the setters and
getters and let the compiler figure it out? Could we avoid having to separate
the definition of the object from the definition of the procs?

`Who knows…
<../10/adding-objectivec-properties-to-nimrod-objects-with-macros.html>`_

::
    $ playback slutdrop.m4a
    Permission denied
    Kernel DRM module not found

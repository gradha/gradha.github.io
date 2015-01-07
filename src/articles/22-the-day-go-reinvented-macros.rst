---
title: The day Go reinvented macros
pubDate: 2015-01-07 22:00
modDate: 2015-01-07 22:00
tags: design, tools, languages, programming, go, nim, nimrod
---

The day Go reinvented macros
============================

Context
-------

One of the big selling points of the `Nim programming language
<http://nim-lang.org>`_ is that it has `syntactic macros
<https://en.wikipedia.org/wiki/Macro_(computer_science)#Syntactic_macros>`_.
When you go to its website, on the front page you can read these sentences:

* […] Beneath a nice infix/indentation based syntax with a powerful (AST based,
  hygienic) macro system lies a semantic model that supports a soft realtime GC
  on thread local heaps. […]
* Macros can modify the abstract syntax tree at compile time.
* Macros can use the imperative paradigm to construct parse trees. Nim does not
  require a different coding style for meta programming.
* Macros cannot change Nim's syntax because there is no need for it. Nim's
  syntax is flexible enough.

If you learn about a new language and read these things on the front page, you
understand that macros are a really important part of the language, and their
use is encouraged by the language developers. As such, it was very surprising
that when I posted to `reddit one of my articles about Nim macros
<http://www.reddit.com/r/nimrod/comments/2polby/swift_string_interpolation_with_nim_macros/>`_
the user **SupersonicSpitfire** mentioned the article is offensive without any
logic, macros are not an advantage, but a huge disadvantage, I'm stupid and I
suck (later edited to *soften* the language a bit), and macros in general are
offensive.

I'm not a stranger to `John Gabriel's Greater Internet Fuckwad Theory
<http://www.penny-arcade.com/comic/2004/03/19/>`_, being insulted on the
internet is just the norm. But I didn't cross post this anywhere else, it was
an article about Nim for other Nim programmers. Is **SupersonicSpitfire** an
actual Nim programmer who hates… a big chunk of the language? That's really
bothering me. It's like something is broken in this universe. Why would people
who passionately hate a feature follow their communities? Self inflicted
stress? Pain?!


What are macros anyway?
-----------------------

If you don't have the time to `read Wikipedia's full article
<https://en.wikipedia.org/wiki/Macro_(computer_science)#Syntactic_macros>`_,
macros are just one of the many methods to reduce typing. With macros you can
*generate* source code for the compiler. Unfortunately the most well known
macros are those from C/C++, which are just `text macros
<https://en.wikipedia.org/wiki/Macro_(computer_science)#Text_substitution_macros>`_
implemented by the language **preprocessor** (the **pre** should tell you
already something about how they work).  While they are part of the standard
(you can't implement C without them), they are not really part of the language
itself, since the language doesn't know anything about them, and the
preprocessor can only deal with source code as lines of text. Here is one fun
example:

```c
#include <stdio.h>

#define SIX 1+5
#define NINE 8+1

int main(void)
{
	printf("Macros rule %d\n", SIX * NINE);
}
```
Running this program will produce the output 42, **not** 54 as one could
naively *read*. Since C macros are textual replacements, you actually get the
expression ``1 + 5 * 8 + 1``, where the multiplication has higher priority,
thus evaluates to ``1 + 40 + 1 == 42``. Experienced C programmers will bracket
the hell out of their macros **just in case**.  And this is the tip of the
iceberg when people complain that macros hurt readability, entries of the
`international obfuscated C code contest <http://ioccc.org>`_ `typically
<http://ioccc.org/2013/endoh3/endoh3.c>`_ `exploit
<http://ioccc.org/2013/hou/hou.c>`_ `macros
<http://ioccc.org/2013/mills/mills.c>`_ `extensively
<http://ioccc.org/2013/morgan2/morgan2.c>`_.

The reason text macros are still used is because they are very easy to
implement, and with enough care they can help the programmer. For instance, the
`@weakify(self) macro
<http://aceontech.com/objc/ios/2014/01/10/weakify-a-more-elegant-solution-to-weakself.html>`_
is quite popular in Objective-C circles because it hides away tedious typing
you otherwise have to do to write correct code without going insane. The
`weakify
<https://github.com/jspahrsummers/libextobjc/blob/652c9903a84f44b93faed528882e0251542732b1/extobjc/EXTScope.h#L45>`_
macro uses internally the `ext_keywordify
<https://github.com/jspahrsummers/libextobjc/blob/master/extobjc/EXTScope.h#L115>`_
macro. Just like with the ``SIX * NINE`` from the first example, something
written like this:

```c
@weakify(self)
```
…will expand to something similar to this:
```c
@try {} @catch (...) {} more-macros-plus-self
```
Which is essentially the Objective-C equivalent of the `do while(false)
<http://stackoverflow.com/questions/4674480/do-whilefalse-pattern>`_ pattern
used exclusively to bring that at-sign (``@``) into your code so it *looks*
like a *native* compiler directive. It's a clever hack, but following how it
works is not easy at all: more bad reputation.

I implemented myself another form of macros for Java and Android development.
For a project where we had just one source code base customized for different
clients, the most sensible way was to use a preprocessor where you replace a
few strings or keywords and you get an different independent binary, something
not supported by the ancient Ant build tool. Using Python and some regular
expressions I implemented what later was replaced by `Gradle's build variants
<http://tools.android.com/tech-docs/new-build-system/user-guide#TOC-Build-Variants>`_.

The Gradle version was better integrated with the build system, but effectively
I had reached before the same conclusion: for a certain task, a macro was the
best solution. And if it wasn't, Google engineers wouldn't have pushed this
feature either.  One thing to note is that they didn't implement it as crude
text replacement, looks more like `procedural macros
<https://en.wikipedia.org/wiki/Macro_(computer_science)#Procedural_macros>`_,
since you use Gradle (a mini language) to define these things, and it can be
analyzed statically (I believe, or maybe it does that at runtime, which would
explain why it is painfully slow whenever you change a setting). In any case,
today new development tries to go away from the aberrations you can generate
with textual macros. We know they are painful.


Nim macros
----------

In the quest for improving meta programming, we reach `syntactic macros
<https://en.wikipedia.org/wiki/Macro_(computer_science)#Syntactic_macros>`_,
which work on abstract syntax trees (ASTs) instead of lines of text. Nim
macros, like other languages, features hygienic macros, meaning that unlike C
macros where you can affect code posterior to the macro expansion, whatever you
do in the macro stays there. Nim macros end up being like normal procs with two
main differences:

* They run at compile time (in the case of Nim, other languages might do macro
  expansion at runtime)
* They process ASTs, and generate ASTs.

Like the Wikipedia article mentions, macros are kind of natural of
`S-expression <https://en.wikipedia.org/wiki/S-expression>`_ languages, since
S-expression allows easily to treat code and data equally. But many people feel
uncomfortable with S-expressions. Nim has an imperative syntax, so it looks
more familiar, at the cost of being more verbose. The availability of modifying
the ASTs is also limited. In a text macro implementation you can change
whatever you want. But here you are fed just a subtree of the user's AST, and
that's the only thing you can modify.

To simplify, the Nim compiler runs your macros, which produce more ASTs, and
then compiles their output. This allows one to expand the language and provide
new constructs. With macros you can `implement object oriented programming
<http://nim-by-example.github.io/oop_macro/>`_, no need to wait for the
language to evolve, you can evolve it yourself!


So what does this have to do with Go, they don't have macros!
-------------------------------------------------------------

Yes they do. The blog post `Generating code <http://blog.golang.org/generate>`_
posted on the 22nd of December of 2014 should already hint with its title that
Go version 1.4 includes some sort of mechanism to generate code. Oh… shiny…
that sounds like meta programming… as if you could generate code for the
compiler…

**ATTENTION:** If you are one of those Go acolytes who believes Go's most
important feature is simplicity and readability, please stop reading! And never
ever **go** to version 1.4 and beyond!

The example given in Go's blog is to stringify enum constants into strings so
you can print them or maybe compare them. The `Go generate design document
<https://docs.google.com/a/golang.org/document/d/1V03LUfjSADDooDMhe-_K59EgpTEm3V8uvQRuNMAEnjg/edit?pli=1>`_
provides additional examples like generating protocol buffers bindings (which
you could do with a Nim macro based on a type definition), embedding binary
data (which you could do with a Nim macro, but is so common that you can use
Nim's `staticRead() <http://nim-lang.org/system.html#staticRead>`_), etc. Other
quotes from that document:

* One could imagine a variant sort implementation that allows one to specify
  concrete types that have custom sorters, just by automatic rewriting of
  **macro-like** sort definition[…]
* There are many more possibilities, and it is a goal of this proposal to
  encourage experimentation with pre-build-time code generation

While the feature has just been released, people in the community have already
been playing with it. Let's see some comments from the `reddit discussion
<http://www.reddit.com/r/golang/comments/2q3yj4/generating_code>`_:

* I've been working on a tool called `goast
  <https://github.com/jamesgarfield/goast>`_ off and on since they announced
  this proposal, that aims to to take advantage of the go generate tool.
* Just want to link a tool I've been using for generics-like functionality
  recently. It's still an early version, but I think it's promising
  https://github.com/ncw/gotemplate.
* this might be a way to implement data structure without interface […] I wrote
  this `tool <https://github.com/jteeuwen/templates>`_ a few days ago as an
  experiment, to demonstrate just that[…]

This is inevitable. Go programmers like the language and they want more, so
they explore meta programming. Unfortunately, the language authors don't want
to provide support in the language, so they have resorted to the worst kind of
macro implementation, which is text based. So much progress to reimplement C.
Not only that, but since you can run arbitrary commands to pre generate code,
users are not meant to run these custom preprocessors. Yay for littering our
source control systems with pre generated crap no one will ever bother reading!
Let's recap:

* Go 1.4 officially defines a code generation mechanism.
* The mechanism is external to the language.
* Since it is external, you could see the day where a tool is for instance
  Windows specific and won't run on Linux.
* The tools, being external, need to reimplement parsing and other basic
  facilities themselves. Not very DRY.
* And they have to produce source code too, which has to be stored because
  *normal* users are not meant to run these tools.
* At least users can look at the generated source code. One of the pains of
  C/C++ is figuring out what the macro expansion does, since by default this
  goes straight to the compiler. Much of the readability problems arise from
  programmers thinking the macro does something else.

I think Go authors could have provided something better, but at least they are
advancing their language.


Conclusion
----------

Meta programming has come to stay. If you have been conditioned to think macros
are bad because you have been spoon fed plenty of C/C++ horror stories, you
should think again. More and more languages implement macros. But do yourself a
favour and use a language which provides the more saner syntactic macros.
Unfortunately that means leaving Go, at least until they reach 2.0 (or later)
and improve their meta programming capabilities.

::
    $ nim c -r macros.nim
    macros.nim(1, 7) Error: A module cannot import itself

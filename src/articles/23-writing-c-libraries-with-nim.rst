---
title: Writing C libraries with Nim
pubDate: 2015-01-14 23:59
modDate: 2015-01-14 23:59
tags: languages, programming, nim, nimrod
---

Writing C libraries with Nim
============================

Context
-------

When you look at `reStructuredText tool support
<http://stackoverflow.com/questions/2746692/restructuredtext-tool-support>`_
you can notice that with the main reference implementation being written in
Python, all other implementations are in languages *equal* or greater than
Python: Java, Scala, Haskell, Perl, PHP, Nim. All these languages have in
common that the programmer doesn't have to manage memory manually, and given
the complexity of reStructuredText it is not a coincidence.

Since I dislike Python due to its brittleness, I didn't want to use a Python
solution for an `OS X Quick Look plugin
<https://en.wikipedia.org/wiki/Quick_Look>`_. Also, Python is very slow
compared to Nim, so I wrote `quicklook-rest-with-nim
<https://github.com/gradha/quicklook-rest-with-nim>`_ which just takes the work
done by the Nim developers in the `rst <http://nim-lang.org/rst.html>`_,
`rstast <http://nim-lang.org/rstast.html>`_ and `rstgen
<http://nim-lang.org/rstgen.html>`_ modules and packages as a Quick Look
renderer. Since everything is statically linked you can copy the plugin to any
machine and it should run without any other runtime dependency.

The Quick Look renderer is implemented in Objective-C and calls the Nim code
through C bindings. That's when I realised the Nim implementation could be
distributed as a plain C library for other languages to use, to avoid their
pain rewriting the wheel or running shell commands. For the Quick Look plugin I
was simply using two entry points exported to C with hard coded values, not
acceptable to other people. I started then to move the custom Nim code to a
separate module named `lazy_rest <https://github.com/gradha/lazy_rest>`_.
Exposing directly the Nim API didn't make sense for several reasons, so first I
`implemented a slightly different Nim API
<http://gradha.github.io/lazy_rest/gh_docs/v0.2.2/lazy_rest.html>`_ which I
think is nicer than the original, then proceeded to wrap it in a separate `C
API module
<http://gradha.github.io/lazy_rest/gh_docs/v0.2.2/lazy_rest_c_api.html>`_ which
is really another Nim file wrapping all of its procs with the `exportc pragma
<http://nim-lang.org/manual.html#exportc-pragma>`_.

The project was successful, when I `replaced the old rester module
<https://github.com/gradha/quicklook-rest-with-nim/issues/42>`_ with
``lazy_rest`` I dropped several brittle shell scripts and external nim compiler
invocations from the project and simply dragged the C files into the Xcode
project. This was pleasantly easy. The refactoring of the original
reStructuredText modules into `lazy_rest
<https://github.com/gradha/lazy_rest>`_ wasn't that easy though, I did hit some
problems or annoyances. This post is going to enumerate the issues I found, in
case you would like to do the same with other Nim code.


Namespaces and identifiers
--------------------------

Nim compiles to C, but most of the identifiers will have mangled C names you
usually don't care about.  Looking at the code found in the ``nimcache``
directory you can get an idea of the mangling pattern (which is in any case not
part of the public API and subject to change with each Nim version):

```c
…
N_NIMCALL(NimStringDesc*, saferststringtohtml_235288)(…
N_NIMCALL(NimStringDesc*, saferstfiletohtml_235656)(…
N_NIMCALL(NimStringDesc*, sourcestringtohtml_235723)(…
…
```

The mangling is done to avoid having linker errors due to two symbols being
named the same. Especially necessary for Nim where you can overload procs or
have two procs named the same living in separate modules. When you use the
`exportc pragma <http://nim-lang.org/manual.html#exportc-pragma>`_ the compiler
won't mangle the name, so you have to pick a good one. The API of ``lazy_rest``
is really small, but still I decided to use the typical Objective-C pattern of
prefixing all symbols with two letters.


Memory handling
---------------

Memory handling was obviously going to be a problem. C is managed manually, Nim
has a garbage collector. Language bindings for any programming language always
have these issues when the memory management is different, especially since the
languages communicating are usually not aware of each other. Memory passed in
from C to Nim is just a `cstring
<http://nim-lang.org/manual.html#cstring-type>`_, that's fine because it can be
converted to a Nim ``string``. However, what do we do with a Nim proc which
returns a ``string`` to C? Strings in Nim are implicitly convertible to
``cstring`` for convenience of C bindings, but what happens to their memory?
Who handles that?

The manual mentions the built in procs `GC_ref()
<http://nim-lang.org/system.html#GC_ref>`_ and `GC_unref()
<http://nim-lang.org/system.html#GC_unref>`_ can be used to keep the string
data alive. That means that the C code calling this API would have to know
about freeing the memory too. Instead I decided to store the result in a global
variable. This forces the string to not be freed even when calling other Nim
code which could trigger a garbage collection, and it is easier on the C
programmer for the common use of one shot reStructuredText transformations. The
potential memory copying for other cases could be reviewed in the future
whenever ``lazy_rest`` gains a user base greater than one (me).


Exporting types from the Nim standard library
---------------------------------------------

Part of the configuration/input options of ``lazy_rest`` are passed in through
a `StringTableRef <http://nim-lang.org/strtabs.html>`_. These type was named
``PStringTable`` in Nimrod 0.9.6, and unfortunately `it is not possible to
export such symbols <https://github.com/Araq/Nim/issues/1579>`_.  The typical
usage of this type is to store configuration options from a file or memory
string, so instead I provided `lr_set_global_rst_options
<http://gradha.github.io/lazy_rest/gh_docs/v0.2.2/lazy_rest_c_api.html#lr_set_global_rst_options>`_.
C users can create an in memory string with the necessary configuration options
and let the Nim code parse that.

Not very optimal, but this is not performance critical. Typically you will call
this once before any other reStructuredText generation.


Export enums and constants
--------------------------

The Nim language doesn't allow `exporting enums or consts to C
<https://github.com/Araq/Nim/issues/826>`_. This is quite a bummer. For
``lazy_rest`` I did add the `lconfig module
<http://gradha.github.io/lazy_rest/gh_docs/v0.2.2/lazy_rest_pkg/lconfig.html>`_
which contains several constants mapping to strings used for ``StringTableRef``
configuration objects. C users have to look at the documentation and duplicate
their own hard coded strings.

I suggested at some point `adding an emit header pragma
<https://github.com/Araq/Nim/issues/905>`_. This pragma would work in a similar
way to the `emit pragma <http://nim-lang.org/nimc.html#emit-pragma>`_ but
instead of generating C code it would allow you to add lines to the final
header generated by the Nim compiler. With such pragma I could write a macro to
wrap all those constants and let them pass through to the compiler while at the
same time generating extra header lines.

Recently Nim 0.10.2 was released and it also provides a way to write to a file
from a macro. Macros happen at compile time, likely before any C header is
generated, but I think a band aid for this issue could be to generate manually
an additional C header in memory and write it to the ``nimcache`` directory.
Maybe in the future I'll try this.


Errors and exception handling
-----------------------------

Callback exception tracking
---------------------------

Threads
-------


::
    $ nim c -r macros.nim
    macros.nim(1, 7) Error: A module cannot import itself

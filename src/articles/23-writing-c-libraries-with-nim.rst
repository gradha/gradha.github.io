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
the complexity of reStructuredText that doesn't seem to be a coincidence. This
may have slowed down adoption of reStructuredText compared to `Markdown
<http://daringfireball.net/projects/markdown/>`_. Markdown started as a Perl
script, but its simplicity led to `many C libraries
<https://github.com/hoedown/hoedown>`_, and even a `standarization attempt
<http://commonmark.org>`_, not without `typical drama
<http://blog.codinghorror.com/standard-markdown-is-now-common-markdown/>`_.
Wouldn't it be nice to have a C library for reStructuredText?

Since I dislike Python due to its brittleness and slow speed, I didn't want to
use a Python solution for an `OS X Quick Look plugin
<https://en.wikipedia.org/wiki/Quick_Look>`_. I wrote `quicklook-rest-with-nim
<https://github.com/gradha/quicklook-rest-with-nim>`_ which just takes the work
done by the Nim developers in the `rst
<https://github.com/Araq/Nim/blob/80b83611875383760da40d626a516e794e1245e7/lib/packages/docutils/rst.nim>`_,
`rstast <http://nim-lang.org/rstast.html>`_ and `rstgen
<http://nim-lang.org/rstgen.html>`_ modules and packages it as a Quick Look
renderer. Everything is statically linked, you can copy the plugin to any
machine and it should run without any other runtime dependencies (note: `some
unknown bug <https://github.com/gradha/quicklook-rest-with-nim/issues/48>`_
prevents it from working on Yosemite when installed in a home directory, but
works fine form a system folder).

The Quick Look renderer is implemented using the default Objective-C Xcode
template modifying it to call the Nim code through C bindings. That's when I
realised the Nim implementation could be distributed as a plain C library for
other languages to use, to avoid their pain rewriting the wheel or running
shell commands. For the Quick Look plugin I was simply using two entry points
exported to C with hard coded values, not acceptable to other people. I started
then to move the custom Nim code to a separate module named `lazy_rest
<https://github.com/gradha/lazy_rest>`_.  Exposing directly the Nim API didn't
make sense for several reasons, so first I `implemented a slightly different
Nim API <http://gradha.github.io/lazy_rest/gh_docs/v0.2.2/lazy_rest.html>`_
which I think is nicer than the original, then proceeded to wrap it in a
separate `C API module
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
case you would like to make some other Nim module available to C users.


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
won't mangle the name, so you have to pick a good unique one. The API of
``lazy_rest`` is really small, but still I decided to use the typical
Objective-C pattern of prefixing all symbols with two letters.


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

.. raw:: html

    <center>
    <a href="http://arcturus127.tistory.com/831"><img
        src="../../../i/memory_handling.jpg" alt="Stuff is hard"
        style="width:100%;max-width:750px" align="center"
        hspace="8pt" vspace="8pt"></a>
    </center>

The manual mentions the built in procs `GC_ref()
<http://nim-lang.org/system.html#GC_ref>`_ and `GC_unref()
<http://nim-lang.org/system.html#GC_unref>`_ can be used to keep the string
data alive. That means that the C code calling this API would have to know
about freeing the memory too. Instead I decided to store the result in a global
variable. This forces the string to not be freed even when calling other Nim
code which could trigger a garbage collection, and it is easier on the C
programmer for the common use of one shot reStructuredText transformations.
Improvements can be reviewed in the future whenever ``lazy_rest`` gains a user
base greater than one (me).

One thing worth mentioning here too is that conversions between ``string`` and
``cstring`` are `not always correct
<https://github.com/Araq/Nim/issues/1577>`_. A ``nil`` ``string`` won't convert
to a ``nil`` ``cstring``. One way to deal with this is `wrapping the string to
cstring conversion
<https://github.com/gradha/badger_bits/blob/5dcc623d1fd5b8232a133370e068b1e3928f56bc/bb_system.nim#L135>`_
to check explicitly for ``nil``.


Exporting types from the Nim standard library
---------------------------------------------

Part of the configuration/input options of ``lazy_rest`` are passed in through
a `StringTableRef <http://nim-lang.org/strtabs.html>`_. These type was named
``PStringTable`` in Nimrod 0.9.6, and unfortunately `it is not possible to
export such symbols <https://github.com/Araq/Nim/issues/1579>`_.  The typical
usage of this type is to store configuration options from a file or memory
string, so instead I provided `lr_set_global_rst_options()
<http://gradha.github.io/lazy_rest/gh_docs/v0.2.2/lazy_rest_c_api.html#lr_set_global_rst_options>`_.
C users can create an in memory string with the necessary configuration options
and let the Nim code parse that.  Not very optimal, but this is not performance
critical. Typically you will call this once before any other reStructuredText
generation.

Something which could be a deal breaker for some people writing C libraries is
the fact that `Nim doesn't export type fields
<https://github.com/Araq/Nim/issues/1189>`_. To work around this limitation you
can export setters and getters. If your fields are primitive types this
involves an extra function call, which doesn't look very appealing. For Nim
types like strings you would have to implement the setters and getters anyway.
The ``lazy_rest`` API I export is mostly an opaque render-and-forget approach
to the many internal types used for parsing and rendering, so it wasn't a
problem.


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

.. raw:: html

    <a href="http://www.idol-grapher.com/1399"><img
        src="../../../i/nimc_exceptions.jpg"
        alt="Plus there is no API"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>
    </center>

Exceptions are something else C doesn't have. Nim procs like
`rst_string_to_html()
<http://gradha.github.io/lazy_rest/gh_docs/v0.2.2/lazy_rest.html#rst_string_to_html>`_
will throw exceptions on error, so how does the C binding deal with that? The C
API module uses `Nim's effect system
<http://nim-lang.org/manual.html#effect-system>`_ for exception tracking. All
the procs are annotated with the ``{.raises: [].}`` pragma. This pragma tells
the compiler that no exception should be raised out of the proc, if there is
any potentially being raised the code won't compile, and you have to add the
appropriate ``try/except`` combo somewhere to appease the compiler.

Annotating procs with this pragma was very satisfying because after doing so
you realise how much stuff could potentially break. In other languages you are
left with the uncertainty that something could break and you have no catch for
it, which leads to typical *catch-all* blocks in several points of the code,
whether they are necessary or not. In Nim by default this could happen too, but
the empty ``raises`` pragma helps you go through each possible error.

Thanks to this pragma I am confident there won't be any exception leaving the
Nim domain. Such exceptions are treated for the C API as functions returning
``NULL`` instead of the expected value.  The errors are again stored in another
Nim global variable, and you can retrieve them with helper functions ending in
``_error`` like `lr_rst_string_to_html_error()
<http://gradha.github.io/lazy_rest/gh_docs/v0.2.2/lazy_rest_c_api.html#lr_rst_string_to_html_error>`_.


Callback exception tracking
---------------------------

Things get trickier with exception tracking when you involve callbacks. The
reStructuredText parser does have a callback to report warnings and errors to
the user. This callback can just ``echo`` information to the user, but it can
also raise an exception, aborting parsing. So you have a proc which uses a
callback, and the proc itself has been protected with all sort of
``try/except`` blocks to keep the callback from causing trouble. The Nim
compiler however disagrees, see this little snippet of code extracted from `an
issue I created <https://github.com/Araq/Nim/issues/1631>`_:

```nimrod
proc noRaise(x: proc()) {.raises: [].} =
  try: x()
  except: discard

proc callbackWichRaisesHell() {.raises: [EIO].} =
  raise newException(EIO, "IO")

proc use() {.raises: [].} =
  # doesn't compile even though nothing can be raised!
  noRaise(callbackWichRaisesHell)
```
This code looks and reads perfectly fine to me. Despite passing
``callbackWichRaisesHell`` around, the ``noRaise()`` proc won't ever raise
anything, but the example won't compile.  It will compile if you add a wrapper
layer around the callback, as Araq suggests in the GitHub issue, or if you
remove the empty ``raises`` pragma from the ``use()`` declaration (but that was
the point of using the pragma). The reported issue was closed, meaning it's OK
to have to patch correct code. I don't know yet if patching good code being the
correct answer to a problem is more sad than having a compiler unable to reason
about a ten line program.

In any case this wasn't a problem for the library, since I wanted the callbacks
to be usable from C there wasn't any point in making them raise exceptions (how
would you raise a Nim exception from C code?). I simply modified the
`TMsgHandler
<http://gradha.github.io/lazy_rest/gh_docs/v0.2.2/lazy_rest_pkg/lrst.html#TMsgHandler>`_
callback type to raise nothing and instead return the possible error as a non
nil string. This avoided the problem of callbacks raising any exceptions.

`Pig and elephant DNA just won't splice
<https://www.youtube.com/watch?v=RztfjHdM-pg>`_, so know also that callbacks
and exception tracking have issues together.


.. raw:: html

    <br clear="right">

Threads
-------

.. raw:: html

    <a href="http://dijkcrayon.tistory.com/297"><img
        src="../../../i/nimc_threads.jpg" alt="Threads are terrible"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>
    </center>

Parsing and generating HTML from text is pretty much sequential, you can't
start generating HTML for a random part of the document because the previous
part could modify its meaning. But we have multi processor machines everywhere,
so I thought it would be nice to provide a queue like API where you pass all
the files or strings you need to process (e.g. results of scanning the file
system) and let the multiple processors do their job, returning all the
results.

I started the `lqueues module
<https://github.com/gradha/lazy_rest/blob/50738869005675b99b039516e8a6031ddf151972/lazy_rest_pkg/lqueues.nim>`_
but couldn't get much done so I've left it disabled. I've done threading in C,
Java, Objective-C, and after the initial problems grasping deadlocks and race
conditions, nowadays I seem to be able to write at least non crashing code. But
I couldn't get Nim to do the same. My biggest gripe was with the fact that
threads can't touch other thread's variables, so they have to communicate
through shared globals. Or use channels/actors which presumably are not the
right solution (couldn't get the expected performance gains from them, but at
least they didn't crash).

Now that Nim 0.10.2 has been released there is hope in the new `parallel and
spawn statements <http://nim-lang.org/manual.html#parallel-spawn>`_, so I
should try that soon. Still, I don't understand what's the presumable benefit
of having threads unable to mutate state from other threads. To me it seems
more like it's easier to implement concurrency with immutable state, but then,
all the other languages I've worked with have mutability and they work
perfectly fine.

I don't think it's coincidence that there is pretty much zero Nim threaded code
out there being written outside of a few very specific cases. Again, not
something I'm worried now, but raises some questions for future work. At the
moment I can't see myself using Nim for GUI programming because all the
asynchronous patterns I know work with explicit mutability in mind. Neither the
new ``parallel`` and ``spawn`` statements nor ``async`` seem to be oriented for
GUI programming where you require callbacks for progress indication (and this
has to happen on the main thread, aka GUI thread) or cancellation.  Time to
learn new tricks I guess, maybe Nim is just so superior in this area I'm unable
to see the benefits yet. <insert needs-enlightment-here>

.. raw:: html

    <br clear="right">

Conclusion
----------

From the point of view of C library consumers, this project mostly works and is
viable. Users can go to the `lazy_rest releases section
<https://github.com/gradha/lazy_rest/releases>`_, download the pre generated C
sources packages and use without having to install or even know about Nim. For
generic C API libraries only the exportation of enums, constants and type
fields seems to be a glaring problem because mostly everybody will hit it.
Fortunately it doesn't seem to be hard to fix. As more Nim users try to export
their Nim code with a C API there will be more interest in fixing or improving
these issues.  And maybe in the not so distant future it will make sense to use
Nim as a perfect replacement for C when you want to write reusable libraries
for C users, or other languages using C bindings.


::
    $ nim c -r complex_callbacks.nim
    complex_callbacks.nim(9, 21) Info: instantiation from here
    complex_callbacks.nim(6, 41) Error: can raise an unlisted exception: IOError

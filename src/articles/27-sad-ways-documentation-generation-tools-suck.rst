---
title: Sad ways documentation generation tools suck
pubdate: 2015-08-11 22:45
moddate: 2015-08-11 22:45
tags: bureaucracy, user-experience, dash, design, tools, nim
---

Sad ways documentation generation tools suck
============================================

.. raw:: html

    <a href="http://www.all-idol.com/1587"><img
        src="../../../i/documenting.jpg"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>

My favourite thing to hack is documentation, it is easy to change, it gives the
best bang for the buck, and it is hard to do. Any monkey with a typewriter can
produce mountains of documentation (like this blog demonstrates), but writing
good documentation is very difficult. So difficult in fact that it is the most
neglected feature of any product. And just as software, it requires
maintenance. Nobody wants to do maintenance, no matter how important it is.
Still, creating, improving, and maintaining documentation is one of my secret
little pleasures. Documentation is in fact the ultimate programming language:
just like you program a CPU to perform some tasks, documentation programs the
brains of the readers to make them achieve impressive things. Or if poorly
written, crashes their expectations and dreams, *bricking* them forever,
possibly making them go away from your technically perfect software… nobody
knows how to use.

I don't think I've ever written the perfect documentation, but maybe I've come
close, little by little, retouching here and there, kind of like a painter who
never knows when the artwork is finished, because in the eyes of the creator
everything can still be improved.  I've written documentation for commercial
products, but along the years I've been contributing to free and open software
maybe the two most important documentation related improvements I've made were
to the `C game programming library Allegro <http://liballeg.org>`_ and the `Nim
programming language <http://nim-lang.org>`_. I'm not talking this time about
*the documentation itself* but about the tools and mechanisms to produce this
documentation. With time and distance an odd comparison and conclusion emerges
from my experience.  Let me introduce you to the respective tools.


The past
========

Allegro's makedoc
-----------------

The current Allegro uses `Pandoc <http://johnmacfarlane.net/pandoc/>`_ to build
its documentation, but in the past a little C `makedoc
<https://github.com/liballeg/allegro5/tree/09b024bacb9428a9cfa8feade7633b0402287186/docs/src>`_
command used to do the grunt work. ``makedoc`` started as a simple parser for a
weirdly hyperlinked text format. As `horrible as the format was (lol)
<https://github.com/liballeg/allegro5/commit/b9508287d74d0a660d9ed70a30503b52bbb4dbb8>`_
``makedoc`` made possible the miracle of generating from a single source file
`ASCII, HTML, TexInfo, RTF
<https://github.com/liballeg/allegro5/blob/09b024bacb9428a9cfa8feade7633b0402287186/docs/src/makedoc/makedoc.c>`_
and other derivative file formats like PDF which were made from the previous
ones. This happened in the times of `MS-DOS
<https://en.wikipedia.org/wiki/MS-DOS>`_ and `DJGPP
<http://www.delorie.com/djgpp/>`_.

Given the strict limitations of ``makedoc`` I have to say it was a terrific
success. I still remember how much fun I had when I added `the possibility of
cross referencing examples from the API documentation
<https://github.com/liballeg/allegro5/commit/68faf6b825a043805cc7a298ee1dff3e4c38097b>`_.
As any big library, Allegro contained a vast list of examples to showcase the
functionality, but examples and documentation lived in separate universes, far
from each other. The improvement added additional documentation building phases
where the examples would be scanned for symbols. Then this symbol database was
used to generate the chapter listing all the examples. With this, the
documentation *suddenly* was aware of examples, and therefore visible to
readers.

But even better, thanks to the symbol database whenever ``makedoc`` would
generate the documentation for any API it would scan this database and
automatically hyperlink the example showcasing its use. So if you had a
function ``draw_something()``, it would list all the examples which **used**
that API.  And since the mapping between API and examples wasn't necessarily
one to one, you could add manual cross references where appropriate.

The current Pandoc version doesn't do this, and it is a shame, but the
developers who continued maintaining Allegro certainly decided that the
externalization of the hacky custom documentation generator few wanted to touch
was worth their personal time. And I agree. If at the time I had known of tools
like Pandoc, instead of maintaining ``makedoc`` I would have likely created
scripts or tools to improve it with the features API documentation creation
requires.  An ugly source code with manual memory management, weird extensions
and backwards compatibility tricks (I don't remember **ever** breaking existing
docs) grown organically, manually maintained list of files to parse and build,
it finally met its end. A toast to you, ``makedoc``. I did learn a lot about
building documentation, and how it is vital for a project.


Nim's docgen
------------

Nim's documentation generation can be explained as the sum of two parts: an
extractor and a generator. The generator uses a custom `reStructuredText
<http://nim-lang.org/docs/rstgen.html>`_ format to create HTML or LaTeX output.
Documentation lives as comments embedded in the source file.  The extractor is
part of the compiler living in the `docgen.nim
<https://github.com/nim-lang/Nim/blob/9764ba933b08e9e04a145c922ab32bfa06cc7400/compiler/docgen.nim>`_
file. Using the compiler for API and comment extraction is the fastest way to
reuse code, but unfortunately makes changes to the documentation generation
tool a pain.  Araq has mentioned several times that docgen should  be split,
but who knows when that would happen. Or if the split `will
<https://github.com/nim-lang/Nim/issues/2757>`_ `cause
<https://github.com/nim-lang/Nim/issues/2341>`_ `even
<https://github.com/nim-lang/nimsuggest/issues/1>`_ `more
<https://github.com/nim-lang/nimsuggest/issues/6>`_ `problems
<https://github.com/nim-lang/nimsuggest/issues/3>`_.

.. raw:: html

    <a href="http://www.idol-grapher.com/1567"><img
        src="../../../i/missing_docs.jpg"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>

From the improvements I made to ``docgen`` maybe the most important one was
`predictable hyperlinks
<http://nim-lang.org/docs/docgen.html#html-anchor-generation>`_. The original
``docgen`` would scan the source code and generate hyperlinks using a counter:
the first API entry would be zero, the second one, etc, etc. Pretty horrible,
since that makes hyperlinks **dead by design**. Nobody is going to use them
knowing that at some point a new API or just a simple code refactoring can
break them. On the other hand, predictable hyperlinks make it possible to tell
somebody 'hey, loop this up **here**', rather than 'hey, open this huge
generated document and try to find whatever keyword I'm telling you about'.

Unlike with the Allegro community, which quickly embraced every new
documentation feature, I don't think these improvements were much appreciated
in Nim land.  The easiest way to verify something is good is when other people
use it. I did contribute new documentation adding hyperlinks showing *how it
should be done*, improved existing documentation (aka, maintaining), but other
developers didn't seem to care. The biggest advancement I saw was when other
contributors started quoting symbols so that words would ``show up in
monospaced font``. But rarely with a hyperlink.  It looks like the best Nim
documentation is the *non existant* documentation.

I had plans to improve ``docgen`` *at least* to the level of ``makedoc``, but
even better with **automatic** hyperlinks, checks against 404 (in case an API
changes), execution of embedded examples for implicit unit testing, generation
of `dash/zeal docsets <https://github.com/nim-lang/Nim/issues/1401>`_ (which I
had already started anyway), etc. However the environment slowly drained my
enthusiasm. Pull requests seemed an uphill battle and weirdly sometimes took
many weeks to review, while other changes were approved faster than you could
blink. Sometimes they were `ignored
<https://github.com/nim-lang/Nim/pull/1452>`_ despite `users requesting such
changes <https://github.com/nim-lang/Nim/issues/1136>`_. Other developers
usually ignored existing documentation styles, sometimes producing a final odd
mixture to read. I finally decided to stop contributing to Nim when `Araq
deliberately lost some improvements to the json module
<https://github.com/nim-lang/Nim/pull/1869>`_.  If contributions are to be
wasted like that on an arbitrary merge I prefer to waste my time elsewhere.


Third time's a charm?
---------------------

Since documentation is one of my obsessions I felt I had to do something when
so many people contributed `Nimble <https://github.com/nim-lang/nimble>`_
`packages <https://github.com/nim-lang/packages>`_ which rarely had any
documentation or even the most basic of READMEs. Believing that the pain of
generating and publishing documentation was to blame, I started
`gh_nimrod_doc_pages <https://github.com/gradha/gh_nimrod_doc_pages>`_ with the
hope that a mostly automatic command would alleviate the repulsion towards
documentation most programmers seem to experience. The ``gh_nimrod_doc_pages``
command was meant to be run after each software release and generate static
HTML files from the local source reStructuredText or MarkDown files, which
would then be uploaded to `GitHub Pages <https://pages.github.com>`_ on the
next commit.

And it does, but maybe it is not the best approach. Maybe I didn't `publicise
it enough <http://forum.nim-lang.org/t/460>`_, because very few people ended up
using it. Maybe instead of putting the burden on the documentation generator I
should have made it `integrate with Nimble
<https://github.com/gradha/gh_nimrod_doc_pages/issues/25>`_ (or Babel, as it
used to be named) so that users could generate the docs despite the original
developer not caring about them. Maybe it was too specific, who uses `GitHub
<https://github.com/>`_ when everybody is doing `BitBucket
<https://bitbucket.org>`_. In any case I consider it a practical failure, but
at least it helped me to document my own Nimble packages.

One of the features it does is scan the final HTML output and rename hyperlinks
in some cases. It is very nice to be able to have reStructuredText or MarkDown
documentation which refers to other such files. The question is, do you refer
to their source or to their final HTML versions? If you use the source, the
link in the GitHub visualization works, but end users generating the HTML
locally will get a broken link (they expect to link the HTML version instead).
If you use an HTML link you have a broken link for GitHub browsers. So
``gh_nimrod_doc_pages`` detects documentation source links and renames them to
HTML in the generated documentation. Then you can write links which work on
both sides, the online visualization and the final HTML output.

Being greedy I also wanted to integrate documentation with source code.
Wouldn't it be cool to have API ``procs`` have a *see source code* which would
take you to a local HTML version of the source code? Wouldn't it be even better
to have this HTML version with syntax highlighting **and** hyperlinks to other
symbols, either their documentation or their source code? That would be nice,
it would effectively turn all source code into a navigable HTML website.  But
something wasn't feeling right, even with patches here and there the design was
hard to maintain as I was writing the software. In the end, another dead
useless project more, I guess…


The elephant in the text
========================

The common feature of these three failed documentation generators (``makedoc``,
``docgen``, ``gh_nimrod_doc_pages``) is that they treat documentation as a
second class citizen. If you are a C programmer you have likely heard the
expression `first-class citizen
<https://en.wikipedia.org/wiki/First-class_citizen>`_, usually applied to a
functional coding style where you pass procs/methods to other procs/methods as
parameters.  The way documentation is treated as a second class citizen is easy
to see when you compare documentation to source code. Source code gets our
love, our tool support, our IDE integration.  Documentation? Meh, who cares,
only a bunch of lame old timers do that.  Besides, what does it mean for
documentation to be a first class citizen anyway?

All the three documentation generation tools  require you to specify the input
files the documentation is made of (``gh_nimrod_doc_pages`` scans automatically
for files, but this is a terrible illusion, internally it is still a ``proc``
processing items from a list one at a time without context).  Compare this to
how you build software in any modern programming language. In Nim you write
``nim c module.nim``. And that's it, because the source is king, the source
says ``import strutils``, and the Nim compiler will understand that it has to
look for the `strutils module <http://nim-lang.org/docs/strutils.html>`_,
process it, and link it together.  Even good old Objective-C got a new `@import
modules syntax <http://stackoverflow.com/a/23146109/172690>`_, because as a
programmer if you need to specify in the source code **and** in the build tool
that you need to link something, you are repeating yourself. So the natural
place is for the source code to dictate what the build tool has to do.

How does this relate to documentation? You should be able to write ``build_docs
some_file.txt`` and that's it. The build tool should start processing the text
file and automatically detect hyperlinks. Not only would the hyperlinks be
verified, but they would tell the build tool to add yet another file into the
build process, generating it along. Just like your Java or Nim projects!
Simple, isn't it? Well, why the hell aren't we doing that? Of course this
increases the complexity of the documentation tool, since it needs to have
different steps in scanning, parsing and linking everything together, but we
have decades of experience doing that with source code, which is presumably
harder to make sense of.  Once you change your mindset into understanding that
documentation is *yet another kind of source code project* you start treating
it as it deserves. Now you can provide static analysis (no more dead
hyperlinks!) and even more exotic features like code hyperlinks, pointing to
examples or implementation files and vice versa. It is just a language more, so
there is no problem to integrate it with your IDE.


The uncertain future
====================

While I haven't officially killed ``gh_nimrod_doc_pages`` yet, I'm still
deciding whether I should continue it or let it die. It is possible to
implement some of these features as I've been doing now, parsing the generated
HTML and processing it further, but some things will really be difficult or
impossible to do without collaboration from ``docgen`` or whatever springs up
in the future. What follows is a list of the features I was planning to
implement. May you pick this up and use it for good.


Feature: no manual file lists, automatic dependencies
-----------------------------------------------------

As said earlier, you should be able to write ``build_docs some_file.txt``. This
file you are processing should be a `welcome file
<https://docs.python.org/2/>`_ with further links to other parts of the
documentation. The documentation generator will detect the links to external
files and process them too. Manual file lists or file patterns should be used
only if for some reason you need to include/exclude a set of files for some
reason.

Being able to build all the documentation from a single entry point avoids
errors and makes it easy to verify that everything is actually available to the
user in the final navigation. There is no point in creating documentation if
you never ever link to it and nobody sees it.


Feature: strong/non broken links
--------------------------------

Related to the previous one, when a document file links another one, it should
use a hyperlink anchor which is valid. In essence this is like programming in C
and calling the ``printf()`` function after you have included the appropriate
header file, the compiler will validate that the ``printf()`` symbol is
available. Since a hyperlink already tells you what file it is referring to,
that one gets imported, built together (see previous feature) and validated for
anchors. This gives you the peace of mind that you are not referring to
something that has moved.

Circular dependencies are easily solved because a hyperlink doesn't immediately
*require* the other file to be processed nor does it have to know anything
about it unlike statically typed programming languages. The referred file will
be processed together, but link validation can be done at a later stage: first
all referred files are imported if not already cached and scanned for symbols,
then hyperlinks are resolved and validated when no more files are to be added
to the build. Luckily there is no such a thing as mutually recursive types in
documentation.


Feature: internal symbols
-------------------------

Also, you shouldn't be linking to the final HTML output anchor, you should be
linking to an internal documentation **symbol**.  Does this symbol *resolve* to
an HTML anchor? Yes, but you don't care how it looks, you are referring to an
element inside your documentation. Of course, generated links should be easily
predictable by documentation users.  It is actually OK if you follow the syntax
of a typical hyperlink for internal symbols, but it is terribly bad if you use
the HTML output anchor as the source link. See this reStructuredText example::

    See `See Düsseldorf, Lörick <d%C3%BCsseldorf.html#L%C3%B6rick>`_
    for info.

That's terrible for you as a documentation creator. Firs problem is that your
hyperlink goes to an HTML file. What if you want to generate a PDF? I guess
it's OK if you use an HTML to PDF conversion tool, but we are in 2015 and maybe
you should expect your toolchain to be able to produce PDFs directly. Second
problem is that since you have already lowered your hyperlink to HTML you
require to use ugly percent encoded anchors. Instead you should be able to
write::

    See `See Düsseldorf, Lörick <düsseldorf.rst#Lörick>`_ for info.

Our hypothetical documentation generation tool will understand this to be an
internal anchor, bring in the ``düsseldorf.rst`` file for processing, validate
the ``Lörick`` internal symbol and resolve it to a valid HTML anchor in the
last generation step.


.. raw:: html

    <a href="http://mang2goon.tistory.com/379"><img
        src="../../../i/hyeyeon_approval.jpg"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>


Feature: example code renderization and symbol detection
--------------------------------------------------------

When you write documentation about an API it can sometimes help to see the
source of examples using the API to which you can navigate and see the API
usage in full context. Your documentation system should have a way to tell the
build tool to *scan* external files and look for the used symbol the build a
list of files. Of course, as mentioned in the first rule, this means the
example files' source code get also built and rendered with syntax highlighting
so that you can view everything inside your documentation browser. Bonus points
if your source code itself is also hyperlinked and clicking on a symbol in the
rendered code will lead you to the API documentation for that symbol.

You should be able to do this today too, I was doing most of this feature
in 2005. In the snow. In C. Uphill. OK, I used external tools and extra build
steps, but only because I didn't know better at the time.


Feature: embedded example validation
------------------------------------

Sometimes rather than looking at an example it is good enough to see just a few
lines of code. This is done quite a lot in `tutorials
<http://nim-lang.org/docs/tut1.html>`_. Unfortunately these snippets of code
are not verified and tend to `bit rot
<https://github.com/nim-lang/Nim/issues/2928>`_. The way I was planning to
solve this in Nim was to add two extra sections before and after the source
code to showcase. The build tool should concatenate all three blocks of source
code (pre + body + post) into a temporary source file and build it to scan for
errors and refuse to continue building documentation until everything is fixed.
Embedded code without pre/post blocks would not be tested of course.

The final output would by default show only the body block, but for interactive
outputs like HTML a JavaScript button would unfold/fold the pre/post blocks to
let the reader see what else was needed to prepare those few lines of source
code if needed. As a bonus you get unit testing for the parts of the API you
happen to document like this, and you could let the example *run* and embed its
output in the generated documentation, saving you the manual duplication
typical in such examples.

Since these validations are expensive you may want to disable them for the
typical documentation generation run, or maybe add a ``test_examples`` command
so that they can be invoked in a continuous integration server after each
commit.

Feature: forward declarations
-----------------------------

The documentation generator builds internally a symbol database for each
included file. Well, make it public, generate a ``docindex.sqlite`` file or
something. Let users include this file or refer to it in your documentation for
cross library/API references. Go to the main `midnight_dynamite module
documentation
<https://gradha.github.io/midnight_dynamite/gh_docs/master/midnight_dynamite.html>`_
and look at the sad, very sad imports section. Click that `os module link
<https://gradha.github.io/midnight_dynamite/gh_docs/master/os.html>`_. Not
there? Try then `streams module
<https://gradha.github.io/midnight_dynamite/gh_docs/master/streams.html>`_ then.
What, 404 too? Seriously, why? A minimal start would be to know that these
modules are not available and *remove* the hyperlink. After all, what good does
it do to frustrate users?  Leave the reference as plain text and avoid the
pain.

Thanks to this hypothetical ``docindex.sqlite`` file (`wink wink
<http://nim-lang.org/docs/docgen.html#index-idx-file-format>`_) other people
creating public libraries can refer to the standard library of your language
and hyperlink it without problem. In the main documentation index (or maybe as
a command line switch or configuration file) you could write something like::

    refdoc stdlib http://nim-lang.org/docs/docindex.sqlite

The URL tells the builder to download and parse that file, then make it
available with the optional ``stdlib`` prefix. Optional means that if there is
no symbol collision you can write the reference like usual. If there are two
symbols with the same name, the build tool will warn you and force you to write
``stdlib.symbol`` instead of just ``symbol`` in your hyperlinks. Just like
normal source code! How amazingly original!


Feature: documentation macros
-----------------------------

No software wish list is complete until you request the software itself to be
programmable. The features mentioned above are directly aimed at the specifics
of documenting software API references, which heavily depend on hyperlinks. But
sometimes you could want to document something like a file format. I've `done
that before for JSON protocols
<https://github.com/gradha/OpenIrekia-iOS/blob/master/docs/server_protocol.txt>`_
and I have to say it is a `pain in the ass
<https://github.com/gradha/OpenIrekia-iOS/blob/master/docs/server_protocol.txt#L118-L126>`_
with normal documentation syntax to generate internal links and such. Normal
file formats are not meant for that, which is the reason why tools like
`Swagger <http://swagger.io>`_ are so popular, because at some point a tool
generates HTML and saves you all the duplication of symbols, tables of contents
and such, producing the best possible output.

Can typical documentation file formats support such extensibility? I don't
know, which is why I'm putting a big question mark here. I've seen a few which
allow extensibility but usually in a very limited fashion, or in a way that is
completely external to the currently processed file (i.e. run this command and
fetch the output). Would it be possible to write some kind of macro system
where you could generate the documentation's AST and programatically build all
those little internal hyperlinks and repeated structures? Maybe, but then you
will have to fight users wanting each their own language. Unless you settle for
JavaScript… yuck. Well, at least we can dream.


Conclusion
==========

It is not a wonder that making a generic tool supporting all these features
would be a nightmare and would leave everybody unhappy. Which is the reason we
don't see such tools, they have to be implemented specifically for each
programming language that wants such tight documentation integration. Is your
favourite programming language helping or getting in the way?

::
    $ nim doc2 midnight_dynamite.nim
    lib/pure/parsecfg.nim(20, 4) Error: cannot open 'doc/mytest.cfg'
    midnight_dynamite.nim(176, 10) Error: undeclared identifier: 'TCfgParser'
    midnight_dynamite.nim(177, 7) Error: type mismatch: got ()
    but expected one of:
    system.open(f: var File, filehandle: FileHandle, mode: FileMode)
    system.open(f: var File, filename: string, mode: FileMode, bufSize: int)
    system.open(filename: string, mode: FileMode, bufSize: int)

    midnight_dynamite.nim(179, 13) Error: undeclared identifier: 'next'
    midnight_dynamite.nim(179, 17) Error: undeclared identifier: 'next'
    midnight_dynamite.nim(179, 17) Error: expression 'next' cannot be called
    midnight_dynamite.nim(180, 11) Error: undeclared identifier: 'kind'
    midnight_dynamite.nim(180, 11) Error: expression '.' cannot be called
    midnight_dynamite.nim(181, 8) Error: undeclared identifier: 'cfgEof'
    midnight_dynamite.nim(181, 8) Error: internal error: cannot generate code for: cfgEof
    No stack traceback available
    To create a stacktrace, rerun compilation with ./koch temp doc2 <file>

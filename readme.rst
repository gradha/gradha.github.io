===========================
Rants from the Ballmer Peak
===========================

This repository contains the source code for the blog at
http://gradha.github.io hosted by `GitHub <https://github.com>`_. The blog
contains the personal opinion of `Grzegorz Adam Hankiewicz
<src/static/about.rst>`_ and is generated with the `ipsum genera
<https://github.com/dom96/ipsumgenera>`_ static blog generator written in the
`Nim programming language <http://nim-lang.org>`_.


License
=======

The content of this blog is `copyrighted by Grzegorz Adam Hankiewicz
<license.rst>`_ unless stated otherwise and you have no permission to replicate
it anywhere else. I can however be bribed easily.

Most of the weird modified images featured in the articles have usually nothing
to do with the text and are there purely for aesthetic or parody reasons.
Credits go to their original authors, which is usually expressed as a hyperlink
to the original source those images were retrieved from. In any case these
modified images should fall under `fair use
<https://en.wikipedia.org/wiki/Fair_use>`_ due to being parodies. Even so if
you feel it's not OK to use them tell me and I'll remove them.


Local generation
================

To generate the blog locally, install the `Nim compiler
<http://nim-lang.org>`_. Then use `Nim's nimble package manager
<https://github.com/nim-lang/nimble>`_ to install the `ipsum genera
<https://github.com/dom96/ipsumgenera>`_ blog generator::

    $ nimble update
    $ nimble install ipsumgenera

Now you can check out the source code and create a local version::

    $ git clone https://github.com/gradha/gradha.github.io.git
    $ cd gradha.github.io/src
    $ ipsum
    $ open ../index.html

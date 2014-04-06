===========================
Rants from the Ballmer Peak
===========================

This repository contains the source code for the blog at
http://gradha.github.io hosted by `GitHub <https://github.com>`_. The blog
contains the personal opinion of `Grzegorz Adam Hankiewicz
<src/static/about.rst>`_ and is generated with the `ipsum genera
<https://github.com/dom96/ipsumgenera>`_ static blog generator written in the
`Nimrod programming language <http://nimrod-lang.org>`_.

License
=======

The content of this blog is `copyrighted by Grzegorz Adam Hankiewicz
<license.rst>`_ unless stated otherwise.

Local generation
================

To generate the blog locally, install the `Nimrod compiler
<http://nimrod-lang.org>`_. Then use `Nimrod's babel package manager
<https://github.com/nimrod-code/babel>`_ to install the `ipsum genera
<https://github.com/dom96/ipsumgenera>`_ blog generator::

    $ babel update
    $ babel install ipsumgenera

Now you can check out the source code and create a local version::

    $ git clone https://github.com/gradha/gradha.github.io.git
    $ cd gradha.github.io/src
    $ ipsum
    $ open ../index.html

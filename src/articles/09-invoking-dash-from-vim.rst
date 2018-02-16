---
title: Invoking Dash from the command line Vim
pubdate: 2014-02-15 10:06
moddate: 2014-02-15 10:06
tags: programming, tools, nim, dash, objc
---

Invoking Dash from the command line Vim
=======================================

`Dash is a documentation browser and snippet manager for macosx
<http://kapeli.com/dash>`_ which is much better than Xcode's documentation
tool, and also allows one to browse other documentations. You can for instance
download `a Dash docset for Nim <http://forum.nim-lang.org/t/330>`_ and
you will be able to instantly search `Nim's <http://nim-lang.org>`_
documentation. A global keyboard shortcut displays Dash on top of whatever you
are doing, you type stuff, then can hide it and continue.

My editor of choice is `Vim <http://www.vim.org>`_ as invoked from the terminal
command line, either the version which comes with MacOSX or one from `MacPorts
<http://www.macports.org>`_. Pressing the upper case ``K`` letter will make Vim
invoke the man page viewer for whatever word your cursor is on top of. Wouldn't
it be nice to have this integration with Dash too? Here's what I added to my
``.vimrc`` file:

::
    " Dash integration for objc and nimrod.
    command! DashNim silent !open -g dash://nimrod:"<cword>"
    command! DashDef silent !open -g dash://def:"<cword>"
    nmap K :DashDef<CR>\|:redraw!<CR>
    au FileType nim  nmap K :DashNim<CR>\|:redraw!<CR>

What I define in these four lines of Vim configuration are two commands,
``DashNim`` and ``DashDef``. The latter is bound to the upper case ``K`` letter
by default. The former is bound to the same letter but only if the file type of
your current Vim buffer is of Nim type, which allows for more specific
keyword matches.  In Dash I have set up the default docs I search with the
``def:`` shortcut (see Dash's preferences).

With Dash installed, you can call the ``open`` command passing the ``dash://``
style URL with additional parameters, and there you have it, Vim will query
Dash for the word your cursor is on top. The additional ``redraw`` commands are
to avoid having to wait to press Enter when the viewer is invoked and to redraw
the current screen afterwards. That's because Vim expects the external program
to draw stuff on the screen, and by default waits for user interaction.

Having said this, when you look at Dash's integration preferences, for Vim it
points to https://github.com/rizzatti/dash.vim#readme. I didn't manage to get
that working, plus I don't understand why I have to install several software
packages for what amounts to a few configuration lines in your ``.vimrc`` file.
Maybe it offers more, but quick lookups are all I need for the moment.


::
    <K>
    No manual entry for nmap

    El intérprete de órdenes devolvió 1

    Pulse INTRO o escriba una orden para continuar

---
title: The problem with Linux packages
pubDate: 2014-12-14 18:15
modDate: 2016-11-27 22:16
tags: tools, bureaucracy, design, static-linking
---

The problem with Linux packages
===============================

$ apt-get install `asciidoc <http://asciidoc.org>`_

…

Recommended packages:
* sbcl lisp-compiler
The following NEW packages will be installed:
* asciidoc cl-asdf clisp common-lisp-controller dblatex dbus defoma doc-base docbook docbook-dsssl docbook-utils docbook-xml docbook-xsl docbook-xsl-doc-html ed feynmf fontconfig-config ghostscript gsfonts gsfonts-x11 jadetex lacheck latex-beamer latex-xcolor lesstif2 libavahi-client3 libavahi-common-data libavahi-common3 libboost-regex1.42.0 libcups2 libcupsimage2 libdbus-1-3 libffcall1 libfont-freetype-perl libfontconfig1 libfreezethaw-perl libgs8 libicu44 libjasper1 libjbig2dec0 libjpeg62 libkpathsea5 liblcms1 liblqr-1-0 libltdl7 libmagick++3 libmagickcore3 libmagickwand3 libmldbm-perl libopenjpeg2 libosp5 libostyle1c2 libpaper-utils libpaper1 libplot2c2 libpng12-0 libpoppler5 libpstoedit0c2a libruby1.8 libsgmls-perl libsigsegv0 libsource-highlight-common libsource-highlight3 libsp1c2 libtiff4 libxml2-utils libxp6 libxslt1.1 lmodern luatex openjade pgf poppler-data poppler-utils preview-latex-style prosper ps2eps pstoedit purifyeps realpath ruby ruby1.8 sgml-data sgmlspl source-highlight sp tex-common texlive texlive-base texlive-bibtex-extra texlive-binaries texlive-common texlive-doc-base texlive-extra-utils texlive-font-utils texlive-fonts-recommended texlive-fonts-recommended-doc texlive-generic-recommended texlive-latex-base texlive-latex-base-doc texlive-latex-extra texlive-latex-extra-doc texlive-latex-recommended texlive-latex-recommended-doc texlive-luatex texlive-math-extra texlive-metapost texlive-metapost-doc texlive-pictures texlive-pictures-doc texlive-pstricks texlive-pstricks-doc texpower texpower-manual tipa ttf-dejavu-core vim-addon-manager xindy xindy-rules xmlto xpdf xsltproc

0 upgraded, 122 newly installed, 0 to remove and 0 not upgraded.

Need to get **510 MB** of archives.

After this operation, **924 MB** of additional disk space will be used.

Do you want to continue [Y/n]? n

Abort.

---------

And people still think I'm a lunatic when I tell them to `build statically
linked binaries <../../2013/08/users-prefer-static-linking.html>`_ since that
will increase the binary footprint… the same people who happily install
gigabytes of optional dependencies without a blink. Somehow I feel sorry for
the ``lisp-compiler`` package to not have hopped on the bloat bandwagon.

**UPDATE**: Yes, `I know you can install asciidoc without all that bloat
<http://askubuntu.com/questions/356604/why-does-asciidoc-have-texlive-as-a-dependency>`_.
No, I'm not advocating to statically link against texlive. Yes, 99% of users
stick to apt-get's defaults (`or any software, really
<http://www.mylinuxrig.com/post/9120015925/linux-and-the-tyranny-of-the-default>`_)
and install packages they won't ever use.

.. raw:: html

    <center><a href="http://darkablaxx.tistory.com/69"><img
        src="../../../i/asciidoc_debian.jpg"
        alt="Some kpop idols know things you wouldn't believe"
        style="width:100%;max-width:600px"
        hspace="8pt" vspace="8pt"></a></center><br>

::
    $ nuke sprawling-bloat --from-orbit
    -bash: nuke: command not found

---
title: Testing installation instructions
pubDate: 2014-04-27 12:42
modDate: 2014-04-27 12:42
tags: nimrod, testing
---

Testing installation instructions
=================================

Unit testing seems like the most recent and popular `e-penis
<http://www.urbandictionary.com/define.php?term=e-penis>`_ game in the
industry: not only can you brag about useless stuff in big numbers (*look, we
have more than thousand unit tests for stuff nobody uses!*), but you can push
this data to upper management and they will pat you on your back for it. Not
because they find that unit testing is useful for software, promotes sane
development approaches, documents working code and corner cases/bugs, or in
general requires some interest in output from code monkeys.  No, they like unit
testing because it can be represented as a number associated with specific
developers, and the human resources department can compare these numbers over
time to increase salaries. `It's lines of code all over again, and everybody
loves it
<http://stackoverflow.com/questions/3769716/how-bad-is-sloc-source-lines-of-code-as-a-metric>`_.

Except for very specific kinds of software, unit testing is likely not very
useful to end users. In fact, when you test something **which matters** to end
users, it stops being called unit testing, and it is called `integration
testing <https://en.wikipedia.org/wiki/Integration_testing>`_ or `validation
testing
<https://en.wikipedia.org/wiki/Verification_and_validation_(software)>`_. This
is serious crap. Like keeping virtual machines which simulate the **first
installation** by the user on an otherwise clean state OS (so you know if that
3rd party library you recently added requires an additional DLL install). Or if
your software doesn't run in a virtual machine, keeping the hardware machines
(with spares) to keep testing newer versions. These kinds of testing tend to
take days compared to minutes in the software development.

Unfortunately they are a pain in the ass to set up, so even important projects
don't care about them and depend on beta test… er, users, to tell them
something has gone wrong. One critical point of many open source projects which
goes untested is: installation instructions. You know, the little sequence of
commands which tells you what to do to actually get the source code, build it,
and maybe install it. Either in binary or source form, installation
instructions are the first step for your users and other potential developers
to know about you. Bad installation instructions are the equivalent of a web
page which never loads: users will look elsewhere.

Testing dropbox_filename_sanitizer
----------------------------------

For this article I'll be using my own `dropbox_filename_sanitizer project
<https://github.com/gradha/dropbox_filename_sanitizer>`_ because pointing
errors in other people's software is too easy and doesn't enrich me. This
project also offers a nice range of things to test: there is a stable source
code installation, a development source code installation, and a pre built
binary installation. In addition the program is implemented with the `Nimrod
programming language <http://nimrod-lang.org>`_ which `recently released
version 0.9.4
<http://nimrod-lang.org/news.html#Z2014-04-21-version-0-9-4-released>`_. A
programming language in development may well render the source code useless
between versions, so we will have to expand the source code tests to cover one
using the stable compiler release and another using the unstable one. If my
math is not wrong, that's more than a single test, enough to impress your mom.

The platforms to test are macosx and linux. You can test Windows too, you can
do nice things with `VirtualBox alone
<https://oracleexamples.wordpress.com/2011/08/12/virtualbox-script-to-control-virtual-machines/>`_
or `with additional tools like Vagrant
<http://www.vagrantup.com/blog/feature-preview-vagrant-1-6-windows.html>`_, but
I don't own any Windows licenses and have little interest in getting one.
Since both target platforms are unix-like, we will be able to reuse the
scripting for both using `bash <https://www.gnu.org/software/bash/>`_ or
whatever shell used by the systems used to run the test cases (if you don't
control the environment, like on virtual host). We won't go the full virtual
machine route because it is time expensive, and also because we can easily
emulate nearly clean state environments through additional users.

The strategy then is to create a separate user for testing in your own machine.
This user won't have any of the installed dependencies required for
installation, and we will install everything in specific directories which can
later be erased to prevent them from polluting future tests. If the software
you are using requires installation in global paths, you need a virtual machine
then anyway. Certainly you don't *trust* software to have a good uninstallation
mechanism, do you?

.. raw:: html

    <img
        src="../../../i/nuke_orbit.jpg"
        alt="The only sane approach to software testing"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt">

A separate user account on the machine is easier to nuke from orbit should
anything go wrong, but it also helps to keep yourself honest about the testing
environment. If you run the tests as your development user many little
environment changes can creep in and alter the tests. First we will make a
Nimrod program which will gather all the runtime variables (URL to download
stuff from and other parameters) which will spit out a bash script. Then we
copy the bash script to the user through a `secure shell
<https://en.wikipedia.org/wiki/Secure_Shell>`_ and run it remotely.

The secure shell abstraction forces us to make a script which works remotely,
can be run at any time, and more importantly, we can run one instance in our
development machine (macosx) and another one on a virtual box or hosted server
(linux). Secure shells are also easier to set up with public/private keys to
avoid interactive prompts during testing. Of course you can set up passwords
into the test scripts, but you have to be careful about `private secrets not
leaking to public repositories
<https://stewilliams.com/silly-gits-upload-private-crypto-keys-to-public-github-projects/>`_.
Making sure the user ssh setup is **not** part of your software repository can
sometimes be a good thing.


::
$ nimrod c -r bank_savings.nim
Traceback (most recent call last)
bank_savings.nim(135)    bank_savings
bank_savings.nim(107)    end_of_month
bank_savings.nim(79)     pay_rent
SIGSEGV: Illegal storage access. (Attempt to read from nil?)
Error: execution of an external program failed

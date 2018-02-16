---
title: Testing installation instructions
pubDate: 2014-05-01 18:00
moddate: 2016-09-10 19:58
tags: nim, testing, programming, user experience
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
page which never loads: users will look elsewhere. Yet they are not that
difficult to test. In fact, everybody should be testing them.

Testing dropbox_filename_sanitizer
----------------------------------

For this article I'll be using my own ``dropbox_filename_sanitizer project``
because pointing
errors in other people's software is too easy and doesn't enrich me. This
project also offers a nice range of things to test: there is a stable source
code installation, a development source code installation, and a pre built
binary installation. In addition the program is implemented with the `Nim
programming language <http://nim-lang.org>`_ which `recently released
version 0.9.4
<http://nim-lang.org/news.html#Z2014-04-21-version-0-9-4-released>`_. A
programming language in development may well render the source code useless
between versions, so we will have to expand the source code tests to cover one
using the stable compiler release and another using the unstable one. If my
math is not wrong, that's more than a single test, enough to impress your mom.

The platforms to test are MacOSX and Linux. You can test Windows too, you can
do nice things with `VirtualBox alone
<https://oracleexamples.wordpress.com/2011/08/12/virtualbox-script-to-control-virtual-machines/>`_
or `with additional tools like Vagrant
<http://www.vagrantup.com/blog/feature-preview-vagrant-1-6-windows.html>`_, but
I don't own any Windows licenses and have little interest in getting one.
Since both target platforms are Unix-like, we will be able to reuse the
scripting for both using `bash <https://www.gnu.org/software/bash/>`_ or
whatever shell used by the systems used to run the test cases (if you don't
control the environment, like on virtual host). We won't go the full virtual
machine route because it is time expensive, and also because we can easily
emulate nearly clean state environments through additional users.

.. raw:: html

    <img
        src="../../../i/nuke_orbit.jpg"
        alt="The only sane approach to software testing"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt">

The strategy then is to create a separate user for testing in your own machine.
This user won't have any of the installed dependencies required for
installation, and we will install everything in specific directories which can
later be erased to prevent them from polluting future tests. If the software
you are using requires installation in global paths, you need a virtual machine
then anyway. Certainly you don't *trust* software to have a good uninstallation
mechanism, do you?

A separate user account on the machine is easier to nuke from orbit should
anything go wrong, but it also helps to keep yourself honest about the testing
environment. If you run the tests as your development user many little
environment changes can creep in and alter the tests. First we will write some
code which will gather necessary runtime variables from the development
environment or from json files producing a bash script. Then we copy the bash
script to the user through a `secure shell
<https://en.wikipedia.org/wiki/Secure_Shell>`_ and run it remotely.

The secure shell abstraction forces us to make a script which works remotely,
can be run at any time, and we can run one instance in our development machine
(MacOSX) and another one on a virtual box or hosted server (Linux). Secure
shells are also easier to set up with public/private keys to avoid interactive
prompts during testing. Of course you can set up passwords into the test
scripts, but you have to be careful about `private secrets not leaking to
public repositories
<https://stewilliams.com/silly-gits-upload-private-crypto-keys-to-public-github-projects/>`_.
Making sure the user ssh setup is **not** part of your software repository can
sometimes be a good thing.


Testing the stable babel installation
-------------------------------------

To install the stable version of dropbox_filename_sanitizer the user only has
to type the following commands::

    $ babel update
    $ babel install argument_parser
    $ babel install dropbox_filename_sanitizer

Fun fact: presumably you don't have to install ``argument_parser``
manually since `babel
<https://github.com/nimrod-code/babel>`_ will take care of dependencies.
Unfortunately `a bug prevents correct installation
<https://github.com/nimrod-code/babel/issues/37>`_ due to a mistake in handling
version numbers. Yes, the problem was found while setting up the project for
testing in advance for this blog post. Bug inception!

Since the project already features a ``nakefile``
which drives other tasks (see the `nake project
<https://github.com/fowlmouth/nake>`_) I decided to add a shell_test
command. This command accepts json files
which contain some parameters of what is to be tested. Let's see one of those
json files first:

- ``host``, ``user``:
  These are the typical host and user parameters for the secure shell. Use
  ``localhost`` and a different user on your own machine to simulate a clean
  install.
- ``nimrod_branch``:
  Specifies which branch to check out for the Nim compiler. You can specify
  tags as well for previous releases. In this case, we use the development
  branch.
- ``nimrod_version_str``:
  The string we will use with `grep <https://www.gnu.org/software/grep/>`_ in
  the script to verify that the compiler we invoke is the proper one. Since
  this is the development version, we don't care about the version, but stable
  version checking will feature a specific number (like 0.9.4).
- ``nimrod_csources_branch``:
  Similar to ``nimrod_branch``, this is the branch used by the sub repository
  csources required by the compiler.
- ``chunk_file``:
  Name of the documentation file we will extract installation steps performed
  by the user.
- ``chunk_number``:
  Index of the instructions *block* that we are testing. The readme features
  several possible instructions, having different json files for each block.
- ``bin_version``:
  Similar to ``nimrod_version_str``, this parameter specifies if we are testing
  against the development version of ``dropbox_filename_sanitizer`` (which will
  get the number directly imported from the module) or the last stable version
  (which will be obtained from git tags).

The nakefile code for the task is a little bit split and tough to follow
sequentially, so I've put at
https://gist.github.com/gradha/aff3c6d53657a27e4cae an example of generated
shell script. This is the shell script that is copied to the remote user and
run as is. The only dependency required is a working compiler. The script first
sets up some variables to reuse, removes previous temporary files which could
have been left from failure runs, and starts to install both the Nim
compiler and babel. Quite boring, but necessary.

By the very end of the script, `on line 58
<https://gist.github.com/gradha/aff3c6d53657a27e4cae#file-shell_test_1398956253-sh-L58>`_
you will recognise the three commands mentioned above to update babel, install
argument_parser, then install the program. `Previously line 54
<https://gist.github.com/gradha/aff3c6d53657a27e4cae#file-shell_test_1398956253-sh-L54>`_
did export the private babel binary directory (``.babel/bin``) to test a normal
user invoking the binary without typing the full path to it. This can be seen
in the `last test line 62
<https://gist.github.com/gradha/aff3c6d53657a27e4cae#file-shell_test_1398956253-sh-L62>`_
which verifies the installed version of the command running the command's
``--version`` switch piped to `grep <https://www.gnu.org/software/grep/>`_. If
``grep`` doesn't find a match it will return an error, which will abort the
whole script, courtesy of `line 4 forcing immediate exit
<https://gist.github.com/gradha/aff3c6d53657a27e4cae#file-shell_test_1398956253-sh-L4>`_
if any of the following commands returns a non zero error status.


Testing the development babel installation
------------------------------------------

To install the development version of ``dropbox_filename_sanitizer`` the user
has to type a little bit more::

    $ babel update
    $ babel install argument_parser
    $ git clone https://github.com/gradha/dropbox_filename_sanitizer.git
    $ cd dropbox_filename_sanitizer
    $ babel install

The only difference is that instead of asking babel to fetch the package we
clone the git repository and install it manually by omitting the parameter (and
having a babel spec file available in the working directory). The only
difference between the stable and development versions of the test script will
be the lines run to install the software. These lines are obtained through the
previously mentioned ``chunk_number`` parameter in the json file.  The crude
``gen_chunk_script`` proc in the nakefile will parse the readme and extract all
the lines for whatever block was specified. One could go hi-tech and use the
`rst nim module <http://nim-lang.org/docs/rst.html>`_ to parse the readme, but
simple line stripping serves well.


Testing the pre built binaries
------------------------------

I haven't bothered yet to do this for a very simple reason: you only need to
test this once. The compiled binaries work without dependencies, so by the time
you create them, you test them yourself once and… that's it! It's the source
installation which depends on many more steps and packages which can go wrong.
Certainly there is room to test for failures in the packaging itself, but the
packaging itself is automated. Maybe if I get very bored I'll do it.


Conclusion
----------

.. raw:: html

    <img
        src="../../../i/so_metal.jpg"
        alt="Tiffany approves"
        style="width:100%;max-width:750px" align="right"
        hspace="8pt" vspace="8pt">

It takes some time to set these kind of tests, but they are critical: if
potential users of your software find that they can't even install it, they
won't bother to contact you to fix it, you require a lot of interest for that
to happen. So you better know first that something is broken. The huge amount
of github projects which don't even compile without tweaking is sad (or maybe
I'm just unlucky?).

As a bonus you know when things go wrong without others having to tell you.
Since these integration tests also test external software, you are
sort of contributing to the `Nim community <http://forum.nim-lang.org>`_
by testing the compiler (both the last stable and last development versions)
and the approved package manager used by many others.

I've wondered if these tests should go the route of continuous integration.
That seems to be a lot of work but possible through `GitHub webhooks
<https://developer.github.com/v3/repos/hooks/>`_. On the other hand maybe
webhooks don't work for watching external repositories you don't have control
over. Since installation instructions are not going to change from day to day,
it would be also possible to write a polling script which every night checks
the current Nim compiler version, and if changed, runs the tests.  Changing
from continuous integration to nightly builds is not that bad either and still
provides a reasonably fast response to external changes if something goes
wrong.

If you develop a Nim based pseudo continuous software tester, let me know!

.. raw:: html

    <br clear="right">

::
$ unzip dropbox_filename_sanitizer-0.4.0-macosx.zip
Archive:  dropbox_filename_sanitizer-0.4.0-macosx.zip
  inflating: dropbox_filename_sanitizer
  inflating: readme.html
  …
$ ./dropbox_filename_sanitizer
-bash: ./dropbox_filename_sanitizer: Permission denied

---
title: From Python windows console to Nim Karax webapp
pubdate: 2019-03-26 21:58
moddate: 2019-03-26 21:58
tags: metaprogramming, programming, languages, python, nim
---

From Python windows console to Nim Karax webapp
===============================================

A challenger appears
--------------------

.. raw:: html

    <a href="https://locomotion1020.tistory.com/18"
        ><img src="../../../i/webapp_nim_wat.jpg"
        alt="A webapp in Nim? What is he smoking? Is that possible at all?"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>


Between people who really love programming and those who treat technology like
inscrutable magic there are those like Kpopalypse who are capable of building
software without being dedicated programmers. If you go to `Kpopalypse's
website <https://kpopalypse.com/>`_ and `click on Sully
<https://kpopalypse.com/2014/01/20/kpopalypse-faq/>`_ you will find out many
facts about his persona, but you will miss that he has released `sp00ky
interactive Halloween fanfiction
<https://kpopalypse.com/2018/10/19/stan-loona-or-else/>`_ or adventure games
like `Escape from the Idol Dungeon
<https://kpopalypse.com/2019/01/24/escape-from-the-idol-dungeon-an-adventure-game-by-kpopalypse/>`_,
showing higher than average levels of determination to understand and dominate
technology.

Most recently Kpopalypse released a `fan comment generator
<https://kpopalypse.com/2019/02/24/the-kpopalypse-fan-comment-generator/>`_,
which allows anybody with a Windows computer to mechanize the act of answering
posts in crazy kpop forums. The original binary can be `downloaded from his
itch.io webpage
<https://kpopalypse.itch.io/the-kpopalypse-fan-comment-generator>`_, but most
interestingly the source code for this Windows console program can be
`downloaded from his Patreon page
<https://www.patreon.com/posts/for-super-nerds-24968118>`_. Windows programs
are not bad, but in this day and age, everybody wants to use software
everywhere, including their phones, and for maximum cross platform portability
that usually means webapps in some combination of HTML and JavaScript.

Since `Python <https://www.python.org>`_ looks `very similar
<https://github.com/nim-lang/Nim/wiki/Nim-for-Python-Programmers>`_ to the `Nim
programming language <https://nim-lang.org>`_, and the Nim compiler includes
`JavaScript compilation <https://nim-lang.org/features.html>`_, I decided to
teach myself how to make a webapp with Nim, first translating Kpopalypse's
Python program to Nim, then making a webapp with `Karax, a single page
application framework <https://github.com/pragmagic/karax>`_ based on it. Even
though I know Python and Nim, before this exercise I had only heard rumors
about webapps.

What follows is a description of how things went which might be of interest if
you are looking to do something similar. Everything described here is stored at
a `GitLab repository
<https://gitlab.com/gradha/kpopalypse_crazycommentgenerator>`_. There you can
see:

* The `original Python 3 program by kpopalypse
  <https://gitlab.com/gradha/kpopalypse_crazycommentgenerator/blob/master/01_original_python/crazycommentgenerator.txt>`_.
* The `translated version to Nim
  <https://gitlab.com/gradha/kpopalypse_crazycommentgenerator/blob/master/02_nim_command_line/crazycommentgenerator.nim>`_,
  with minimal differences.
* The `Nim + Karax version for the webapp
  <https://gitlab.com/gradha/kpopalypse_crazycommentgenerator/blob/master/03_nim_webapp/crazycommentgenerator.nim>`_,
  which is certainly very different from the console version, but strives to
  retain the original purpose.

And of course, you can use the final resulting webapp at
`https://gradha.gitlab.io/kpopalypse_crazycommentgenerator/
<https://gradha.gitlab.io/kpopalypse_crazycommentgenerator/>`_. You can even
create a bookmark on your mobile phone or add it to your desktop so it opens as
a kind of native application. You can also save the contents of that page to
your hard drive and it should work locally. But why would you do that since you
use it to generate a comment you want to post somewhere online, right?


Translating the Python script to Nim
------------------------------------

Translating the Python source code to Nim was very easy. Both are imperative
programming languages which use whitespace as indentation. Other than the minor
differences in syntax (e.g. in Python you write ``def``, in Nim you write
``proc``) the most significant difference in the Nim version are the emulations
of the Python functions ``input()``, ``print()`` and the need to *forward
declare* procedure.

Both Python and Nim read the source input line by line,
but in Python you can reference functions or globals which the interpreter has
not yet seen. Python will presume they will be defined later and look for some
time later. The following Python fragment is correct::

    def function_1():
        print("I'm function 1")
        function_2()

    def function_2():
        print("I'm function 2")

    function_1()

But if you try to transcribe this to Nim, the compiler will complain that on
the third line you are attempting to use ``function_2()`` which has not been
defined yet. Hence the forward declaration, which tells the compiler that it
should stay calm and keep compiling::

    # This is a forward declaration.
    proc proc_2()

    proc proc_1() =
        echo("I'm proc 1")
        proc_2()

    proc proc_2() =
        echo("I'm proc 2")

    proc_1()

Another practical difference is that in Python you end up with Python
*scripts*. These are both source code and final version, since you use the
Python interpreter to run them. In order to produce a final binary (aka:
``.exe``) that can be run on machines without Python, you need to use a special
tool like `py2exe <http://py2exe.org>`_ which just packages Python along your
script and makes them executable. In Nim you always need to compile the source
code, so by definition you get a working executable you can move to practically
any other machine.

With regards to the structure of the program itself, most of it is *user
interface* handling, meaning the program asks you a series of questions and
stores the values in global variables. By the end, when you have entered all
the required data, a single function will go through the input data and
generate a big comment. The *user interface* is of course a line by line
terminal like console, or a DOS prompt for Windows users. The program asks you
things, and you write stuff, followed by the return key.

Being new to programming, Kpopalypse makes a few mistakes. First `modules are
imported
<https://gitlab.com/gradha/kpopalypse_crazycommentgenerator/blob/master/01_original_python/crazycommentgenerator.txt#L20>`_,
then `modules are defined through the def statement
<https://gitlab.com/gradha/kpopalypse_crazycommentgenerator/blob/master/01_original_python/crazycommentgenerator.txt#L35>`_.
The second part should read *functions are defined through the def statement*,
since modules are
actually collections of functions and variables.

Another mistake is that function calls are actually treated like `good'ol goto
statements
<https://arstechnica.com/information-technology/2014/02/extremely-critical-crypto-flaw-in-ios-may-also-affect-fully-patched-macs/>`_,
meaning that when Kpopalypse `writes that something returns
<https://gitlab.com/gradha/kpopalypse_crazycommentgenerator/blob/master/01_original_python/crazycommentgenerator.txt#L73>`_,
it actually does **not** return but calls the mentioned function. For the use
case of this program, who cares, right? But if you were to be a highly
determined caonima and generated lots and lots of comments without quitting the
program, you would eventually reach a stack overflow, since each call without
return to a function increases the stack until it can't grow any more. We have
plenty of memory in our machines nowadays so it is never going to be a problem
in real life.


What is a webapp?
-----------------

Webapps are abominations born from the pit of despair. Originally web pages
were just static declarations of hierarchical content. You defined a title, a
paragraph, some images and you essentially have this site. At some point
JavaScript was added to browsers for them to run scripts, and these scripts
were allowed to modify the webpage they were associated with. People figured
out they could actually change everything in the web page, since its content
hierarchy was described as a tree, or `DOM (Document Object Model)
<https://en.wikipedia.org/wiki/Document_Object_Model>`_. And then chaos ensued,
known as single page webapps.

A basic single page webapp, like the one we will do, creates a content
structure (DOM), and defines JavaScript code which modifies it based on user
input (events) like button clicks or mouse movement. As such, our code has to
keep the state of what should the web page actually be displaying, and typical
webapps are just infinite loops (`described as lame by Kpopalypse
<https://gitlab.com/gradha/kpopalypse_crazycommentgenerator/blob/master/01_original_python/crazycommentgenerator.txt#L256>`_)
which check the state and generate or update the web page appropriately to
display *different screens* without actually changing the page. Thus the
illusion of a single page webapp.

But the craziness of this is actually **not enough**, since we will raise the
bar by using the Nim programming language instead of JavaScript. Does this make
sense?  Unlikely. This would only make sense if you actually knew a lot of Nim,
and nothing or little of JavaScript (what a coincidence!). Or maybe you know a
lot of JavaScript, and `this extensive knowledge of the most horrible rituals
known to mankind <https://www.destroyallsoftware.com/talks/wat>`_ has made you
reflect and return to saner programming languages like Nim. How ironic that by
trying to be saner you increase the overall insanity! Are you perhaps
`following <https://www.youtube.com/watch?v=3kQuMVffbWA>`_ `other
<http://www.asianjunkie.com>`_ `cults
<https://www.youtube.com/watch?v=XEOCbFJjRw0>`_ `too
<https://www.youtube.com/watch?v=-KFpL9DUyms>`_?

One possible way of translating the console script to web format would be to
emulate the workings of a console. This would be quite simple, we only need to
store a list of the lines that we are meant to display. Our ``print()``
function would just add the line to this global list of lines, and then tell
the web page to render itself again, which would make the new line visible.
Thus, adding lines to our global list would emulate new lines of text on a
console. Whenever a question is asked by the program, an input text box could
be displayed at the end of all visible lines. While functional, this would also
look very crude to the average web user, who has been trained with animated
images and flashy elements requiring mouse clicks.

In general users don't need to see how the previous question was asked on the
screen, so we can replace the list of questions with a single one that changes
text. This also avoids huge scrolling pages for mobile users with less screen
space. But some form of history is good for usability, so we can display the
user input entered so far as a horizontal list at the top. Also, whenever a
binary question is asked, the original script makes an effort to detect
different types of input and react accordingly. One typical mistake is that if
you were to input certain values in upper case, the script would fail to
recognise the.  See this console output::

    Are you stanning a group or a solo performer?
    Press g for group, or s for a solo performer.
    Press ENTER after your selection.
    G
    Please enter a valid selection.

Just by having the caps lock key on we have users scratching their head and
thinking why their option ``G`` was not recognised. That's because the script
expects such questions in lower case, and does no effort to add the upper case
variants to the list of possible answers. In the web version we can skip all
this nonsense and simply present buttons to click. Click here for group, or
click here for solo performer. Done. Changing from free form text to mouse
clicks restricts user input enough that we barely have to implement any
validation to check cases like the one mentioned above with the upper case.


Standing on Karax's wobbling shoulders
--------------------------------------

.. raw:: html

    <a href="https://locomotion1020.tistory.com/10"
        ><img src="../../../i/webapp_understanding.jpg"
        alt="Did you understand that? Let me check the documentation… nope. Also this doesn't have enough hearts yet, let me draw some"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>



When I described how webapps work (maintaining state and regenerating every
part of the page) I simplified a lot. There are many *low level* details on how
to do this, and while web pages seem to be cross platform, there are many
differences between browsers, and sometimes even their versions. To abstract
all of these, people build libraries or frameworks to help them write webapps,
and I chose `Karax <https://github.com/pragmagic/karax>`_, which at the moment
is the `highest starred nim-language repository on GitHub with 312 stars
<https://github.com/topics/nim-language>`_. Karax asks you to write a simple
DOM root which will then be rewritten for every Nim code change, presumably
letting you write your whole webapp in Nim without touching JavaScript at all.

Unfortunately, Karax is not ideal for newcomers to webapp programming, or just
newcomers in general. Nothing screams more *unfinished software* like a project
with `zero stable releases <https://github.com/pragmagic/karax/releases>`_.
Unless you are prepared to deal with ever changing software, you should stay
away from it. In terms of user friendliness, actual documentation is `a joke
someone tried to play 2 years ago
<https://github.com/pragmagic/karax/tree/20fe35355c83de024dbf13a6489073ddbb666e81/docs>`_,
and you are forced to rely on the base ``readme.rst`` and available examples to
work. Which would not be a problem if the documentation was right, however if
you try to run the first example on OSX (as extracted from the readme)::

    cd karax
    cd examples/todoapp
    nim js todoapp.nim
    open todoapp.html

You will be greeted with a blank web page, with the JavaScript console spitting
out a *SecurityError: The operation is insecure* message. So you later learn to
use the ``karun`` tool instead, and that works, but just below the mention of
``karun`` you are disheartened by the notice that in order to know what Karax
is doing, you should actually compile your code with ``-d:debugKaraxDsl`` to
see what it does. Which is not very beginner friendly, as you need to know both
JavaScript and Nim to know what the hell is going on (have you ever seen a C
programming language tutorial tell you to look at the assembly/machine code
generated by the compiler?). The learning curve for newcomers to Nim webapps is
very steep.

One of the problem for newcomers to webapp programming in Nim is that it is not
clear what is meant to work and what not. The usual expectancy of normal
desktop Nim code is broken in a webapp environment. Being a newcomer myself, I
had to go through all the examples scratching my head as to why things would
work or would not. For instance, take a look at the following fragment of the
`toychat.nim example
<https://github.com/pragmagic/karax/blob/20fe35355c83de024dbf13a6489073ddbb666e81/examples/toychat.nim>`_::

      if loggedIn:
        label(`for` = message):
          text "Message: "
        input(class = "input", id = message, onkeyupenter = doSendMessage)

In the ``toychat.nim`` example (if you run it with ``karun -r toychat.nim``)
you get a simulation of a chat like environment, where typing text into an area
box and pressing the enter key adds the written input to the web page. Of
course nothing is sent anywhere, but you get the idea of how the user interface
could work. Aha! You tell yourself looking at other examples, let's add a
button to emulate the pressing of the return key!::

      if loggedIn:
        label(`for` = message):
          text "Message: "
        input(class = "input", id = message, onkeyupenter = doSendMessage)
        button(id = message, onclick = doSendMessage):
          text "Click here to send stuff"

You compile again the example and you see the button, but something is not
right: first of all, typing a text and pressing the enter key sends a ``null``,
then blank lines, and the button works the same, sending blank lines instead of
whatever has been typed. Why does adding a button break the behaviour of the
``input`` form? Trying random stuff, I removed the ``id = message`` part from
the button and that made the ``input`` area work again. Yeah! Shame the button
callback still doesn't do anything useful and generates blank lines. And why
does using the same ``id`` in the button **break** the ``input`` part? The
``readme.rst`` mentions that callbacks are somehow special, but if you don't
know JavaScript and what Karax is meant to generate well, you will be kept in
the dark praying to luck to move forward.

Still, some work can be done blindly by mangling examples until stuff works.
The source code for the webapp version `of Kpopalypse's crazy comment generator
has comments  too
<https://gitlab.com/gradha/kpopalypse_crazycommentgenerator/blob/master/03_nim_webapp/crazycommentgenerator.nim>`_,
trying to explain a few things about the structure, so I'll skip them here.
Most notable *weird magic shit* is the `JavaScript code to copy text to the
clipboard
<https://gitlab.com/gradha/kpopalypse_crazycommentgenerator/blob/master/03_nim_webapp/crazycommentgenerator.nim#L211>`_.
If you are using the comment generator on a mobile device, selecting and
copying a wall of text is not going to be very user friendly, since selection
is prone to *sausage fingers* making it a frustrating operation.

Therefore I wanted to add a button to the final screen which would allow you
to copy the generated text to the clipboard, ready to paste in your web
browser. While the mechanism of the JavaScript code to copy the text is pretty
simple to follow, trying to coerce Nim into generating it was a real pain in
the ass, so I decided to take a shortcut and use the `Nim emit pragma
<https://nim-lang.github.io/Nim/manual.html#implementation-specific-pragmas-emit-pragma>`_.
The ``emit`` pragma is well known by people avoiding Nim compiler bugs or just
trying to do stuff the compiler is striving to prevent you from doing and
simply dumps whatever you ass it to the final backend (in this case JavaScript
generator). The webapp works without this, but its end user friendliness is
slightly reduced.

Another interesting part of the webapp source code is the usage of `templates
to generate repetitive procs
<https://gitlab.com/gradha/kpopalypse_crazycommentgenerator/blob/master/03_nim_webapp/crazycommentgenerator.nim#L132>`_.
The webapp uses callbacks for each button to modify the global variables, and
copying and pasting several times the same proc gets repetitive. Templates
allow to parametrize code generation in a very natural way. But then `I hit a
compiler bug
<https://gitlab.com/gradha/kpopalypse_crazycommentgenerator/blob/master/03_nim_webapp/crazycommentgenerator.nim#L366>`_
when I tried to parametrize the code to build user input for each variable. For
some reason, the following template (whose structure was used successfully
twice before) does not compile::

    template buildGroupMemberN(procName, inputCallback, nextState): untyped =
      proc procName(): VNode =
        result = buildHtml(tdiv):
          p:
            tdiv: text "Enter the name of another group member: "
          input(class = "input", id = inputFieldId, onkeyupenter = inputCallback)
          button:
            text "Click here if there are no more members"
            proc onclick(ev: Event; n: VNode) =
              setRemainingGroupMembers(10)
              screen = nextState
          tdiv: text errorMessage

    buildGroupMemberN(buildGroupMember11, setGroupMember10, sAdjective1)

Trying to compile the webapp will spit out the following error::

    stack trace: (most recent call last)
    karax_mirror/karax/karaxdsl.nim(182) buildHtml
    karax_mirror/karax/karaxdsl.nim(138) tcall2
    karax_mirror/karax/karaxdsl.nim(79) tcall2
    karax_mirror/karax/karaxdsl.nim(138) tcall2
    karax_mirror/karax/karaxdsl.nim(79) tcall2
    karax_mirror/karax/karaxdsl.nim(138) tcall2
    karax_mirror/karax/karaxdsl.nim(79) tcall2
    karax_mirror/karax/karaxdsl.nim(102) tcall2
    karax_mirror/karax/karaxdsl.nim(32) getName
    ../../../../.choosenim/toolchains/nim-0.19.4/lib/core/macros.nim(523) expectKind
    crazycommentgenerator.nim(388, 18) template/generic instantiation from here
    crazycommentgenerator.nim(377, 23) template/generic instantiation from here
    crazycommentgenerator.nim(379, 15) Error: Expected a node of kind nnkIdent, got nnkOpenSymChoice

So just like with Karax weird input vs button behaviour I decided to look
elsewhere and copy&paste the necessary repetition. Life is to short to look
into obscure compiler meta programming bugs.


Conclusions
-----------


Can you write single page web applications in the Nim programming language?
`Sure you can <https://gradha.gitlab.io/kpopalypse_crazycommentgenerator/>`_!
Is this something I would recommend somebody else? Nah, I'll let a few years
pass by and check Karax in the future. Maybe by then others will have had their
teeth cut on Karax and documentation will be useful for newcomers or at least
understandable. At the moment Karax needs the equivalent of `Nim basics
<https://narimiran.github.io/nim-basics>`_ tutorial to gain users. The current
pseudo documentation heavily relies on you willing to read every bit of `the
todo example
<https://github.com/pragmagic/karax/tree/master/examples/todoapp>`_ to gain
minimal insight, but it is complicated enough that the solutions written there
don't make much sense to newcomers or are too specialized to be used anywhere
else.

As for making Kpopalypse crazy comment generator available as a web page, I
consider this a 100% success, so now I'll take a rest of web app programming
until I learn more about `Cthulhu <https://en.wikipedia.org/wiki/Cthulhu>`_ and
the other deities that have to be worshiped to avoid loosing too much sanity
during the process.

.. raw:: html

    <center><a href="https://locomotion1020.tistory.com/52"
        ><img src="../../../i/webapp_oppa.jpg"
        alt="Fuck yeah! With this comment webapp Oppa will notice us!"
        style="width:100%;max-width:600px" align="center"
        hspace="8pt" vspace="8pt"></a></center>

::
    $ karun -r tesla.nim
    Error Chuu not president.

---
title: Worse than global variables
pubdate: 2013-12-09 11:54
moddate: 2013-12-09 11:54
tags: programming, languages, design, objc
---

Worse than global variables
===========================

Global variables are one of the lowest programming abstractions you can use
today. They represent through a human readable name an arbitrary address of
memory on the machine running a program. In the beginning, *real* programmers
would store their data at specific memory address locations, and this was
tedious and error prone. Being able to *name* those address locations with a
meaningful name, hopefully indicating what the address was used for, decreased
human errors and made reviewing code easier. Programmers didn't have to
remember any more what the address ``&A0BFh`` stood for while developing. They
weren't even called *global* variables, they were simply variables, saving the
world and allowing civilization reach higher heights. They were good, and
kittens were saved.

So what happened? At some point `structured programming
<https://en.wikipedia.org/wiki/Structured_programming>`_ happened and suddenly
programmers realised that as code grew, it was useful to compartmentalize
sections and try to make them independent of each other for reuse. Local
variables entered the scene, having a shorter lifespan compared to that of the
*immortal* global variables. Now you could have `subroutines
<https://en.wikipedia.org/wiki/Subroutines>`_ using their own variables without
*polluting* the global *name space*. Note how even the words I just used
(polluting) imply something negative. As if the global name space was as
*precious* as our `bodily fluids
<https://www.youtube.com/watch?v=Qr2bSL5VQgM>`_, and any attack against them
had to be answered with resolution.

Indeed, global variables are at odds with structured programming (and even more
concurrent programming). Consider the following C program:

```
#include <stdio.h>
#include <string.h>

int amount = 0;

void count_words(char *text)
{
    const char *sep = ", \t";
    for (char *word = strtok(text, sep);
            word; word = strtok(NULL, sep)) {
        amount++;
    }
}

int main(void)
{
    char text[] = "Globals, globals everywhere";
    count_words(text);
    return printf("Words %d\n", amount);
}
```

This little program will display that there are 3 words in the text ``Globals,
globals everywhere``. This is done calling the ``count_words`` function, which
then calls the libc ``strtok`` function to *tokenize* the input. That is,
``strtok`` splits the input buffer and loops over it ignoring the separator
characters.

The function ``count_words`` stores into the global variable ``amount`` the
number of words. And for this simple example it's enough, and it works.
However, if we wanted to reuse the ``count_words`` function in other programs,
we would quickly see that we *have to carry* the global variable along: the
function itself is not independent. Also, it is difficult to call, rather than
assigning the result to any variable, we are forced to use ``amount``.

I picked this specific case for another reason. Let's say that we make
``count_words`` **not** use the global variable ``amount`` but instead return
the value. Then we write `some sort of word indexing website as an experiment
<https://www.google.com/>`_ and we modify the program to read multiple input
files and start `different threads
<https://en.wikipedia.org/wiki/Thread_(computing)>`_, each calling the
``count_words`` subroutine. Excellent! We are done, aren't we?

Nope. Here we see another *evilness* of global variables. The libc ``strtok``
function itself uses an internal global buffer (similar to the ``amount``
global variable) for its purposes, and this means that concurrent threads
calling this function at the same time will step over each other modifying this
buffer, and likely obtaining an incorrect result during the computation. For
this specific reason the `strtok_r function
<http://linux.die.net/man/3/strtok_r>`_ was added. Through the use of a new
third parameter, the caller of the function can specify the internal buffer,
and thus multiple concurrent threads using *different* buffers won't step on
each other. This property is called `reentrancy
<https://en.wikipedia.org/wiki/Reentrancy_(computing)>`_, and it tells the
programmer that it is safe to call a function in a multi threaded context
because it doesn't use any global state.


The crusade against global variables
------------------------------------

The solution to all this suffering is easy. Ban global variables. Banish the
``strtok`` function from the standard C library. Even better! Why don't we make
`a programming language were the programmer has to jump through hoops to make a
global variable <https://en.wikipedia.org/wiki/Java_(programming_language)>`_?
That will teach them, if programmers really want to have a global variable,
let's force them to wrap that around an invented object class and mark it
static.

Even better, rather than create global variables, why don't we have a language
where the *mainstream* convention is to wrap them inside `the singleton pattern
<https://en.wikipedia.org/wiki/Singleton_pattern>`_? Oh, don't worry, it's
going to be simple, so simple in fact that to this day there are `still
questions on how to implement this pattern because it is so complex and it has
so many little gotchas that nobody is able to figure out the proper way to do
it
<http://stackoverflow.com/questions/145154/what-should-my-objective-c-singleton-look-like>`_.
I'm not the first to point out that people who are new to programming `get
bored to death through the use of languages which require them to be an expert
to implement a Hello World program
<http://programmingisterrible.com/post/40453884799/what-language-should-i-learn-first>`_.

At this point you really have to stop. Where did it go wrong? Why from a simple
global variable we have to over engineer a singleton pattern? Is it really that
good? Is it *that* common to start writing an algorithm using a global variable
that you later say "*Awww, look, I should have not used that global variable
because I have to now… add a single state parameter/structure to my code*"? The
amount of times I've said that are very very few, yet day and night I find
myself reading the singleton pattern where a normal global variable access
would do.

Global state is rarely a matter of a single variable, and one typical solution
is to group the global state into a single structure. Then create an global
variable of that structure and use it. Here's a snippet from one of my programs
implemented in `Nimrod <http://nimrod-lang.org>`_:

```nimrod
type
  Tglobal = object ## \
    ## Holds all the global variables of the process.
    params: Tcommandline_results
    verbose: bool ## Quick access to parsed values.
    target_url: string ## Were to download stuff from.
    short_name: string ## Prefix used for file directories.
    dest_dir: string ## Path for the destination directory.
    post_process: string ## Path to command to be run on final directory.

var g: Tglobal
```

Command line parsing is a very good example of global state because it happens
once, and it works for the whole execution of the program. When the user wants
to have a *verbose* execution you can store that in a global variable. Then you
access ``g.verbose`` and do your thing. Instead, according to the singleton
pattern I should be accessing some *static* method of a class to read the value
of a variable (which is not going to change). How wasteful is that, not only in
terms of program runtime but also developer time, repeating that stupid pattern
all over the place?


Crutches, not tools
-------------------

The fact is that Java or Objective-C are not good languages when it comes to
implement global variables, each having downsides, imposing a development
penalty on all of us. Global variables  won't go away, all but the most trivial
programs have or need global state. It is damaging to ourselves when
programmers, after having invested time in learning a programming language,
throw excuses and tantrums to justify their broken tools.  That's an emotional
answer, nobody wants to be told that they have wasted their time learning the
wrong thing.

The singleton pattern can be useful, but hiding simple global variables behind
it is not a proper use of this pattern. Is your programming language preventing
you from doing the right thing then? And more importantly, is your programming
language preventing you from thinking about the right way to express your
needs?

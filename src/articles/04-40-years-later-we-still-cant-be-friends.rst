---
title: 40 years later we still can't be friends
pubdate: 2013-10-08 00:29
moddate: 2013-10-20 00:39
tags: multitasking, user-experience, objc, apple
---

40 years later we still can't be friends
========================================

Context
-------

The computer (or electronic device) you are likely using to read this article
is also very likely to be doing some form of `multitasking
<https://en.wikipedia.org/wiki/Computer_multitasking>`_, where the machine
gives the illusion of performing different tasks simultaneously. At the low
level a single processor is only able to perform a single task, operation,
action, whatever you want to call it. However, processors are so fast that
switching from one task to another looks to us, humans, like they are doing
multiple things.

For instance, even if you are waiting for a web page or program to load, and
you see some sort of visual indicator, like a spinning wheel, as a user you may
think the computer is busy doing one task, the loading of the web page or
program. But at the low level the computer is doing much more, in fact, by
simple virtue of drawing and updating an animated icon, updating the position
of the mouse on the screen, and why not even `playing some kpop music in the
background <https://www.youtube.com/watch?v=yMqL1iWfku4>`_ while you patiently
wait. In contrast, if the computer could not multitask, while the web page or
program loaded, you could not do anything, not even move the mouse.

According to the erudites from wikipedia (*citation needed*), `time sharing
<http://en.wikipedia.org/wiki/Time-sharing>`_ was a computing model which
between 1960 and 1970 established itself as the way to share resources on big
mainframes. `Unix <http://en.wikipedia.org/wiki/Unix>`_ and many of its
descendants, like the popular `Linux <http://en.wikipedia.org/wiki/Linux>`_
inherited this computing model, since it was accepted as valid. Most of
operating systems of today follow this computing model, since one of the
troubles with the computing industry is its really impressive momentum and
resistance to change.


There's a war going on inside your machine
------------------------------------------

There are many ways to explain how programs running on a computer share
resources, but actually most ignore the fact that the programs *are not
sharing, nor willing to share* those resources. Operating systems are really
like guardians who provide access to a single resource (the CPU) in turns. If
you have a single process running, it will get all the time slices of the CPU.
But if you have two processes, the operating system will try to distribute
equally the CPU among them. Depending on the type of the programs, they might
not even use the CPU at all because they may be waiting for user input. The
process gets the time slice of the CPU but yields it back to the OS. Hence
modern machines have many processes, but they are actually *sleeping*, waiting
for some event which will trigger a reaction.

The problem is of course the active CPU hogs. These could be playing music in
the background, video playback, compressing images or rendering frames for a
video game (games are constantly redrawing the game world on the screen for the
user).  But even if you are actively running a single program, it might run
many different sub threads to perform its tasks. For this reason most task
managers can display the list of programs running, and how many threads or
children have they spawned. So you don't actually need multiple processes to
trigger time sharing behaviour, it's enough for a single process with multiple
threads.

The problem with this inherited approach is the way multitasking is expressed
and handled in software. The most popular ways to split a task are to either
*fork* a process, or *spawn* a thread. In both cases the source program decides
how many processes or threads to create, and then coordinates the communication
to control and complete the task. And here lies the problem, a process can
query the number of available cores on the system and decide to spawn an equal
number of threads to perform a task which can be subdivided (this is called
parallelization). Why is this a problem at all?  There are two:

* The process ignores the existence of other processes in the current
  environment.
* The check for available cores happens at the beginning of the task
  subdivision, and presumes the number will remain stable for its duration.

Both of these can be handled perfectly by the operating system, since it knows
all the necessary data to decide best how to divide tasks. Yet our current
software threading model forces the programmer to decide without this
information.


Task switching killing your scalability
----------------------------------------

Let's write a photo processing software! Or maybe video. Anyway, this kind of
software operates on bidimensional images which can usually be split into
smaller chunks and dealt with mostly individually without dependencies. Tasks
inside the computer don't *magically* migrate to other cores. If we write this
software in single threaded mode, the four core machine will have one core
working at the maximum, and three idling. What a waste. No problem, we
subdivide the image and feed the chunks to the four cores. Now the performance
is nearly four times that of the original single threaded code (we have a small
overhead for splitting/controlling tasks).

Cool, now we can batch process porn pictures at the speed of light. But it
takes time to go through `our folder of midget porn
<https://www.youtube.com/watch?v=q8lW8ndh5BU>`_, and we want to do other things
in the meantime. Let's compress some video! Video edition can also benefit from
parallelization, since at the basic level the individual images can also be
split into chunks to feed different cores. Again, our video program detects
four cores, splits the images in a queue and starts processing them four at a
time. See the problem?

Now there are two processes on the quad core machine, each of them requesting
to have the four cores for itself, but in total that means running eight
threads at the same time. Unless we are running JesusOS which can multiply
cores out of nowhere, the OS is just going to switch tasks between each core.
Big deal, right? Yes, it's a big deal. When you start to measure performance of
such programs in combination you realize that task switching is not free: the
CPU has to change a lot of internal state and then the next task has to recover
it.  It takes time. And the more processes you run the worse it gets. So we end
up with a machine which for each process overspawns many threads instead of
getting one thread per core. Where doing tasks serially would take ``A + B +
C`` seconds, now we have ``A + B + C + task switching overhead`` seconds, and
the ``task switching overhead`` part can grow quite a lot, especially the more
processes there are.

This considers a situation where the number of processing units is static all
the time, but things can be harder especially on mobile devices where the
hardware may decide to disable one or more processing units to save battery.
Plugin in the laptop might give it a performance boost, and viceversa. For
these situations the programming model we have dragged for over forty years is
completely useless, there is no provision for changing the number of threads on
the fly, you need clever programmers to implement such behaviour themselves, but
there are clearly none since we haven't solved this yet, have we?


Take this ticket and wait for your turn
---------------------------------------

While most of the world was indulging in criticizing Apple for having economic
success, they silently released `Grand Central Dispatch (GCD)
<https://en.wikipedia.org/wiki/Grand_Central_Dispatch>`_ which is *yet another*
task parallelism tool based on `kqueue
<https://en.wikipedia.org/wiki/Kqueue>`_. GCD changes the way the programmer
thinks about multithreading. Instead of saying "*hey, I want 4 threads doing
this much stuff*", the programmer says "*hey, I have these many tasks which can
run parallel to each other without dependencies, run them please*". This is a
big change. While it can be argued that queues are easier to handle than
threads, what this change means to the user is that the OS can now decide how
many threads to allocate for a process. The OS doesn't face the *simultaneous
attack* of dozens of processes, instead it sees dozens of processes waiting for
their queues to finish. The OS can decide then to pick as many tasks from their
queues and not worry (mostly) about switching threads.

Of course the devil is in the details. What if you are not subdividing your
tasks well enough that they block the queues for other processes? What if the
chunk of code in the queue blocks for disk I/O? What if... queues are not for
solving the inherent threading problems OSes will keep having for the
foreseeable future. But they help a lot in allowing them to decide what to run
and when. In the example give above, the OS could decide to take only two tasks
at the same time from the image process queue and two tasks from the video
queue, and if any process finishes, the new slots can be given to the reminder
tasks in other processes' queues. Similar scenario happens if the platform you
are running enables/disables more processing cores. Have you imagined a
hardware where you can plug in a card and double the processing speed of the
running processes without them having to restart to take advantage of the
change? Now you could.

In fact, all of this is *in the past*. Note that GCD was introduced in the
year 2009. Since then, Apple has been pushing API changes all over their iOS
and OSX frameworks to include blocks and queues where they make sense. Even if
programmers of these platforms don't explicitly use queues for their programs,
most of the libraries they will surely use **are** going to take advantage of
these task parallelization techniques, thus gaining the advantages mentioned
here. And of course, whenever they need to run something in the background, the
Objective-C language and APIs will prod them towards queues rather than threads
or processes.

The benefits from using queues are not invisible or theoretical. Already in
November of 2010, `Robbie Hanson (aka Deusty)
<https://github.com/robbiehanson>`_ wrote `a blog post explaining the benefits
of migrating its HTTP server
<http://deusty.blogspot.com.es/2010/11/introducing-gcd-based-cocoahttpserver.html>`_
(`CocoaHTTPServer <https://github.com/robbiehanson/CocoaHTTPServer>`_) to
queues. Claimed performance improvements range from doubling to quadrupling,
but the most impressive is the *nearly linear scalability* when the number of
concurrent connections was increased. This is the golden dream: increase number
of tasks with nearly zero overhead. And Robbie is collaborating to other pieces
of software you might not expect could benefit from queues, like `YapDatabase
<https://github.com/yaptv/YapDatabase>`_, built on top of `SQLite
<https://sqlite.org>`_ and providing `smooth database operations not blocking
the user interface <https://github.com/yaptv/YapDatabase/wiki/Hello-World>`_ to
preserve the fluidity of the user's interaction.


A bleak future
--------------

Yet here we are, nearly four years later still waiting for the revolution to
happen. You could only hope the competition would clone this approach to
threaded code as the phone industry copied the iPhone, but I haven't seen yet
any other mainstream programming language embedding such functionality in its
core language and standard library. And if you think that's bad, we still
haven't talked about another pressing issue related to inter process hostility.
If only I had the memory to remember what it was all about…


```nimrod
$ nim c work_faster.nim
work_faster.nim(1, 7) Error: cannot open 'threads'
```

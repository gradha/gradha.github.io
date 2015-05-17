---
title: Hard memory problems
pubdate: 2015-05-16 00:36
moddate: 2015-05-16 00:36
tags: multitasking, user-experience
---

Hard memory problems
====================


.. raw:: html

    <a href="https://instagram.com/p/vzWU8iSB9B/"><img
        src="../../../i/crayon_pop_explain.jpg"
        alt="Endless pit of patience"
        style="width:100%;max-width:320px" align="right"
        hspace="8pt" vspace="8pt"></a>

The conclusion of `one of my previous articles
<../../2013/10/40-years-later-we-still-cant-be-friends.html>`_ might have led
you to believe nobody cares about new better ways of sharing the CPU for end
users. That's correct, but still solvable for many scenarios through libraries
like `Grand Central Dispatch (GCD)
<https://en.wikipedia.org/wiki/Grand_Central_Dispatch>`_, so it is a matter of
time until the rest of the industry drags their feet forward. The problem we
really haven't solved is about memory.  From a practical point of view, the CPU
is *sort of* infinite if we look into the dimension of time: no current time
slice for my starved process? OK, let's just wait a few clock ticks more until
we can run. On the other hand, if a process gets any amount of memory, that
memory is lost, completely gone and impossible to recover for any other process
on the machine. In weird situations even the original owner of the memory may
be unable to recover it! Why? What did we do to deserve this punishment?


Memento fragmentation
---------------------

Allocation of `dynamic memory
<http://en.wikipedia.org/wiki/C_dynamic_memory_allocation>`_ is still done
today through a very simple interface. When you want a chunk of memory, you
call `malloc() and later free()
<http://man7.org/linux/man-pages/man3/malloc.3.html>`_. If you are not using C,
your language may provide a different set of primitives, like `new and delete
in C++ <https://en.wikipedia.org/wiki/New_(C%2B%2B)>`_, but the basic idea is
you ask for a chunk of memory, and you later free this chunk of memory. Higher
level languages with *managed memory*, usually implementing a `garbage
collector
<https://en.wikipedia.org/wiki/Garbage_collection_(computer_science)>`_,
alleviate the programmer from doing this task manually but it still exists
there, it's just a little bit hidden.

In any case, the OS has to keep track of what cells in the whole hardware
memory are free to use. And there is always a trade-off between precision of
what byte belongs to whom, and space efficiency. Usually the OS will subdivide
the hardware memory in blocks. Even lower level, the hardware itself might be
able to provide memory to the OS only at the *page* granularity of say 1KB or
4KB. Programs have complex memory allocation patterns. If the program allocates
different chunks, and frees one of them, the remaining chunks may prevent the
shared memory block from being freed, and even make it not usable for future
memory requests. This is called `memory fragmentation
<https://en.wikipedia.org/wiki/Fragmentation_(computing)>`_.

Let's say that the OS imposes memory boundaries of 1KB and you request a
``malloc()`` chunk of 1500 bytes. That will use two pages of memory. Depending
on how clever the OS wants to be, the remaining bytes of the second page might
be unable to other ``malloc()`` requests. In this situation, your process is
effectively losing ``2048 - 1500 = 548`` bytes. If the OS is *clever*, let's
say that it allows you to reuse this space. So we start again with a reserve of
1500 bytes, and get two pages.  Now we request another 1500 bytes, and the OS
being clever gives us one page more, with the second allocation starting right
at the end of the first one.  This is very nice, from the three pages of 1024
bytes we are losing only ``(1024 * 3) - (1500 * 2) = 72`` bytes. Now the
question is, what happens when the first ``malloc()`` is freed? Only the first
page can be freed. But more importantly, what if we now want to ``malloc()``
10KB? The OS is unable to give us that first page, because it is not contiguous
to the other ones we need. Hence, we get a contiguous block of pages *after*
the third page. We have fragmented our own free memory, the first hardware page
is free, but we are not getting it.

Memory allocators are always tricky software to write. Maybe one of the most
famous ones is the one by `Doug Lea
<http://g.oswego.edu/dl/html/malloc.html>`_. That page has a lot of juicy
information, you can read it to get an idea about many more problems memory
allocators have to deal with. I love to rant on the problem of sharing memory
between languages inside the same process.


Sharing is caring
-----------------

.. raw:: html

    <a href="https://instagram.com/p/1hAndMyB2u/"><img
        src="../../../i/crayon_pop_sharing.jpg"
        alt="Gangsta sharing"
        style="width:100%;max-width:320px" align="right"
        hspace="8pt" vspace="8pt"></a>

The memory interface is very minimal, and once a program has hold of a memory
block, the OS guarantees that this block will be available forever to the
program at that specific memory address. Since most programming languages are
based on the idea of pointers, the OS is not able to *move* or reshuffle this
block of memory because somewhere a variable might still point to the old
**address**. Moving this memory around could lead to crashes when this
variable/pointer is later used to read or write to memory.

In summary, dynamic memory handling in most programming languages is tied to
these two very basic restrictions, which are not the fault of the language but
of the foundation OSes provide:

1. The OS doesn't have any idea what the memory is going to be used for, or for
   how long.
2. Once provided, the OS is unable to move this memory later due to guarantees
   to its physical address.

How many times have you written software that depended on these restrictions
being valid? Never? Unless you are writing some kind of `DMA level
<https://en.wikipedia.org/wiki/Direct_memory_access>`_ software, kernel,
audio/video streaming interface, or similar piece of software which is *really*
restricted by the hardware, you are unlikely to ever care **where** the memory
is allocated, or if it actually stays **there** much later. Most software
developers only care about memory being available or not. If there is not
enough, the program just gives up and asks the user to buy more. Still, OSes
are tied to this basic interface since the beginning of time. So you end up
with the problem we described earlier for pages but at the level of whole
processes. 


Memory boundaries
-----------------

If memory issues are already bad between a process and the OS, you have
additional barriers when you want to produce software which involves two or
more different programming languages. Some time ago I started writing `AlPy
<http://pyallegro.sourceforge.net/alpy.php>`_, a small binding between Python
and `Allegro <http://alleg.sourceforge.net>`_. Since Allegro is a C library,
you deal with creation and destruction of bitmaps manually. In Python land, you
rarely if ever notice memory allocation, it is automatic. And there are two
ways to write a binding for Python: you either make memory allocation explicit
to the Python programmer, or you make it implicit.


.. raw:: html

    <br clear="right"><center>
    <a href="https://instagram.com/p/ybmONSGosR/"><img
        src="../../../i/kpop_interracial.jpg"
        alt="Jake Pains"
        style="width:100%;max-width:750px" align="center"
        hspace="8pt" vspace="8pt"></a>
    </center>


An explicit interface would mean that the user creates some ``Bitmap``
placeholder object in Python land, and before using it another initialization
method has to be called on it to reserve the appropriate amount of memory
(which would call the C function).  Later when the user is done with the object
another method is called, and the associated memory is freed, despite the
Python placeholder still being alive and kicking. An implicit interface would
let Python users to create freely as much ``Bitmap`` objects as they want, and
only usage of these objects would trigger allocations (and later deallocation
when the Python object is deleted). The disadvantage of this method is that
memory allocation/freeing is a potentially expensive operation you might want
to control.

In any of these cases, it is possible that objects created at the Python level
which are not necessary any more, but haven't been collected, may prevent newer
objects to be allocated. Let's say that you implement the kind of binding where
the low level memory allocation happens automatically behind the user's back.
Users might want to happily write a loop where they process all the files in a
directory to load them, perform some tweaking on them, then save them to disk.
It could happen that the memory allocated by the ``Bitmap`` objects in one
iteration of the loop is not freed immediately. The next iteration allocates
more memory, and so on. When you look at such software in a memory debugger you
see the memory growing in steps and suddenly drop when the loop finishes and
all the temporary objects can be released at the same time.

Let's twist this a little bit more. In Python it is frequent to cache the
result of expensive operations. Maybe you want to load an image, perform some
operations and store the final result in a dictionary. If the software has to
come back to this image, rather than doing all the operations again, you can
retrieve the cached image from the dictionary. Users love this because their
interaction is immediate. But how do you make Python and C libraries cooperate?
The solution is to delegate memory allocation from both actors into a separate
third party. Instead of C or Python calling ``malloc()`` directly, you write a
separate memory cache library. This library will perform their ``malloc()`` and
``free()``. But now when the Python (or C library) code wants to cache
something, it can mark a bitmap as a `weak reference
<https://en.wikipedia.org/wiki/Weak_reference>`_. These objects go into a
separate pool. If a new ``malloc()`` comes in and the OS doesn't have any more
free memory, the cache library can look through the pool of weak objects and
free one or more of them before giving up.

One interesting artifact of how memory is shared between languages shows its
ugly head to Android programmers when they deal with images. If you take a
brief look at `Square's Picasso library <http://square.github.io/picasso/>`_
and look at the custom image transformations example, look at the following
depressing lines:

```java
Bitmap result = Bitmap.createBitmap(source, x, y, size, size);
if (result != source) {
    source.recycle();
}
```

Any ideas about what ``recycle()`` does? Depending on the Android version,
`bitmap memory is managed in a different way
<https://developer.android.com/training/displaying-bitmaps/manage-memory.html>`_,
and the call to ``recycle()`` *helps* to avoid running out of memory because
the Java ``Bitmap`` object is separate from it's native memory storage, causing
a similar situation to what I described earlier, a Python object preventing a C
malloc'ed image from being freed at the appropriate time. The documentation
says this is only for older Android versions, but I suspect the implementation
of ``recycle()`` is still used in newer ones to signal the OS that most of the
backing memory for the Bitmap can be used for something else at that moment. In
fact, if it weren't really necessary, wouldn't they *deprecate* that API? Huh?
*Unneeded* APIs still in use by the most popular image libraries out there…
sounds like `sane design
<https://en.wikipedia.org/wiki/Cargo_cult_programming>`_. Or maybe not?


Running parallelly with scissors
--------------------------------

.. raw:: html

    <a href="https://instagram.com/p/sKU6jvyB0J/"><img
        src="../../../i/crayon_pop_listens.jpg"
        alt="Don't want to hurt your feelings"
        style="width:100%;max-width:320px" align="right"
        hspace="8pt" vspace="8pt"></a>

This is all a little bit tedious, but doable if all the parties agree on the
mechanism to control memory (aka: not gonna happen). How do you extend this
among separate processes? In an ideal world we would like to have the user open
an image browser. The first time the image browser is loaded all the images in
a specific directory are loaded and cached in memory (four rows of five images,
each 20 mega pixels in size, or about 80 MB of uncompressed memory, for a total
of 1.5GB of RAM required to have them all loaded at once). After browsing some
of them, maybe editing them (more memory for undo required!) the user hears a
sound and receives a new email. The email prompts to `watch some youtube video
<https://www.youtube.com/watch?v=YR92tv29pFU&spfreload=10>`_.  Without closing
the photo software the user opens the web browser to see a streaming video
equivalent to about 150 or 200 MB file. With the video being in Full HD, each
frame takes about 8MB of RAM. Not much, but still some frames might be buffered
for smoother playback.

Even on a machine with just 2GB of RAM this is all doable without problems. But
what happens if there are more images on screen? What if the pictures the user
is handling have higher resolution? What if we would like the video player to
have caching and not have to download or uncompress parts of the stream again
if the user clicks a few seconds back on the playback bar to watch again the
video? All these *niceties* increase the memory usage. Programs don't have
mechanisms to tell the OS "*oh well, I want memory for these images, but the
user has not accessed to them in a while, so maybe you can purge them if their
memory is needed for something else*".  At the moment the closest thing to this
are two mechanisms available in mobile operating systems, which are leading
advances in memory sharing due to their low hardware resources compared to
desktop machines:

1. Provide mechanism for the OS to request cache memory from applications.
2. Make memory handling opaque to the programmer through proxies, so it can be
   freed and recovered at certain points during execution.

In the first category there are methods like Android's
`Application.onLowMemory()
<http://developer.android.com/reference/android/app/Application.html#onLowMemory%28%29>`_
which is called when the overall system is running low on memory, and actively
running processes have to trim their memory usage. On iOS there are similar
methods like `applicationDidReceiveMemoryWarning:
<https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIApplicationDelegate_Protocol/index.html#//apple_ref/occ/intfm/UIApplicationDelegate/applicationDidReceiveMemoryWarning:>`_.
It is worth noting though that methods like `UIViewController.viewDidUnload
<https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIViewController_Class/index.html#//apple_ref/occ/instm/UIViewController/viewDidUnload>`_
have actually been deprecated! I remember watching a WWDC video session where
they explained this method was removed because… people weren't using it
properly causing more crashes than helping out, and anyway most of the memory
was reclaimed through other means (a quick search says this was a `WWDC 2012
session named Evolution of view controllers
<http://stackoverflow.com/a/12509381/172690>`_). Interesting, isn't it?

Actually, that "*through other means*" leads us to the next next category,
which is using proxy elements instead of letting programmer's filthy fingers
touch directly any RAM. In both Android and iOS this happens through the
classes used to display images. Think about it, most of the time when mobile
developers build a user interface they are only *connecting* resources with
objects controlling their appearance on the screen. Meaning, I want the data
contain by this specific filename be displayed at this particular position on
the screen with these resizing properties and relations to other visual
objects.  And for this reason, when one of these mobile applications is
interrupted and goes to the background, since the program is *not really*
touching any of the memory, the OS can actually free the memory used by all
those user interface bitmaps, and when the app comes back to the foreground it
can reload the resources associated with them.

For generic objects, programmers in Java can use a `WeakReference
<http://developer.android.com/reference/java/lang/ref/WeakReference.html>`_.
iOS developers can use `NSCache
<https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/NSCache_Class/>`_.
The unfortunate side of these APIs is that nobody uses them. They are somehow
awkward to use, and I've come to see zero usages of them in other people's
code. I have used them myself only once or twice.

As for the first category, the idea of memory being released when the OS asks
for it is nice until you realise it is all a lie. You see, the OS is allowed to
call those methods only when **you** are in the foreground. So if you build an
app which keeps big data structures (not using those specific cache aware APIs)
and the user switches to another one… you are out of luck, the OS won't call
those methods again. Why? Well, imagine the performance of your app if when
memory is scarce the OS starts running *other apps' code* in the *hope* that
they can free some memory (and hopefully none of those other apps attempt to
run anything that causes **more** memory to be allocated, like, maybe be *evil*
and request some network resource while they got some CPU to play with). What
you end up realizing is that if you **really** want to be a good neighbour to
other running apps you have to essentially flush yourself your caches
**before** being pushed to the background while you are still running, or risk
being killed due to an `out of memory
<http://www.oracle.com/technetwork/articles/servers-storage-dev/oom-killer-1911807.html>`_
situation if the future foreground app tries to allocate memory.  And the
number of mobile programmers who do this is… (depressing answer left as an
exercise for the reader).


Conclusion
----------

.. raw:: html

    <a href="https://instagram.com/p/v8Skk3yB1Z/"><img
        src="../../../i/crayon_pop_christmas.jpg"
        alt="Gangsta sharing"
        style="width:100%;max-width:320px" align="right"
        hspace="8pt" vspace="8pt"></a>

While a lot has been written about memory allocation and fragmentation
prevention techniques (like `regions
<https://en.wikipedia.org/wiki/Region-based_memory_management>`_, quite popular
in video games for level loading), the problems of sharing memory between
different processes, or sharing memory between different languages running in
the same process are rarely talked about because they fall out of the domain of
a single stakeholder. Memory fragmentation is easier to deal with because it is
*yours*. Memory sharing with other processes? Meh, it's *their* fault. Don't
expect any improvements in this area in your lifetime, at least until
programming languages don't incorporate memory sharing primitives in their
languages (or make memory sharing proxies transparent, which is the most
realistic solution as proved by mobile platforms).

And now, get back to your ``malloc()`` and ``free()``!

.. raw:: html

    <br clear="right">

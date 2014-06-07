---
title: Dirrty objects, in dirrty Nimrod
pubDate: 2014-06-07 17:23
modDate: 2014-06-07 17:23
tags: nimrod, programming, objc
---

Dirrty objects, in dirrty Nimrod
================================

This article has been optimized for search engines by using the misspelled word
**dirrty**. If you came here looking for some hot girls, please go instead to
Youtube to watch `Christina Aguilera's Dirrty video
<https://www.youtube.com/watch?v=4Rg3sAb8Id8>`_ where she works it out. At the
moment of writing this article the video records 7.226.476 views, some more
won't hurt. For all the other boring people, welcome again to another technical
article only worth reading while you wait for the compiler to do its job (or
for your browser to render some JavaScript, if you are one of those hipster
types).

In what looks like a distant past, I used to write Objective-C code for the
iPhone. In one of the projects, a little client consuming JSON would fetch news
from a web server and cache them locally using SQLite. The code I initially
wrote worked fine for about 50 to 100 items, which was the expected workload.
Years later this code was moved to another project where the item requirement
jumped to over 600+ items and suddenly the user interface was all jerky. As if
you were using a cheap Android device instead of the silky smooth luxury car
the iPhone feels like (platform fanboys will be glad to know I replicated the
silky smooth experience on Android 2.1 devices with less computing power than a
cereal box).

Certainly 600 didn't seem an incredibly big number (though it was `twice as
Sparta <https://en.wikipedia.org/wiki/300_(comics)>`_, respekt man), so why was
it all slow suddenly?  Fortunately there were two things I could quickly do to
alleviate the problem and not look back:

* SQL transactions.
* Marking objects as `dirrty <https://en.wikipedia.org/wiki/Dirrty>`_.

Experienced Objective-C programmers with knowledge of `Core Data
<https://en.wikipedia.org/wiki/Core_Data>`_ will surely roll their eyes at this
point as both of these problems are handled automatically by Core Data. The SQL
transactions is the obvious facepalm: using a database without taking care of
transactions is like pushing a bicycle instead of riding it. You have this
shiny thingy beside you which helps you and you are ignoring it. But after
placing a few BEGIN/END here and there the saving wasn't instant yet (remember,
you have to aim for perfect, always).

The 600+ item requirement didn't actually come from increased network traffic.
The server would still serve data in chunks of about 50 items. However, the
items would be cached locally until a certain expiration date and thus when new
items arrived the older ones were still there. That was the problem: the code
was blindly saving all the objects even when they had not changed at all.
That's where the **dirrty** flag comes, the code would mark any new or modified
object as **dirrty** and the SQLite saving code would skip the items without
this flag.  With these two new measures in place the client performed again
seemingly instantly and scrolling was fast again even on first generation
devices.


The reference Objective-C implementation
========================================

.. raw:: html

    <a href="https://en.wikipedia.org/wiki/File:Dirrty_Slutdrop.jpg"><img
        src="../../../i/wikipedia_slutdrop.jpg"
        alt="Christina doing the slutdrop"
        style="width:100%;max-width:750px" align="right"
        hspace="8pt" vspace="8pt"></a>

The implementation of the **dirrty** flag is not really hard at all, just
tedious. In Objective-C you tend to build your serialized objects around an
inheritance tree where the base class provides the basic serialization methods.
Subclasses can then call ``super`` and extend the serialization (in my case,
JSON dictionaries) with whatever new properties the parent class was not aware
of.

The first step is to create a data model super class which already contains the
**dirrty** flag. Then you provide setter/getters for properties. In Objective-C
setters/getters can be implemented by the compiler automatically through
``@property`` and ``@synthethize``. But you can also implement them yourself.
In my case I created the following C macros which would expand to setters
marking the **dirrty** flag:

.. raw:: html

    <br clear="right">

::

    #define SS_DIRRTY_ASSIGN_SETTER(NAME,TYPE,VAR) \
    	- (void)NAME:(TYPE)VAR { \
    		VAR ## _ = VAR; \
    		dirrty_ = YES; \
    	}
    
    #define SS_DIRRTY_RETAIN_SETTER(NAME,TYPE,VAR) \
    	- (void)NAME:(TYPE)VAR { \
    		[VAR retain]; \
    		[VAR ## _ release]; \
    		VAR ## _ = VAR; \
    		dirrty_ = YES; \
    	}
    
    // Actual later usage:
    SS_DIRRTY_RETAIN_SETTER(setBody, NSString*, body)
    SS_DIRRTY_RETAIN_SETTER(setFooter, NSString*, footer)

Not the prettiest code in the world, but works fine. There are two versions of
the macro, one for scalar values and another for objects which requires the
``retain`` ``release`` dance. The last two lines would be seen in a subclass
implementation file where they would expand to a setter updating the
``dirrty_`` flag.

::

    sox-drm slutdrop.mp3
    Denied?

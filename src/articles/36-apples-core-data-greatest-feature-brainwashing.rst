---
title: Apple's Core Data greatest feature: brainwashing
pubdate: 2017-05-28 10:45
moddate: 2018-12-06 00:42
tags: apple, design, bureaucracy, multitasking, programming
---

Apple's Core Data greatest feature: brainwashing
================================================

.. raw:: html

    <a href="http://www.idol-grapher.com/1695"
        ><img src="../../../i/core_data_pretty.jpg"
        alt="Core Data, pretty on the outside, but painful once you use it"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>

Now that another project is ending for me, it's always a good idea to review
the good and bad things, a postmortem. This time, thanks to Sir Arthur's Legacy
from Crazy Hipster Land (you know who you are!) I got to deal with Apple's Core
Data *yet* another time, for a project which didn't really need it. Thanks to
Apple being idiots, it's never possible to hard link any kind of their
documentation with confidence because it seems to move every year with each new
SDK update, so I have now the `following documentation link
<https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/index.html>`_
in case you don't know what Core Data is, but who knows for how long it will
last. Your best chance is to Google "Apple's Core Data".

Now, just like any tool, framework, library, etc, you can use stuff just for
the sake of it even if you don't need it. And sometimes the use can be
justified through external reasons, like using a *lesser* programming language
because it is easier to find programmers for your team. But regardless of
justification, Core Data has always made me feel nervous since the first time I
read about it and used it, and now I think I have a clear understanding of why
I've always had such feelings. There are many ways to blame or rant about Core
Data, but I'll be talking about what is wrong from an architectural point of
view, which as far as I know is something that is overlooked. Hence the
brainwashing feature, since most of the people using Core Data (or similar
frameworks) would nail you to a cross if they saw you committing the same
*crimes* in your own code. But Apple is different.


Kaleidoscopic fragments of solutions
------------------------------------

One of the most basic concepts programmers use is the abstraction: we have
vertical and horizontal abstractions. Vertical abstractions are typically those
that simplify interaction, reducing the number of API entry points or adding
convenience functionality on top of another. We even categorize whole
programming languages relative to each other based on the complexity and height
of the abstractions they allow programmers to interact with. Once upon a
time the C programming language was considered a higher level programming
language compared to assembler, but now C is usually considered a low level
programming language compared to those like Python or Scala.

Horizontal abstractions are those that compartmentalize and split components,
they usually impose a generic *interface*. Instead of writing two components
together, tightly coupled, one depending on the other, they can be coupled
loosely through an interface, a horizontal abstraction of each other.  It is a
horizontal abstraction because we still talk at the same level as we were
previous to the abstraction. The utility of such abstractions is that we can
now exchange one part at each end of the interface without the other knowing
there was a change at all.

There are certainly many ways of split or design an app, but the most basic,
simple and effective pattern I've used is to split all applications into three
layers: the user interface, the business logic, and the storage. In fact, best
way to write a user interface is to write it like you were writing it for a
`daemon program <https://en.wikipedia.org/wiki/Daemon_(computing)>`_. A daemon
**does not** require an explicit user interface, it is just a program which
runs without user interaction, and hence does not need a user interface.  But
most of them have one, they can have a command line interface, a telnet
interface, or a graphical interface. Think of web servers like daemons, most of
the time accessing their storage in order to serve web pages, and web browsers
like user interface against them.

The separation is a little bit blurry since the web server *tells* the user
interface what to display, but this kind of abstraction still serves our
purpose, the user interface is separate from the business logic implemented by
the daemon, and certainly ignorant of whatever storage is being used. More
importantly, well designed web servers/daemons/web apps, are also independent
of their storage choice, because they use another abstraction, both vertical
and horizontal: SQL. The SQL language removes developers from the minute
details of how to store a string or an integer, but more importantly it allows
us to change the storage database for an application with minimal or no
explicit changes to it other than some configuration settings (as long as we
are not using some proprietary or vendor specific extension which locked us
in). This is highlighted when the web server app is not even running on the
same machine as the database. We reach thus the highest degree of
compartmentalization: user interface connected through HTTP+HTML to the
business logic, and the business logic connected through SQL/NoSQL to the
storage, each layer in a separate machine, each allowing replacement as long as
the horizontally abstracted interface is respected.


It came from the horizontal dimension!
--------------------------------------

We can classify Core Data as a higher level abstraction over some of the
features it provides, like serialization (you don't need to write explicit
serialization code in most cases) or undo (you don't have to implement the undo
manager yourself). But unfortunately Core Data also provides a poor and
dangerous horizontal abstraction for storage.  In general all abstractions are
both vertical and horizontal at the same time, each axis being stronger or
weaker than the other depending on the original design purpose. Sometimes,
originally designed vertical abstractions become horizontal (the case for
emulators or virtual machines). Core Data itself doesn't necessarily break
horizontal abstraction… but most users do it for convenience. In fact, if you
don't do it, you are loosing big time on most of the higher level abstractions
it provides.

The problem is that Core Data **imposes** it's own threading restrictions on
what you can do with your objects, and this breaks encapsulation (on top of
being generally a hazard). For starters, Core Data objects are associated to a
context, and there is a context per thread/queue. This means that if you take
an object from a thread and pass it to another, you may get `errors like these
<https://stackoverflow.com/questions/14590764/solving-coredata-error-null-cd-rawdata-but-the-object-is-not-being-turned-into>`_.
The implications mean, as you can see in the `accepted answer
<http://stackoverflow.com/a/14591955/172690>`_, that once you start using Core
Data, you *shouldn't* use threading primitives like ``dispatch_async()`` and
should instead replace them with ``[NSManagedObjectContext performBlock:]``
calls. So were did your encapsulation go? If we want to use a library which
works on some kind of objects, unaware of Core Data, and it does some threading
stuff… are you screwed or not? Possibly your best bet is to serialize
everything and forget about threading, or risk runtime problems. Core Data
forces you to handle your data model (presumably the most important thing in
your app, since the business logic operates on it) in a very specific way, and
this silent requirement is propagated elsewhere.

.. raw:: html

    <a href="http://cyidra.tistory.com/852"
        ><img src="../../../i/core_data_back.jpg"
        alt="Core Data, because you love back hugs"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>

Recently Google published the `room persistence library
<https://developer.android.com/topic/libraries/architecture/room.html>`_ for
Android apps after many years of leaving developers to write their own SQL
code.  Through annotations extra code is generated which deals with the lower
level details, but the user is still in control of what happens where. The
library doesn't change how you deal with threads because it doesn't try being
your kitchen sink.  More specifically, read the last section `Addendum: No
object references between entities
<https://developer.android.com/topic/libraries/architecture/room.html#no-object-references>`_
where it shows another *hidden* problem with threading and lazy loading:

    *[…] ORMs usually leave this decision to developers so that they can
    do whatever is best for their app's use cases. Unfortunately,*
    **developers usually end up sharing the model between their app
    and the UI**. *As the UI changes over time, problems occur that
    are difficult to anticipate and debug.*

    *For example, take a UI that loads a list of Book objects, with each book
    having an Author object. You might initially design your queries to use
    lazy loading such that instances of Book use a getAuthor() method to return
    the author. The first invocation of the getAuthor() call queries the
    database. Some time later, you realize that you need to display the author
    name in your app's UI, as well. You can add the method call easily enough,
    as shown in the following code snippet*::
    
        authorNameTextView.setText(user.getAuthor().getName());

    **However, this seemingly innocent change causes the Author table to be
    queried on the main thread […]**.

Lazy loading of properties is another much advertised feature of Core Data, but
as you can see, such *misfeatures* can be problematic if one doesn't double
check every model property access, because costly IO operations are now
implicit and could happen any time without you being able to foresee them.

The obvious solution to this problem is to **contain** Core Data to its storage
layer in your app, and create two objects: one for your model, one for Core
Data, and convert one to the other and vice versa at the boundary. That's why
Google's text says: "*Unfortunately, developers usually end up sharing the
model between their app and the UI*". Nobody using Core Data does this kind of
split.


The invisible red thread of bloat
---------------------------------

On top of affecting the encapsulation of your storage and model layers, using
Core Data in mobile environments tends to bloat your code base because mobile
often require less features than apps found in a desktop environment (Core
Data's original environment). Things like (`extracted from the documentation
<https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/index.html>`_):

* Change tracking and built-in management of undo and redo beyond basic text
  editing.
* Maintenance of change propagation, including maintaining the consistency of
  relationships among objects.
* Lazy loading of objects, partially materialized futures (faulting), and
  copy-on-write data sharing to reduce overhead.
* Optional integration with the application’s controller layer to support user
  interface synchronization.
* Grouping, filtering, and organizing data in memory and in the user interface.
* Automatic support for storing objects in external data repositories.
* Sophisticated query compilation. Instead of writing SQL, you can create
  complex queries by associating an NSPredicate object with a fetch request.
* Version tracking and optimistic locking to support automatic multiwriter
  conflict resolution.

None of these features have been even a requirement in the mobile apps I've
been developing so far, most of them being essentially native versions of
websites with offline features. So whenever I encountered Core Data in a
project, it was merely being used as an interface against SQLite, treated as a
raw database. Quoting again from the documentation, just above that long list
of features:

    Core Data typically decreases by 50 to 70 percent the amount of code you
    write to support the model layer. **This is primarily due to the following
    built-in features that you do not have to implement, test, or optimize**:

As such, given that most mobile uses of Core Data are not using those features,
we should start asking ourselves if the overhead is worth it. And if that 50 to
70 percent happens **only** if we are trying to use those features. For
comparison, in this project all the model layer was in Core Data, but most of
the objects weren't even serialized to disk, and per design shouldn't be, since
they represented transient data. However, once you start with Core Data, it
tentacle rapes your brain, propagating its corruption everywhere. So I decided
to look at the model objects and realised that one point at the object tree
represented the boundary between *things we want to serialize* vs *things we
don't want to serialize*.

::
    $ git show --stat e2183d36fe07ac8ef60c75c29785ee89328616bb
    …
     42 files changed, 243 insertions(+), 659 deletions(-)

There you have a change which transforms 12 objects using Core Data into 6
using it and 6 being plain old classes. No functionality was changed, since
those objects weren't using any Core Data feature at all. That's 416 lines of
less bloat. And if you take a look at typical Core Data libraries (why should a
library or framework *claiming* to reduce your line count require **extra
additional code** to be manageable?) it's the kind of bloat which can be
avoided through code generation, but for some reason Apple engineers decided to
leave that issue in your hands. This is another important point that seems to
be forgotten in the reasoning of most Core Data advocates for mobile, it
doesn't actually save you much if you only use it for basic persistence, like
caching network results. In my experience, projects which used Core Data had
the same amount of work/time spent in the storage layer as those using SQLite
plus some basic Objective-C wrapper. Core Data never saved me any work and
forced me to step into minefield of thread issues.


Conclusion
----------

My point of view on Core Data for mobile is that it doesn't make much sense,
`it's not worth the trouble
<https://davedelong.com/blog/2018/05/09/the-laws-of-core-data/>`_. But it keeps
attracting new developers, unaware of its constraints or its hidden maintenance
costs (hence my title of brainwashing).  Maybe if your mobile app is as feature
full as a desktop app involving content creation (undo), lots of data (lazy
loading), and online storage (iCloud integration) then Core Data makes sense.
But it is awkward at best for most apps which are just some news kind of RSS
reader, diet/weight/exercise trackers, games, small utilities, etc. Apple
ported Core Data from desktop to mobile because it made sense for those who
already invested lot of work on it on the desktop and wanted to share that
work. The appeal is not there if you start a project from scratch and don't
share code with a desktop application, or have no desktop presence at all. My
recommendation is that you should think twice if using Core Data is good for
your future sanity (or mine, since I end up grabbing so many Core Data projects
with problems).

Recently the `Realm mobile database <https://realm.io/>`_ has been getting a
lot of hype, and its features look very tempting. Unfortunately it follows the
same thread model as Core Data, restricting your thread usage and forcing to
`pass identifiers back and forth between threads
<https://realm.io/docs/swift/latest/#passing-instances-across-threads>`_ to
read/write to your *model* objects (or are they **storage layer** objects?). At
least it is cross platform, having implementations for iOS, Android, and even
Microsoft Windows or server back ends, so you get a better deal out of it if
you `know what you are trading
<https://realm.io/docs/swift/latest/#file-size--tracking-of-intermediate-versions>`_
your sanity for (`dependence on a third party
<https://news.realm.io/news/serverless-logic-with-realm-introducing-realm-functions>`_,
possibly forever; `do you remember Parse
<https://en.wikipedia.org/wiki/Parse_(company)>`_?).


In my opinion the best library I've seen so far is
`SQLDelight <https://github.com/square/sqldelight>`_ for Android, which instead
of trying to hide SQL as much as possible, makes it a first class citizen: you
write SQL queries in ``.sq`` files which on top of being integrated with the
IDE (validation, completion, and so forth) generate the mundane code required
to deal with serialization, but without imposing any model. In fact, the
library is strong on interfaces, which your objects need to implement. Those
interfaces are the horizontal abstraction which guarantees that you are the
owner of any thread issues that crop up. So should you, for whatever reason,
replace SQLDelight in the future, or rather the code it produces, you can
freely do so maintaining the existing interface, without having to change the
way your business logic or user interface layers work.

.. raw:: html

    <center>
    <a href="http://www.all-idol.com/1619"><img
        src="../../../i/core_data_conclusion.jpg"
        alt="Core data, I'm not convinced, I still prefer to use a framework with hidden problems, which breaks the storage encapsulation layer than writing a few lines of serialization code"
        style="width:100%;max-width:750px" align="center"
        hspace="8pt" vspace="8pt"></a>
    </center>

::
    $ nim c -r threaded_hello.nim
    eHlol !orlwd

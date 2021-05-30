---
title: Jetbrains backs off on Kotlin/Native memory model, Android devs too stupid to learn new tricks
pubdate: 2021-05-30 20:28
moddate: 2021-05-30 20:28
tags: programming, kotlin, languages, java, design, politics, tools
---

Jetbrains backs off on Kotlin/Native memory model, Android devs too stupid to learn new tricks
==============================================================================================

Now that `Google IO 2021 <https://events.google.com/io/>`_ is behind our backs
and it essentially boiled down to refining existing libs, `fresh coat of paint
<https://arstechnica.com/gadgets/2021/05/google-shows-off-android-12s-huge-ui-overhaul/>`_,
and `copying Apple Privacy policies
<https://android-developers.googleblog.com/2021/05/android-security-and-privacy-recap.html>`_,
the most shocking revelation to me was `Jetbrains update on the Kotlin/Native
memory model
<https://blog.jetbrains.com/kotlin/2021/05/kotlin-native-memory-management-update/>`_
which dropped like a bomb:

    *TL;DR: The original Kotlin/Native memory management approach was very easy
    to implement, but it created a host of problems for developers trying to
    share their Kotlin code between different platforms.*

Of course this reversal is hidden among piles of marketing speech, but is
happily pointed out by the comments, where Roman Elizarov can't say much other
than, *"yeah, we will make that work"*.

This **needed** change comes a bit too late to the party, because most Android
developers with an interest in Kotlin/Native have probably already touched the
big pile of poo that Kotlin/Native memory model is and decided to avoid it, or
are waiting for `somebody else to do the hard work
<https://blog.jetbrains.com/ktor/2021/05/28/ktor-1-6-0-released/>`_. In
`related articles
<https://blog.jetbrains.com/kotlin/2021/05/whats-new-in-kmm-since-going-alpha/>`_
the change is mentioned briefly, but more important than that is the highlight
of study cases where KMM (Kotlin Multiplatform Mobile, implicitly
Kotlin/Native). Why? Well, if you go into advocacy content, you will see on
`Google's own blog <https://android-developers.googleblog.com/2021/05/>`_ that
Kotlin is the most used primary language by professional Android developers and
is included in 80% of the top 1000 apps.

But when I go to `Youtube <https://www.youtube.com>`_, a Google product, it
suggests me videos like `Is Kotlin Multiplatform Mobile Ready for Production?
<https://www.youtube.com/watch?v=L8Xq15NTuCc>`_. Gosh, it does **not** suggest
me videos like "Is Kotlin Android ready for production?", simply because nobody
is doing videos like that, everybody knows Kotlin is perfectly fine, so much
that you get videos titled `Why Kotlin is taking over the world
<https://www.youtube.com/watch?v=oJSkRY392Ag>`_. But KMM? Not so much. I see
frequent *"I made a KMM app"* articles, but again, nobody is writing *"I made a
Kotlin Android app"*. Nobody is interested in something that works, but
everybody advocates things that maybe are not popular for good reasons, or is
writing themselves some CV item for a job hire.

Mutable state between threads is evil
-------------------------------------

.. raw:: html

    <a href="https://idol-grapher.com/1553"
        ><img src="../../../i/42_mutate_shared_memory.jpg"
        alt="Mutate shared memory? Disgusting. What are you, a caveman?"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>

So what happened here? What did we miss? What was wrong and made KMM unpopular
among *the masses*? Well, point 4 of `Nine Highlights form the Kotlin Roadmap
<https://blog.jetbrains.com/kotlin/2021/05/nine-highlights-from-the-kotlin-roadmap/#kn-gc>`_
explains it briefly:

    *"Prepare to say goodbye to your old buddy* ``InvalidMutabilityException``,
    *as you’ll stop seeing it every time you work with Kotlin/Native!"*

When the first Kotlin/Native documentation was published you had to carefully
look for it but it stated that the garbage collector would disallow sharing
memory between threads. At some point after 1.x the documentation started to
mention this more up front, but it doesn't change the fact that it's a pretty
horrible *feature*. And the biggest reason for this being horrible is that
Kotlin/Native attempts (without success) to make Android code shareable with
iOS and fails. It fails not because it won't work, but because **existing**
code won't work.

A happy Android Kotlin programmer will have their own pile of battle tested
code that works perfectly fine on Android. They follow the guides that tell
them to move separate logic into a Kotlin/Native module, recompile, and yep,
everything works. Now they try to run this on iOS and nothing works, everything
crashes. Why? The Android version does not actually use Kotlin/Native, because
Kotlin already runs on the JVM. Making Android use Kotlin/Native *under the
hood* would be potentially worse in terms of performance because the jumps
between JVM and native would decrease the performance. But at least the Android
developer would experience first hand if what they are writing is actually
good, because the compiler or IDE won't help. `Of course nobody has time to
care about shit like that
<https://discuss.kotlinlang.org/t/can-kotlin-jvm-be-memory-strict-like-kotlin-native/14148>`_.

This unfortunate state of affairs means that Android programmers can't actually
test their Kotlin/Native code until they reach out for the iOS version, and the
experience of doing so is terribly more inconvenient and slow than simply
running the Android version. So much, that the usual behaviour is to implement
first the Android version, then try on iOS, see surprise crashes and pull out
your hair trying to figure out why. The better alternative would be to write
code step by step and test it incrementally on iOS, but as mentioned the *jump*
is so cumbersome compared to testing the Android version that nobody cares
(until it's too late).

Another consequence of Kotlin/Native memory model is that most likely no code
you already have will work, because chances are high you are mutating some
class from a different thread that this class was created from. If this sounds
familiar, it's because `I've already mentioned this in the context of Apple's
Core Data or the Realm mobile database
<../../2017/05/apples-core-data-greatest-feature-brainwashing.html>`_ and how
it can fuck up your program if you are not careful enough. Being careful means
that you should not happily pass around classes as you are used to, and instead
make immutable copies that can be shared without danger. But immutable copies
means that if you want to change something now you have to go through hoops to
*refresh* that same data being shared somewhere else.

Consider a typical case of app where the user opens a screen with a list and
the client fetches data from the server to show to the user. Usual pseudo steps would be:

1. UI layer wants data, starts spinning some visual indicator that the app is
   working, then spawns a thread to actually fetch the data.
2. Your background thread actually performs the call to the server (synchronous
   or asynchronous doesn't really matter). The fetched result is likely to be
   parsed from JSON or some other wire representation into your business domain
   objects.
3. Once your background thread finishes and stores the results somewhere, calls
   back the UI thread with the fresh data.
4. The UI thread stops spinning the visual indicator and displays the new data.

The user now touches some item on the list and sees the detailed view and
decides to change something, which requires performing changes on the backend.

1. UI layer requests modification, starts spinning some visual indicator that
   the app is working, then spawns a thread to actually perform a network request
   that changes the data and possibly fetches a new copy of it, just in case.
2. A background thread performs the request, and presuming everything went OK,
   receives new wire representation of your business domain object with the
   updated changes.
3. Once your background thread finishes, it calls the UI thread with the fresh
   data.
4. The UI thread stops spinning the visual indicator and displays the updated
   data.

This would all be great if not for the fact that if the user goes back to the
previous list they will see the old data, because we didn't update it. And here
is where different programmers with different views on architecture clash.
Since the detail view is only updating a single element, and this element is
already viewed in a different screen, one way to handle the situation is to
keep track of the first collection somewhere in memory (`oh no, a scary global
variable! <../..//2013/12/worse-than-global-variables.html>`_), and whenever
your detail view wants to modify the data the business logic code updates the
global array with the new entry and notifies all *observers* that the
collection was updated, requiring them to refresh it. But since the collection
*pointer* is the same, the observers only need to redraw the data, since they
already have access to the globally shared collection.

This wont work in Kotlin/Native, and now the code has to be updated. The
*correct* way to handle this situation is to not let the different observers
have a pointer/reference to the original data, and instead observers should get
a copy of the global list. Now, when the user wants to change any object, the
global list will be updated, and a refresh event will be signalled, but each
observer will have to request a new copy of the list containing the updated
objects.  Nothing really hard, but, you know, it's the kind of thing that it's
pretty difficult to implement incrementally when your already existing app
already shares all of its data everywhere.  You can't just stop the sharing at
some arbitrary boundary and still have it work were you want it, the whole way
you update data across the app requires changing.

And this is only in the **ideal** cases where you have structured your data in
a separate business logic layer with separate threads handling the mutability
of the data. I'm not afraid to say that I have to maintain apps where these
clean boundaries are frequently broken. Say you want to change the data, well,
the first thing the UI layer does is **of course** modify the data itself, then
start the spinner to notify the backend in a thread with the already mutated
object as input, and if the backend fails, the local version is **mutated
again** so as to revert the initial local change. This UI transgression doing
stuff that should be part of the business logic is unfortunate, but if your
employer cuts corners in the time you have to implement features, sometimes you
are stuck with such code and ordered to maintain it (refactor? We don't spend
dollars on that shit here!). For such *bad luck Brian* developers adopting
Kotlin/Native probably means discarding most of its codebase.

Essentially, all Kotlin/Native code runs fine on JVM, but only a subset of JVM
valid code will work at all on Kotlin/Native. And this is a hard rock to
swallow compared to the incredible Java interoperability that has allowed
Kotlin to replace it in many places incrementally. After all, if your old code
doesn't work and you have to write new code, why not use a different tool other
than Kotlin anyway?

.. raw:: html

    <center><a href="https://idol-grapher.com/2043"
        ><img src="../../../i/42_mutating_business_objects.jpg"
        alt="Mutating business objects from the UI layer? I've heard enough. You better start running now or I'm going to solve all your memory model problems once and for all."
        style="width:100%;max-width:750px" align="center"
        hspace="8pt" vspace="8pt"></a></center>


Who cares about garbage collection with separate heaps?
-------------------------------------------------------

Ironically the people caring the most about garbage collectors are probably the
fewest of its actual users: language compiler writers. See, in the examples
above there is no actual performance bottleneck, most of the time your app will
spend waiting seconds to get something from the network. Seconds which are like
ages in terms of CPU time. I've yet to see an UI developer say: *"Oh, bollocks,
I wish the garbage collector was faster because it's the bottleneck of my
app"*.

But that is the life of language compiler writers, because after all, their
pride is in the generated code, and every language programming fanboy is going
to take `any useless micro benchmark as comparison
<https://benchmarksgame-team.pages.debian.net/benchmarksgame/>`_ and laugh and
point at you as a programmer failure because somebody else, with different
language constraints can generate a few loop iterations more per second on a
`Raspberry π <https://www.raspberrypi.org>`_. Loop iterations you probably
won't be spending in any of your actual real life code but which are
tremendously important `for marketing Medium posts <https://medium.com>`_.

It is therefore easy to understand why language compiler developers *prefer* a
garbage collector with separate threads were no memory sharing happens. In
fact, `it's Python's famously Global Interpreter Lock that makes people drag it
into the mud
<https://realpython.com/python-gil/#what-problem-did-the-gil-solve-for-python>`_,
since every object creation/destruction has to *stop the world* and see no
other thread is accessing the same data. On the other hand, Python marketeers,
`those who want to sell you a bridge <https://youtu.be/KVKufdTphKs?t=12m11s>`_,
say its **thanks** to the Global Interpreter Lock that Python is so popular.
You know, like:

- *"Oh my God, look at this sweet Python code"*
- *"Yeah, pretty"*
- *"Look at this other language though, ugh"*
- *"Yuck, so bad, it doesn't tie your runtime performance to a single thread
  like JavaScript?"*
- *"The horror"*

Man, imagine if we had some sort of Virtual Machine which allowed different
threads to **not** have a Global Virtual Machine Lock and `somebody implemented
Python on top of it
<https://stackoverflow.com/questions/1120354/does-jython-have-the-gil>`_. In
any case, probably the 99% of the code that 99% of the programmers of the world
produce today is not performance constrained, yet most of these language
programmers will look at the ridiculous micro benchmarks and discard one
language over another because of some stupid example. As such, new language
programming creators are pressured to improve the performance of silly
examples, and a garbage collector with separate heaps is a total win for these
benchmarks.

When a language implements such a garbage collector it's trading performance.
You suddenly have top performance inside your separate threads, because they
indeed don't have to *stop the world* every time a different threads
allocates/frees memory. But to communicate with other threads you now have the
slowing down of memory copies, since memory available to one thread is not
directly visible in another (unless you play with fire and eventually get an
``InvalidMutabilityException``). So you are trading the individual memory
access overhead with memory sharing overhead that forces you to make copies of
everything that needs sharing. On the bright side you are also avoiding
potential race conditions over shared mutable memory, but since such race
conditions are hard to find and debug people just say *"oh, reboot and try
again"*, and mentally it's not even part of the discussion.

The programming world at large is not ready for a thread model with immutable
data. Mainstream programming languages use for better or worse a totally
mutable memory model, and as such most programmers learn multi threading using
this model, battling race conditions manually with locks, semaphores, queues,
or whatever else they find. Jetbrain has finally found out that all this mental
investment does not want to go away, so they are changing their original tune.
If they kept pushing their original memory model, chances are Kotlin/Native
would never flourish like Kotlin Android has.  Essentially, you can't teach an
old dog new programming tricks.

.. raw:: html

    <center><a href="https://en.wikipedia.org/wiki/On_the_Internet,_nobody_knows_you%27re_a_dog"
        ><img src="../../../i/42-dog-on-the-internet-by-peter-steiner.jpg"
        alt="On the Internet, nobody knows you're a dog"
        style="width:100%;max-width:600px" align="center"
        hspace="8pt" vspace="8pt"></a></center>


Conclusion
----------

It has taken Jetbrains only 4 years to realise Android developers don't like
being `raped <https://www.youtube.com/watch?v=FZ-oTF4ZOK0>`_ by
``InvalidMutabilityException`` whenever their valid JVM code tries to run on
Kotlin/Native. Personally I don't mind, I've already `made peace with my
prejudices <../../2014/03/nimrod-for-cross-platform-software.html>`_ and
accepted that the future is in memory models which disallow sharing mutable
data. But it's easy to look at `reactions of other developers at the thought of
coming back to a mutable world
<https://www.reddit.com/r/Kotlin/comments/nh3qzw/kotlinnative_memory_management_update/>`_
and verify that yes, everybody likes the status quo:

     **Mango1666**: *Fantastic news for kotlin native! The memory
     model made things a bit weird with my even pretty limited scope
     of KMM projects. Having KN act "normal" without changes is
     going to be great*

     **diamond**: *Yeah, this is really good news. I've been working
     with KMP for a while now, and the K/N memory model is a constant
     source of irritation. It's not a total showstopper, but
     definitely a barrier to widespread adoption. I'm looking forward
     to seeing where they go with this.*

Indeed, it's going to be interesting where Roman Elizarov wants to go with this
change, since he seems to be the one spearheading Jetbrain's efforts at
`structured concurrency
<https://elizarov.medium.com/structured-concurrency-722d765aa952>`_ and the
memory model could potentially impact it. After all, once the restriction of
immutable memory between threads is lifted, why learn structured concurrency at
all when your good'ol unstructured concurrency *works™*?.

We could also see these news the other way round: developers are too stupid to
learn new ways to code, and so we must sacrifice future performance for ease of
use.  `This is why we can't have nice things
<https://youtu.be/c18FR87Djh0?t=34>`_.


::
    $ nim c -r threaded_code.nim
    Error, no programmers found.

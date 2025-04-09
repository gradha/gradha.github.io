---
title: Static vs dynamic linking is the wrong discussion
pubdate: 2016-12-26 10:41
moddate: 2016-12-26 10:41
tags: static linking, user experience, design, bureaucracy
---

Static vs dynamic linking is the wrong discussion
=================================================

.. raw:: html

    <a href="http://www.idol-grapher.com/1977"
        ><img src="../../../i/static_things.jpg"
        alt="I've seen things, thing you wouldn't believe"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>

The developer `holy war <http://catb.org/jargon/html/H/holy-wars.html>`_
between static and dynamic linking continues to threaten our peace. Missiles in
favour of `dynamic linking
<https://www.akkadia.org/drepper/no_static_linking.html>`_ or `static linking
<http://sta.li/faq>`_ won't allow us to sleep at night, with debris `reaching
unexpected areas
<https://www.reddit.com/r/learnprogramming/comments/4bo951/eli5_this_whole_fiasco_with_javascript_node_and/>`_
previously thought to be safe. When my own zealotry was at an all high I wrote
that `Users prefer static linking
<../../2013/08/users-prefer-static-linking.html>`_, but the wounds of war have
opened my eyes and I need no more cripples among my friends and family to
understand that we are all wrong and should make peace. Static linking needs to
be banished from our lands, or maybe upgraded into a new concept, but in any
case we need to unite and fight against the true source of our despair:
operating systems.


Useless options
---------------

The main reason developers still argue about static or dynamic linking is
because that's as far as their domain reaches. When developers prepare a
binary, they don't have a say about how this binary will be used, in what
systems, under what conditions. Very few understand or want to implement a
build process which tries to satisfy both static and dynamic linking, since
most of the time it only increases their work with little benefit. More
importantly, the current trend in the consumer facing industry regarding binary
distribution is having a single point of electronic distribution, like Apple
Mac and iOS stores, `Google's Play store <https://play.google.com/store>`_ and
the `Microsoft store <https://www.microsoftstore.com/>`_. If you squint your
eyes a little bit any Linux distro not requiring their users to build their own
binaries has its equivalent store or program repository, but they don't tend to
be considered *stores* since they rarely implement paid software distribution,
and as such, you don't exchange money for software.

With the exception of these Linux *stores*, which don't implement paid software
distribution, the other stores depend on `digital rights management
<https://en.wikipedia.org/wiki/Digital_rights_management>`_ to keep track of
what software is installed and how it is accessed and updated. The key concept
is that whatever developers provide it has to fit inside a sandbox. You can
think of this sandbox as a directory with files and some metadata, but its
security mechanisms extend into the software runtime preventing it from
accessing most files outside of its realm, so as to protect users from
installing malicious software which could erase critical files or siphon
pictures of our beloved ones.

And this makes the battle between static and dynamic linking useless. Do you
want to increase the portability of your software by statically linking all the
libraries you can think of so as to reduce the chance of the end users missing
a dependency on their systems? No need, the app stores guarantee a set of
system libraries which the end user can't alter.

Do you want to reduce the binary footprint by putting common code into a shared
library? Fat chance, the app stores require you to provide yourself the dynamic
library to enforce the sandbox, so you end up carrying the weight of the
library yourself, and users end up carrying the weight of repeated instances of
the library for every program in their systems.

Do you want to apply a single security fix to a highly used shared library and
have your whole system patched? No chance, app stores prevent this
administrator wet dream from happening. Maybe you think dynamic libraries help
with security as in memory address layout randomization? Well, the OS enforces
even stronger security through the sandbox, so it shouldn't really matter.


Sandbox killed the dynamic library
----------------------------------

Discussion for or against dynamic linking is nice for mental masturbation but
the real world out there moving millions of dollars every year in software
doesn't care, and never will. The choice of static vs dynamic linking remains
relevant only to niche environments like embedded systems or servers. And even
server admins gasp with horror how every day more and more applications
`package themselves <http://appimage.org>`_ in a way which renders dynamic
linking useless. Traditional server apps aren't sacred ground, and some admins
find themselves `preparing environments <https://www.docker.com>`_ in a way
where `dynamic linking is not even a concern <https://www.vagrantup.com>`_. Or
maybe they `buy directly such environments <https://sandstorm.io>`_ for apps to
run on.

Dynamic linking is an elegant solution of a more civilized age… er, from a time
where bits were scarce and you paid them through the nose. My first personal
computer with a hard disk had the astonishing storage space of about 40
Megabytes. My latest smartphone, for a fraction of the hard disk's price, holds
32 Gigabytes of data, which is considered little by some, and thus includes an
expansion slot for an SD card should I need more. Arguments in favour of
dynamic linking come from the age of the 40 Megabytes hard drive and today they
are invalid because the context has changed. Linking was something only servers
or computers cared about, but now everybody is suffering one form of linking or
another in our pockets. And I say suffering because none of the current choices
help end users.

In terms of security, the saying that you could patch all the programs in a
system updating a single library, is not applicable any more. It is of course
still technically valid, but patching a dynamic library is a negligible benefit
compared to signing binaries preventing malware from embedding itself in them,
being able to white list software to run in a system, provide delta upgrades to
reduce bandwidth, and essentially prevent any non intended bit manipulation of
the software at rest.

Conclusion
----------

If supporters of dynamic linking want it to exist in the future world, a
sandboxed world, they need to ask for changes in the software which runs other
software: operating systems. Operating systems have always been in charge of
running programs, but now they also take part in the security by enforcing
sandboxes and verifying file signatures. The current crop of sandboxed
technology exists only because it has been built adhoc over whatever
technologies were available. We can do more, we can split dynamic libraries
from their sandbox.  To implement this we need help from those building both
the operating systems and the app stores, since they take part in the
distribution and management of software.

In fact, app stores are `already doing their part for whatever hurts them most
<http://thenextweb.com/apple/2015/06/09/app-thinning-in-ios-9-might-finally-mean-your-16gb-iphone-isnt-always-out-of-space/>`_
trying to split the sandbox in a sensible way. An appropriate solution then
is to have an equivalent to app stores, which would be *library stores*.
Developers may link against several dynamic libraries, but when they upload
their bundle to whatever app store for distribution, hashes of the individual
files can be obtained and if matched against known libraries, removed from the
binary itself and annotated as a required dependency. The end user OS has to
know about this and download the required libraries as needed from the library
store, but this has to be done once, effectively providing dynamic linking. In
case of need, the OS could *replace* stubs inside the app bundles with the
real dynamic library as file system read only hard links.

Since we are dreaming, and in dreams we can achieve anything we want, we could
dream of not only specifying that we link against a dynamic library, but also
specify that we allow the binary to work with a range of libraries, either
specified explicitly or through some range using something similar to `semantic
versioning <http://semver.org>`_. Of course this would be *risky*, since a new
library update could botch up existing software if the developers don't test
binary backwards compatibility. But we are dreaming, right? By default a
programmer would indicate a closed range of versions, and once new versions are
published, through the appropriate app store interface, the range could be
extended for already uploaded binaries after the fact. Is this too manual?
Don't worry, I keep on dreaming: let app stores *try* new versions of the
libraries for different users and sample statistically if the apps continue
working or not. Most app stores provide some sort of automatic cloud testing,
so this could be extended for them if hurting users is too much to ask.

Through the splitting of dynamic libraries from their sandboxes we could
maintain the ideal of dynamic linking without sacrificing the ease of use,
portability and security of sandboxes. It's not like this is science fiction,
deduplication has existed for so long that `there are lucrative service
providers
<https://blogs.dropbox.com/business/2016/04/announcing-project-infinite/>`_
built on the idea that many machines contain most of the same files and only
different versions need to be stored/sent/available. But this requires changes
in the OS, because otherwise end users won't be able to handle the split. Would
you implement this as a daemon running, checking and deduplicating libraries in
the background after each installation?  Would you implement the deduplication
at the filesystem level simplifying the usage of such linking on the host? For
those not using walled gardens, would the OS be able to dynamically package an
app correctly if users wanted to copy it to an external USB disk? I don't know
yet, but at least I think this is the right direction.

It's Christmas, so let's ask for a gift and have this feature ready in 2017.

**UPDATE 2025**: Oh, look, `Google is creating separate sandboxed SDKs which
are downloaded separately but also from the Android Store
<https://youtu.be/a7BMBZE1Nbc?t=270>`_. It seems that it works `by creating a
shim library
<https://privacysandbox.google.com/private-advertising/sdk-runtime/developer-guide/key-concepts#migrate_existing_sdks>`_
which uses Inter Process Communication to talk to the separate SDK running in
an outside process. What did my Nostradamus forecast give me? Just this lousy
blog footnote.

.. raw:: html

    <center>
    <a href="http://mang2goon.tistory.com/465"><img
        src="../../../i/static_rudolph.jpg"
        alt="Sorry about your wish but Santa couldn't come, and I lost his credit k.a.r.d somewhere between Iceland and Norway (T_T)"
        style="width:100%;max-width:750px" align="center"
        hspace="8pt" vspace="8pt"></a>
    </center>

::
    $ fortune
    It is Christmas. You are likely to be eaten by a grue.

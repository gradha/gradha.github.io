---
title: Prototyping a private server for location sharing apps
pubdate: 2018-03-29 18:24
moddate: 2018-03-29 18:24
tags: design, user experience, programming
---

Prototyping a private server for location sharing apps
======================================================

At the beginning of the year 2009 Google created `Google Latitude
<https://en.wikipedia.org/wiki/Google_Latitude>`_, which was a service to
report your own mobile location to their servers so that other users could see
where you are. It is funny to me that I didn't even know such a thing existed
until 2010, when one of my previous coworkers released `Latitudie
<https://web.archive.org/web/20101027221033/http://www.latitudie.com/>`_, which
was an iOS app using Google's Latitude service (I even did buy it and use it
for my nefarious purposes!). But you had to wait until the end of 2011 (`after
possibly the most public false start
<https://arstechnica.com/gadgets/2011/04/how-apple-tracks-your-location-without-your-consent-and-why-it-matters/>`_)
for `Apple to innovate with their Find My Friends app
<https://en.wikipedia.org/wiki/Find_My_Friends>`_, offering pretty much the
same service as Google, except for the fact that you were limited to using
Apple devices and, at least at that time, there was no way to view a friend's
location on a desktop web browser. These limitations set the world on fire, and
thus a new era of location tracking apps *officially* emerged.

Google closed its service in 2013 (and so had to do my friend), but later
embedded the feature directly in their Google Maps app, so that only *their*
official client was able to use *their* servers. Maybe you weren't aware of it
though? If you have a mobile phone with Google Maps you only need to touch the
*hamburguer* menu button on the top left corner of the screen, and select the
**Share my location** option. With Apple prominently adding an icon to all
their devices, and Google having Maps in most of their Android devices, you
would think there was no place for other firms to develop similar apps. But the
funny thing about wheels is that just as they don't seem to stop with the
appropriate momentum, so do software developers seem to endlessly rewrite them.

It is thanks to `mishaps like those from Facebook
<https://arstechnica.com/information-technology/2018/03/your-facebook-data-archive-wont-really-show-everything-facebook-knows-about-you/>`_
that users are starting to realize all the services they enjoy might not have
been paid for themselves through their uploading of food pictures to whatever
social network they use. `Privacy is a word hard to define
<http://www.vs.inf.ethz.ch/publ/papers/privacy-principles.pdf>`_, especially
since `some cultures don't even have such a word
<https://en.wikipedia.org/wiki/Privacy>`_, and what exactly is privacy for a
mobile user, who **depends** on a server? If you ask the backend developer,
privacy might mean to avoid selling or sharing your data to third parties.
Maybe it could mean not storing logs or backups of your data forever. But
whatever concession is made and sold to you, the server *wants to access* your
data, and you build an implicit trust relationship with it.

Is it possible to build a service similar to Google's Latitude or Apple's Find
My Friends which respects the privacy of its users? Even if you *trust* a
company, `can you trust all the people ever employed there
<https://techcrunch.com/2010/09/14/google-engineer-spying-fired/>`_, when some
people have trouble trusting their own family members? In such cases, the best
would be to avoid a server at all and develop something maybe using a
`distributed hash table
<https://en.wikipedia.org/wiki/Distributed_hash_table>`_. Unfortunately
decentralized algorithms tend to penalize mobile users, since they usually
consume more bandwidth, having a negative effect on battery life and possibly
monthly bandwidth allowance. The middle ground solution is to build a server as
dumb as it possibly is: the less it knows, the better for your privacy.


Requirements
------------

What I will outline in the rest of this article are my personal requirements
for configuration and operation of a server working as location relay to
different mobile users. It is unlikely to stop `state level surveillance
<https://www.nsa.gov>`_, but at least it should make it fairly difficult for
not very interested parties in learning about your location, increasing the
work required to invade your privacy and thus making the attacker go look for
easier prey. Since the purpose is having a server somewhere we don't trust, all
the communication will go encrypted (I'm not inventing anything here, just
borrowing from `the Sodium crypto library <https://libsodium.org>`_) and the
server itself will merely serve as a message relay point. Where the server is
located doesn't really matter, it could be `Google App Engine
<https://cloud.google.com/appengine/>`_, a mobile oriented service like `Pusher
<https://pusher.com>`_, or a custom server hosted on the `Sandstorm platform
<https://sandstorm.io>`_.

The main requirement is to avoid giving up on two things to the server: our
social network, and our location. The social network is essentially the list of
people in our address book, telephonic or otherwise. To shortcut problems with
this we can piggyback on existing secure messaging platforms like `Tox
<https://wiki.tox.chat/>`_, `Signal
<https://signal.org/blog/private-contact-discovery/>`_, `Whatsapp
<https://www.whatsapp.com>`_ or `Threema <https://threema.ch/en/>`_. Our
private server will be used to relay our position to other parties, but those
will join us using one of these communication networks, there is no need to
reinvent **that** wheel. For instance, to start broadcasting our position to
other users, we will generate a blob of data, encoded in a URL or file, which
we will send to them through these *alternate communications channel*, and it
will contain all the necessary information to join the location server.

While I have in mind implementing real time communication with something
similar to `websockets <https://en.wikipedia.org/wiki/WebSocket>`_, there is
nothing specific to websockets in the design, you could as well implement it
over `avian carriers <https://en.wikipedia.org/wiki/IP_over_Avian_Carriers>`_.
The first important step is starting a position broadcast, which requires:

* Information about the message relay server and its configuration, usually a
  URL.
* Session identifier or chat name. The server can be used by multiple users at
  the same time, so this identifier restricts communication to just its users.
  It is very easy to construct this value through a `universally unique
  identifier (UUID)
  <https://en.wikipedia.org/wiki/Universally_unique_identifier>`_. Knowing this
  identifier means being able to listen and read all the messages sent between
  the parties. Each session will have a new value, which is enough to conceal
  our broadcast from other users, but we need something more to conceal our
  position from the listening server itself.
* Symmetric encryption key. The same key will be used to encrypt all the
  messages through the active session. Sessions are meant to be short lived
  (sharing your location for 15 minutes, or maybe a few hours), and creating a
  new broadcast (or even broadcasting to two sets of different people at the
  same time!) will create a new symmetric key. Most messages will be a simple
  JSON with the encrypted payload.

Example of URL:

::
    https://server.com:1234/some_path?s=<session id>#<encryption key>

There is no creation or destruction of a chat, or session id, meaning there is
no way for the server or its users know if a broadcast is going on, finished,
didn't yet start, etc. Giving a 404 for a bad session identifier is an
information leak we don't need.

Users joining the session **can** broadcast their joining, but **are not
required to do it**. It is nice to know if other people are listening, but
security/privacy shouldn't depend on this information being available. In case
of broadcasting, the clients will first identify themselves through a random
value (likely another UUID), and *interested* clients may deliver to them
further authentication requests. To simplify things for now, let's presume user
identities are not know and we only have UUIDs, which are needed to distinguish
different users broadcasting their position at the same time. The messages
client machines will exchange with the server are in plaintext JSON:

* ``{"id": "uuid as string", "lat": float, "lon": float}``: message sent by
  whoever is willing to broadcast their position along their random identifier
  picked for this session. The identifier is used by clients to overwrite the
  previous position. The position is presumed to be current at the moment of
  receiving it, with a +/- 1 minute error, broadcasters are presumed to send
  their position at least once every 15 seconds.

And that's it! What else could we want from a minimally viable location
broadcasting project expect, anyway. The former packet will be sent *encrypted*
in a wrapper JSON with the following form:

* ``{"p": "base64 encrypted string"}``: This is what all the listeners to the
  session will see, a basic payload packet where the base64 encoded string has
  to be decrypted with the symmetric session key. All the listeners receive the
  message (except whoever sent it).

With all this setup what we end up with is a server which doesn't even perform
any authentication, authorization or storage at all, it simply forwards
messages here and there to whoever is listening. Starting from this base
experiment we can keep adding features, as long as they don't reduce the
privacy we have achieved so far. The server can't know who we are or where we
are with great precision, they can still know our approximate IP geolocation,
which is information your cell phone provider can also provide to say law
enforcement. Should this be a concern, maybe use a `Tor connection
<https://www.torproject.org>`_ against the server through a proxy like `Orbot
<https://guardianproject.info/apps/orbot/>`_ that won't show your real IP.


The initial libsodium prototype
-------------------------------


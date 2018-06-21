---
title: Prototyping a dumb server for location sharing apps
pubdate: 2018-04-01 02:27
moddate: 2018-04-01 02:27
tags: design, user experience, programming
---

Prototyping a dumb server for location sharing apps
===================================================

.. raw:: html

    <div style="background-color:yellow;float:right;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_01.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

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
location on a desktop web browser. Those limitations set the world on fire, and
thus a new era of location tracking apps *officially* emerged.

.. raw:: html

    <div style="background-color:yellow;float:left;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_02.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

Google closed its service in 2013 (and so had to do my friend), but later
embedded the feature directly in their Google Maps app, so that only *their*
official client was able to use *their* servers. Maybe you weren't aware of it
though? If you have a mobile phone with Google Maps you only need to touch the
*hamburguer* menu button on the corner of the screen, and select the **Share my
location** option. With Apple prominently adding an icon to all their devices,
and Google having Maps in most of their Android devices, you would think there
was no place for other firms to develop similar apps. But the funny thing about
wheels is that just as they don't seem to stop with the appropriate momentum,
so do software developers seem to endlessly rewrite them.

.. raw:: html

    <div style="background-color:yellow;float:right;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_03.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

It is thanks to `mishaps like those from Facebook
<https://arstechnica.com/information-technology/2018/03/your-facebook-data-archive-wont-really-show-everything-facebook-knows-about-you/>`_
that users are starting to realize `all the services they enjoy might not have
been paid for themselves through their uploading of food pictures to whatever
social network they use
<https://www.schneier.com/crypto-gram/archives/2018/0415.html#1>`_. `Privacy is
a word hard to define
<http://www.vs.inf.ethz.ch/publ/papers/privacy-principles.pdf>`_, especially
since `some cultures don't even have such a word
<https://en.wikipedia.org/wiki/Privacy>`_, and what exactly is privacy for a
mobile user, who **depends** on a server? If you ask the backend developer,
privacy might mean to avoid selling or sharing your data to third parties.
Maybe it could mean not storing logs or backups of your data forever. But
whatever concession is made and sold to you, the server *wants to access* your
data, and you build an implicit trust relationship with it.

.. raw:: html

    <div style="background-color:yellow;float:left;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_04.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

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

.. raw:: html

    <div style="background-color:yellow;float:right;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_05.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

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

.. raw:: html

    <div style="background-color:yellow;float:left;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_06.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

The main requirement is to avoid giving up on two things to the server: our
social network, and our location. The social network is essentially the list of
people in our address book, telephonic or otherwise. To shortcut problems with
this we can piggyback on existing secure messaging platforms like `Tox
<https://wiki.tox.chat/>`_, `Signal
<https://signal.org/blog/private-contact-discovery/>`_, `Whatsapp
<https://www.whatsapp.com>`_ or `Threema <https://threema.ch/en/>`_. Our
dumb server will be used to relay our position to other parties, but those
will join us using one of these communication networks, there is no need to
reinvent **that** wheel. For instance, to start broadcasting our position to
other users, we will generate a blob of data, encoded in a URL or file, which
we will send to them through these *alternate communications channel*, and it
will contain all the necessary information to join the location server.

While I have in mind implementing real time communication with something
similar to `websockets <https://en.wikipedia.org/wiki/WebSocket>`_, there is
nothing specific to websockets in the design, you could as well implement it
over `avian carriers <https://en.wikipedia.org/wiki/IP_over_Avian_Carriers>`_
(if you can stomach the latency).  The first important step is starting a
position broadcast and sharing it with others, which requires:

.. raw:: html

    <div style="background-color:yellow;float:right;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_07.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

* Information about the message relay server and its configuration, usually a
  URL.
* Session identifier or chat name. The server can be used by multiple users at
  the same time, so this identifier restricts communication to just its users.
  It is very easy to construct this value through a `universally unique
  identifier (UUID)
  <https://en.wikipedia.org/wiki/Universally_unique_identifier>`_, but it could
  as well be completely 128 bits of randomness. Knowing this identifier means
  being able to listen and read all the messages sent between the parties. Each
  session will have a new value, which is enough to conceal our broadcast from
  other users, but we need something more to conceal our position from the
  listening server itself.
* Symmetric encryption key. The same key will be used to encrypt all the
  messages through the active session. Sessions are meant to be short lived
  (sharing your location for 15 minutes, or maybe a few hours), and creating a
  new broadcast (or even broadcasting to two sets of different people at the
  same time!) will create a new symmetric key. Most messages will be a simple
  JSON with the encrypted payload.

.. raw:: html

    <div style="background-color:yellow;float:left;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_08.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

Example of URL:

::
    https://server.com:1234/some_path?s=<session id>#<encryption key>

There is no creation or destruction of a chat, or session id, meaning there is
no way for the server or its users know if a broadcast is going on, finished,
didn't yet start, etc. Giving a 404 for a bad session identifier is an
information leak we don't need.

Whenever a client connects to a session, that client is assigned a random 32bit
integer user identifier, which is broadcast to other listening users for them
to know somebody has joined. This identifier can be used in more advanced
setups to authenticate users, but for the moment let's presume all users are
simply random and anonymous. A client being disconnected will get a new random
value the next time he joins. The messages client machines will exchange with
the server are in plaintext JSON:

.. raw:: html

    <div style="background-color:yellow;float:right;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_09.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

* ``{"a": "logged_in", "id": 32bit, "t": 64bit}``

  Message received by a new user connecting to a session. From that moment on
  the specified ``id`` will be used for the rest of the connection. The ``t``
  value contains the current server time in milliseconds since the Unix epoch.
  Future messages generated by clients should use this value + the time since
  they joined for each message, which will help with the encrypting.

* ``{"a": "new_user", "id": 32bit}``

  Message sent by the server to other users, they can update their list of
  members in the chat.

.. raw:: html

    <div style="background-color:yellow;float:left;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_10.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

* ``{"a": "logged_out", "id": 32bit}``

  Message sent by the server to whoever is listening indicating that the
  specified ``id`` is no longer valid and won't accept connections. It is
  possible for a reconnecting user to get their previous id, but this shouldn't
  be expected.

* ``{"a": "pos", "lat": float, "lon": float}``

  Message sent by whoever is willing to broadcast their position. This message
  will actually be encrypted (see below) and the wrapper will contain the
  identifier of the sender.  The identifier is used by listening clients to
  overwrite the previous known position of that user, as well as decrypt the
  message.

.. raw:: html

    <div style="background-color:yellow;float:right;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_11.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

And that's it! What else could we want from a minimally viable location
broadcasting project expect, anyway. The ``logged_in``, ``logged_out`` and
``new_user`` messages are sent by the server unencrypted, but  ``pos`` packets
will be sent *encrypted* in a wrapper JSON with the following form:

* ``{"p": "base64 encrypted string", "t": 64bit, "from": 32bit[, "to": 32bit]}``:

  This is what all the listeners to the session will see, a basic payload
  packet where the base64 encoded string has to be decrypted with the symmetric
  session key. All the listeners receive the message (except whoever sent it),
  unless the ``to`` field is present, in which case the message is sent only to
  the addressed user. Delivery is never guaranteed. The ``from`` value is
  inserted by the server (or overwritten if it exists) and identifies the
  source of the message.

  The ``t`` value should be the server's received value during login + the
  current elapsed time when generating the encrypted message. This value exists
  mostly to help the symmetric encryption algorithm, which will be explained
  later below, and is used as part of a nonce to avoid message repetition.

.. raw:: html

    <div style="background-color:yellow;float:left;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_12.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

The server will simply relay all the messages with a ``p`` without doing
anything else with it.  With all this setup what we end up with is a server
which doesn't even perform any authentication, authorization or storage at all,
it simply forwards messages here and there to whoever is listening. Starting
from this base experiment we can keep adding features, as long as they don't
reduce the privacy we have achieved so far. The server can't know who we are or
where we are with great precision, they can still know our approximate IP
geolocation, which is information your cell phone provider can also provide to
say law enforcement.  Should this be a concern, you can hide your real IP with
a `VPN service <https://en.wikipedia.org/wiki/Virtual_private_network>`_ like
`TunnelBear <https://www.tunnelbear.com>`_ or a `Tor connection
<https://www.torproject.org>`_ like the `Orbot
<https://guardianproject.info/apps/orbot/>`_ proxy.


The initial libsodium prototype
-------------------------------

.. raw:: html

    <div style="background-color:yellow;float:right;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_13.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

To verify that the above makes some sense, let's start creating a simple C
example using libsodium to simulate the creation of a session on a non existent
server and a few users talking to each other using the previous protocol. The
only reason this can't be made directly on paper is the part where libsodium
takes place doing it's magic crypto stuff. You can grab the source code from
https://gitlab.com/gradha/prototyping-a-dumb-server-for-location-sharing-apps/,
it contains a basic ``Makefile`` which uses a local custom path for the
libsodium library, so if you have installed libsodium globally it is easier for
you to simply run ``gcc -o test -lsodium *.c`` to compile it. Anyway, here is
the output `form the program
<https://gitlab.com/gradha/prototyping-a-dumb-server-for-location-sharing-apps/blob/master/simulate.c>`_
in case you don't *trust* running it yourself::

    Got session id ebee376ba1bc15ea36924ad4726a373a (base64: 6+43a6G8Feo2kkrUcmo3Og==)
    The encryption key is c53d8859946acbcd1688c3bfec351c8d8d96a838e5f7e3566e702d7d6044c994 (base64: xT2IWZRqy80WiMO/7DUcjY2WqDjl9+NWbnAtfWBEyZQ=)
    A hypothetical URL for web clients could be:
    	https://server.com:1234/path?s=ebee376ba1bc15ea36924ad4726a373a#ebee376ba1bc15ea36924ad4726a373ac53d8859946acbcd1688c3bfec351c8d

    {'a': 'logged_in', 'id': 6050335, 't': 1535922234440000}
    {'a': 'logged_in', 'id': 13250510, 't': 1540391876920000}
    to client 6050335: {'a': 'new_user', 'id': 13250510}
    {'a': 'logged_in', 'id': 103415, 't': 1544861519400000}
    to client 6050335: {'a': 'new_user', 'id': 103415}
    to client 13250510: {'a': 'new_user', 'id': 103415}
    Client ids: 1:6050335, 2:13250510: 3:103415

    client 6050335 wants to send: {'a': 'pos', 'lat': 43.200001, 'lon': 15.935000}
    The encrypted payload is 65 bytes:
    	hex: 563b8e66a1dc501c184912202df335655889f770f30febb57cb17aad1607dc6cac4691fc8c7ae80942c77d04092aa0becd8826aa28b8c08b057e7eb5a167b5c4c3
    	base64: VjuOZqHcUBwYSRIgLfM1ZViJ93DzD+u1fLF6rRYH3GysRpH8jHroCULHfQQJKqC+zYgmqii4wIsFfn61oWe1xMM=
    Server received encrypted JSON: {'p': 'VjuOZqHcUBwYSRIgLfM1ZViJ93DzD+u1fLF6rRYH3GysRpH8jHroCULHfQQJKqC+zYgmqii4wIsFfn61oWe1xMM=', 't': 1544861519400, 'from': 6050335}
    	JSON sent to client 13250510
    	JSON sent to client 103415
    Client decrypted '{'a': 'pos', 'lat': 43.200001, 'lon': 15.935000}'

    secretbox bytes 32
    secretbox nonce bytes 24
    secretbox mac bytes 16
    Simulate EOF

.. raw:: html

    <div style="background-color:yellow;float:left;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_14.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

As you can see most binary outputs are displayed in hexadecimal, and some of
them are also base64 encoded, which is a way of embedding binary data into
plaintext like JSON formats. The first block shows that the libsodium
`randombytes_buf() function
<https://download.libsodium.org/doc/generating_random_data/>`_ is used to
generate both the session identifier **and** the encryption key. As mentioned
above, the session key emulates a UUID 128bit value (16 bytes), which should be
enough to avoid *outside* stalkers to enter the same chat by chance and listen,
but even if they do, or the server is **evil**, there is also the symmetric
encryption key, whose length is 32 bytes, which is the value of the
``crypto_secretbox_KEYBYTES`` constant. The hypothetical URL shows how the
secret could be *safely* sent to other users. Presuming this URL is opened with
a web browser, this hypothetical web page would use some JavaScript trickery to
connect through a websocket to the server, open the channel, and use the
specified encryption key after the hash. Why after? So that the browser doesn't
accidentally send it to the server along the other parameters to remain in some
log file for later decryption. In fact, everything could be after the hash. If
the server is *evil*, we are dead though, since the web browser is getting the
JavaScript from this evil source and who knows what it is doing.

The second block shows the typical login/join behaviour::

    {'a': 'logged_in', 'id': 6050335, 't': 1535922234440000}
    {'a': 'logged_in', 'id': 13250510, 't': 1540391876920000}
    to client 6050335: {'a': 'new_user', 'id': 13250510}
    {'a': 'logged_in', 'id': 103415, 't': 1544861519400000}
    to client 6050335: {'a': 'new_user', 'id': 103415}
    to client 13250510: {'a': 'new_user', 'id': 103415}
    Client ids: 1:6050335, 2:13250510: 3:103415

.. raw:: html

    <div style="background-color:yellow;float:right;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_15.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

The first client joins the session and is assigned the id 6050335. The second
client joins the chat and gets assigned the id 13250510. This event is
broadcast by the server to the first already logged in client. The same dance
happens with the login of the third client, assigned id 103415. The last line
shows the assigned identifiers together. Every run of the simulation will give
you different identifiers, just like it generates different session identifiers
and encryption keys.

All the encryption/decryption goodness is in the third block::

    client 6050335 wants to send: {'a': 'pos', 'lat': 43.200001, 'lon': 15.935000}
    The encrypted payload is 65 bytes:
    	hex: 563b8e66a1dc501c184912202df335655889f770f30febb57cb17aad1607dc6cac4691fc8c7ae80942c77d04092aa0becd8826aa28b8c08b057e7eb5a167b5c4c3
    	base64: VjuOZqHcUBwYSRIgLfM1ZViJ93DzD+u1fLF6rRYH3GysRpH8jHroCULHfQQJKqC+zYgmqii4wIsFfn61oWe1xMM=
    Server received encrypted JSON: {'p': 'VjuOZqHcUBwYSRIgLfM1ZViJ93DzD+u1fLF6rRYH3GysRpH8jHroCULHfQQJKqC+zYgmqii4wIsFfn61oWe1xMM=', 't': 1544861519400, 'from': 6050335}
    	JSON sent to client 13250510
    	JSON sent to client 103415
    Client decrypted '{'a': 'pos', 'lat': 43.200001, 'lon': 15.935000}'

.. raw:: html

    <div style="background-color:yellow;float:left;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_16.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

The first client wants to send the position action JSON with the latitude and
longitude at the time. The simulation calls the `gen_broadcast_pos() function
<https://gitlab.com/gradha/prototyping-a-dumb-server-for-location-sharing-apps/blob/master/client.c#L46-76>`_
which generates the plaintext JSON and then encrypts it. The encryption uses
the libsodium `crypto_secretbox_easy() function
<https://download.libsodium.org/doc/secret-key_cryptography/authenticated_encryption.html>`_,
which requires as input parameters the destination where the cipher text will
be written, the source plain text, the length of the source plain text (we are
saying *text* here but it really is any sequence of bytes, printable or not), a
nonce, and the encryption key. What is the nonce and what do we need it when we
already have an encryption key?

.. raw:: html

    <div style="background-color:yellow;float:right;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_17.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

The nonce is essentially an initialization vector used to randomize more the
output of the encryption, with the purpose of avoiding replay attacks. Since
the same symmetric key is used during a **conversation**, a nasty listener
could perform a `replay attack <https://en.wikipedia.org/wiki/Replay_attack>`_
simply copying the input of a user and sending it to another one. Usually the
current time can be used to avoid such attacks, and in this case what we do is
generate a nonce from the random chat identifier and time given to us by the
server given to us during login. That's what the `gen_nonce() function
<https://gitlab.com/gradha/prototyping-a-dumb-server-for-location-sharing-apps/blob/master/client.c#L25-41>`_
does. libsodium nonces have a length of 24 bytes and we are only filling 11, so
just like we send the encryption key through an external channel to other users
we could send a 13 byte nonce prefix to use, which would defeat the server
being able to serve us always the same identifier/time during login.

.. raw:: html

    <div style="background-color:yellow;float:left;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_18.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

Once sent, we see that the encrypted JSON is sent to the server, and this is
broadcast to the two other listeners. Note how the listeners receive the
encrypted payload and the two changing values that make up the nonce for each
message (the time and sender identifier). Of course the simulation knows
everything and has access to the plaintext JSON, but to verify everything works
the `decrypt_message() function
<https://gitlab.com/gradha/prototyping-a-dumb-server-for-location-sharing-apps/blob/master/client.c#L84-101>`_
takes the message and encryption key and calls libsodium
`crypto_secretbox_open_easy() function
<https://download.libsodium.org/doc/secret-key_cryptography/authenticated_encryption.html>`_
to reverse the decryption. If you modify the simulation program and change a
few bytes here or there, or modify the nonce values you should see the function
failing.

.. raw:: html

    <div style="background-color:yellow;float:right;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_19.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

Finally, the last block of lines shows a few constants which might be of
interest. The first line tells us that symmetric encryption keys need to have a
length of 32 bytes. The second line tells us that the nonce is 24 bytes long.
The last line tells us that ``crypto_secretbox_MACBYTES`` is 16 bytes long.
When we perform symmetric encryption, unless we use some sort of padding the
output should have the same length of bytes as the input. libsodium adds these
16 bytes as a sort of tag which authenticates the encrypted content to verify
that it has not been tampered with during the exchange.


Being user friendly to… users
-----------------------------

.. raw:: html

    <div style="background-color:yellow;float:left;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_20.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

If we ended up implementing the above, we would have a system where we could
use a third party server to relay our position to other users securely as long
as the server (and other parties) weren't aware of the encryption key. But
anonymous users are not fun at all to display, we would like to see who we are
watching or who is watching us as well. Authenticating users is not really
difficult at all, once a client has joined the chat and knows the symmetric
key, they can access the information flow. At that point, we could have a
protocol to ask for/exchange information about ourselves. For example:

* ``{"a": "request_info"}``

  When clients join the session they first thing they can do is send this
  message already encrypted. All the connected users will receive it and send
  their answer. Existing users can as well send this message to the recently
  joined user, but instead of sending this message to the whole channel they
  can use the ``to`` optional parameter of the wrapper to direct the message to
  the new id.

.. raw:: html

    <div style="background-color:yellow;float:right;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_21.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

* ``{"a": "user_info", name: string, "static_id": 64bit}``

  This answer, always directed at a specific user with the unencrypted wrapper
  ``to`` field, would contain the information about the user to display on the
  web or the mobile client, at least a name to make it more human friendly. The
  useful bit could be the ``static_id`` field. Since mobile applications will
  at some point lose their connection to the server, and our dumb server is
  designed to generate a new chat identifier for each login, it might be
  annoying to track the position of the same user uniquely. During the first
  login, clients could assign themselves a static identifier and reuse it for
  all the connections. This static identifier could be appended to the previous
  messages, like the position message.

  In addition to the name, more information about the user could be sent, like
  the hash of an image which would later be requested to be sent and displayed
  as avatar… but then we start getting into useless UI details, like how we
  send the image, or what do we do if the user changes it, etc, which are not
  interesting from our privacy aware point of view.


Slave to the state
------------------

.. raw:: html

    <div style="background-color:yellow;float:left;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_22.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

Another user friendly thing to implement would be state. At the moment clients
can know their positions by asking, but we know not everybody is going to be
online always at the same time. Let's say Alice… erm, `Ah Young
<https://en.wikipedia.org/wiki/Ah_Young>`_ wants to meet with Bo… `Bae Woo-hee
<https://en.wikipedia.org/wiki/Bae_Woo-hee>`_ to discuss future plans after the
disbandment of `Dal Shabet <https://en.wikipedia.org/wiki/Dal_Shabet>`_. Ah
Young wants to share her position while traveling because she doesn't know yet
if she's going to take the bus, the train, or if traffic is going to be ok, so
she creates a session and shares it with Woo-hee using `KakaoTalk
<https://www.kakaocorp.com/service/KakaoTalk?lang=en>`_ for her to be able to
check periodically if she's going to show up at the door. The session is
*created*, but Woo-hee doesn't see the message for the next 15 minutes, and
when she logs in, she is alone in the channel. What gives?

To prevent users from entering empty sessions, which as mentioned before are
not distinguishable from expired links, we would like the server to store our
last position, or a list of people who are known to be invited to the session.
If we **do** control the software of the server, we can extend the public
protocol to let the server store a chunk of binary encrypted information for
each user. In its simplest form we could add to the normal ``p`` encrypted
packet an optional field ``store``, which set to true would tell the server to
*remeber* this packet and associate it to the user. Then, any user logging in
could send a request to fetch all the stored information so far:

.. raw:: html

    <div style="background-color:yellow;float:right;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_23.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

* ``{"a": "see_storage"}``:

  This message sent to the server would not be relayed to other users, instead
  it will trigger the server to flush to the client all the individually stored
  and encrypted messages. The client can decrypt them easily and get the last
  known position of users and see them on the map.

In the case of the previous scenario, Woo-Hee would see the last position of Ah
Young along with a time representing how fresh that position is, which could
give here an approximate idea of where she is or how long it will take here to
reach her. It is better than nothing, but still feels *icky* because the server
has a chunk of information and it knows it is very likely to be a position,
which is what we are preventing to store. Also, if there are other data we
would like to persist for the session, like a chat between users or the avatars
(so that they don't log in to faceless avatars), we would end up with a very
big chunk of encrypted data sent periodically to the server, since we can't
update just a tiny bit of the whole encrypted data.

.. raw:: html

    <div style="background-color:yellow;float:left;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_24.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

If we don't like that, or the server/backend we have selected doesn't allow any
form or storage, we could store the state faking a server through a
**persistent** client.  Chances are you are reading this on some kind of
electronic medium, either a mobile, or a computer. Chances are you can also
leave the computer connected to the internet downloading `Kpop videos day and
night
<https://www.youtube.com/playlist?list=PL2HEDIx6Li8hDUxaa-0cLX2tNrx_brV7G>`_,
or have an old mobile you haven't recycled yet because you might keep it as a
back up of your current phone. In both cases these devices could join the
session and perform the storage actions a trusted server would. In effect, they
replace the server inside our encrypted communications channel.

The big advantage over using the server as storage is that the client emulating
the storage has access to the encryption key. Thus, people sending their
position don't need to identify their packets in any special way, the fake
server will see them and store them. The previous ``see_storage`` command could
also be more fine grained, maybe the client only wants to know the most recent
positions, or maybe it wants to download the user information/avatar of
somebody who has previously joined the session but is now not available. This
fake server could also store the willingness to end the position broadcasting
session, or purge it and disconnect after a set up time by the user creating
the first session. If this fake server client advertises itself as such, new
clients joining the session can by default upload their identity to it to be
available to others even when they are not online.


Out of marbles
--------------

.. raw:: html

    <div style="background-color:yellow;float:right;margin:1px"
        ><a href="http://www.youtube.com/watch?v=gHuZ_yQxtyE"><video autoplay muted loop
        style="width: 166px; height: 166px;"> <source
        src="../../../i/omb_25.mp4" type="video/mp4"
        /> No silly animated videos, good for you!</video></a></div>

At this point, regardless of how fun it is to use libsodium or how cool we feel
for hiding our position to a third party using encryption, we are definitely
running out of marbles. In fact, the next step to raise the ante would be to
switch from symmetric encryption to public/private key encryption, like the
`paranoid guys at Threema <https://threema.ch/en/faq/crypto_differences>`_.
Instead of trusting your secondary communication channel you would not trust
that either, so you need each user to generate their public/private key and
share them in a non online form previous to any online interaction.

But is this all necessary to share temporarily our position to a few people?
Let's consider that mobile users are 99% likely to be using either iOS by Apple
or Android by Google, and both report their position to *the mothership*, for
basic services like tracking the location of your phone in case it gets stolen
and you want to recover it or push a message which obliterates its content. Or
to know *statistically* the chance of running into a traffic jam because many
other Android phones are for some reason stopped in the middle of a highway in
your path instead of travelling at their *usual* speed.  When you dismiss
without thought the *daily cards* which remind you it's time to drive home and
you should take a different route because `there is a traffic jam
<https://www.youtube.com/watch?v=H9SnGn3oKps>`_, isn't then a little bit
paranoid to not trust a random company offering location sharing when you are
already implicitly sharing your location with at least your operating system
provider (and `who knows how many others in case of Android
<https://www.gsmarena.com/cia_nsa_fbi_chiefs_warn_against_buying_huawei_and_zte_phones-news-29618.php>`_)?
Maybe you are one of the few who trust in the `Librem 5 phone
<https://puri.sm/shop/librem-5/>`_, which promises security and privacy? Or you
installed a custom ROM on that Android provided by unknown people who you trust
more than a corporation full of unknown people?

I think that designing servers, protocols, clients, and methods of
communications where all the personal sensitive data is stored in different
compartments helps in whatever failure cases you can think of (theft,
impersonation, surveillance, etc), so it is legitimate to request providers to
use the safest protocols or methods they can afford. But security and privacy
are always a matter of trust, because you are still using that shiny Apple or
Android phone, installing a binary compiled by somebody, who likely didn't read
all the lines of code that went into it, and you need to trust somebody at some
point anyway.  Instead of throwing away thousands at building a fictitious
location sharing protocol running on third party servers it might be wiser and
more economically viable to buy your own server and be done with all this crap.

Speaking of trust, I wouldn't trust the loonatic ramblings of somebody on the
internet. Even less if that person tells you how to implement security while
linking random weird things from time to time to confuse you. In an article
published the 1st of April. Seriously,
`these   <http://knowyourmeme.com/memes/these-are-not-the-droids-you-are-looking-for>`_
`aren't  <https://www.youtube.com/watch?v=ShVRP09NCO4>`_
`the     <https://www.youtube.com/watch?v=BIly131MSyQ>`_
`droids  <https://www.youtube.com/watch?v=KhZCNhUj4AI>`_
`you're  <https://www.youtube.com/watch?v=4K4b9Z9lSwc>`_
`looking <https://www.youtube.com/watch?v=mjknp1nWGjY>`_
`for     <https://www.realdoll.com>`_.


::
    $ nim c -r encrypt.nim too_many_secrets.doc
    Please type your password to apply rot256 encryption:

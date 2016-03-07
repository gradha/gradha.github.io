---
title: Kerf timestamps done almost right: conclusions
pubdate: 2016-03-06 23:54
moddate: 2016-03-06 23:54
tags: design, nim, java, cpp, languages, kerf, programming, swift
---

Kerf timestamps done almost right: conclusions
==============================================

After implementing Kerf's timestamps in several programming languages we should
take a look again at `Scott's original Kerf article
<https://getkerf.wordpress.com/2016/01/19/timestamps-done-right/>`_ and review
its final lessons for future language authors:

.. raw:: html

    <table border="1" bgcolor="#cccccc"><tr><td style="vertical-align: middle;"
    ><b>META NAVIGATION START</b>
    <p>This is a really long article (<a
    href="https://www.youtube.com/watch?v=GUl9_5kK9ts"
    >Look at my horse!</a>) which has
    been split in different chapters because it is (<a
    href="https://www.youtube.com/watch?v=GUl9_5kK9ts"
    >My horse is amazing!</a>) unsuitable for today's average attention span
    and lets me
    maximize (<a href="https://www.youtube.com/watch?v=GUl9_5kK9ts"
    >It tastes like raisins!</a>) page ads.
    <p><b>META NAVIGATION END</b>
    </td><td nowrap>
    <ol>
    <li><a href="kerf-timestamps-done-almost-right-a-new-type.html">a new type?</a>
    <li><a href="kerf-timestamps-done-almost-right-nim.html">Nim</a>
    <li><a href="kerf-timestamps-done-almost-right-c-plus--plus-.html">C++</a>
    <li><a href="kerf-timestamps-done-almost-right-swift.html">Swift</a>
    <li><a href="kerf-timestamps-done-almost-right-wtf…-java.html">WTF… Java?</a>
    <li>conclusions <b>You are here!</b>
    </ol></td></tr></table>


Scott's lessons for future language authors
-------------------------------------------

.. raw:: html
    <a href="http://www.idol-grapher.com/1881"><img
        src="../../../i/kerf_superior.jpg"
        alt="So you wrote a blog article, please tell me more about how that makes you immediately superior to everybody else"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>
    <blockquote><em>

    1. If you query from a database, that type needs to be propagated through
    to the language as a first class type. If this isn't possible to do
    directly, there should be some way of quickly translating between
    classes in the DB and classes that doesn't involve parsing a string
    representation.

.. raw:: html
    </em></blockquote>

And you know what? I agree! The implementation in the different languages is as
optimal as it can get to Kerf's timestamp, since internally it is handled just
like in Kerf, as a simple 64bit value storing elapsed nanoseconds since the
Epoch. If you programming language doesn't support propagating integers as a
first class type, `you are out of luck from the beginning
<https://en.wikipedia.org/wiki/JavaScript>`_. I don't think many new future
language authors would want to make the decision of not supporting plain
integer values.

.. raw:: html
    <blockquote><em>
    
    2. timestamps should be a first class type in your programming language.
    Not an add on type as in R or Python or Java.

.. raw:: html
    </em></blockquote>

I disagree on this one. The implementation of our custom timestamp in Nim, C++
and Swift has shown that it is not necessary to bake timestamps as a language
feature, it is enough to have a language which allows extension by programmers.

But then, Scott makes a jab at Python or Java, which are known for being
terrible languages in terms of performance (no idea about R, sorry). Yes, you
can find specific performant Java code which has been optimized for benchmarks
or you can use `JNI <https://en.wikipedia.org/wiki/Java_Native_Interface>`_ to
call native C libraries. And you can find Python code which runs C underneath
for speed, but that's essentially accepting that the language generally sucks
and you always need to externalize the performance critical paths of your
program.

.. raw:: html
    <blockquote><em>
    
    3. timestamps should have performant and intuitive ways of accessing
    implied fields

.. raw:: html
    </em></blockquote>

Every time the word *intuitive* is used in the context of programming, which is
one of the most alien tasks known to humanity, along with maths or statistics,
a programmer is forced to write Java code. Run, fools, run if you hear this
word, for somebody is trying to sell you a bridge! Accessing implied fields is
a matter of taste, and it can be done anyway. Remember when I added the ``len``
variable to the ``String`` type `in Swift
<kerf-timestamps-done-almost-right-swift.html>`_ just because I'm worth it? If
I had a date library or type which didn't do what I wanted I could extend it
myself without problems.

There is no *performant* type for anything, because performance is context
sensitive. For some tasks Kerf's timestamp will be the most performant
solution. For others it will fail miserably. This is Scott's `faulty
generalization <https://en.wikipedia.org/wiki/Faulty_generalization>`_, trying
to apply the lessons from Kerf's niche audience to general language
programmers.

.. raw:: html
    <blockquote><em>
    
    4. it would be nice if it handles nanoseconds gracefully, even though it is
    hard to measure nanoseconds.

.. raw:: html
    </em></blockquote>

That's OK, `I like nice things too
<https://www.youtube.com/watch?v=I191r0eLdc4>`_. Again, not a problem unless
you are dealing with a terrible terrible programming language.


Implementation summary
----------------------

I'm glad I decided to start writing these articles. They didn't really take a
lot of time to implement and I found some interesting things in the process,
but since I have other priorities in life it simply dragged for weeks. In fact
I believe that writing the articles explaining the implementations took me
**more** time that the implementations themselves, but I never bothered to
check, shame on me. As usual implementing stuff in Nim is a pleasure. C++ was
surprising as well, the syntax sucks but it could deal with the problem like a
champ. Swift was a mixed bag, but I'll let it slide due to its compiler being
relatively very new. Java, LOL, nice try. Here is a summary table with the
score I give to each implementation for its final fidelity to Kerf's timestamp
type:

.. raw:: html

    <table border="1"><tr>
    <th>Language</th>
    <th>Fidelity</th>
    <th>LOCs</th>
    <th>Pleasure to use</th>
    <th>Extra notes</th>
    </tr>

    <tr>
    <td style="vertical-align: middle;">Nim</td>
    <td style="vertical-align: middle;">95%</td>
    <td style="vertical-align: middle;">411</td>
    <td style="vertical-align: middle;">100%</td><td
    >The only thing that keeps Nim from being 100% exact to Kerf is that there
    is no custom syntax to match, and the differences are minor in any
    case.</td></tr>

    <tr>
    <td style="vertical-align: middle;">C++</td>
    <td style="vertical-align: middle;">75%</td>
    <td style="vertical-align: middle;">654</td>
    <td style="vertical-align: middle;">70%</td><td
    >Overloading the STL is icky, and the syntax is complex and sometimes
    obscure.  Fortunately the full functionality of the type can be reproduced,
    but I fear that testing more cases than the ones presented in these
    articles could be problematic. C++ compiler errors are well known for their
    unfriendliness towards beginners.<td></tr>

    <tr>
    <td style="vertical-align: middle;">Swift</td>
    <td style="vertical-align: middle;">65%</td>
    <td style="vertical-align: middle;">443</td>
    <td style="vertical-align: middle;">50%</td><td
    >The fidelity should be higher than C++ once the bugs about complex
    expressions are ironed out and more compact operators can be used. Right
    now the biggest drawback of this language is the extremely slow
    compiler.</td></tr>

    <tr>
    <td style="vertical-align: middle;">Java</td>
    <td style="vertical-align: middle;">10%</td>
    <td style="vertical-align: middle;">571</td>
    <td style="vertical-align: middle;">-42%</td><td
    >Don't worry Java, you will always be special.<td></tr>

    </table>

In case you don't like tables for some reason here is a graphical
representation of the table above in a single picture:


.. raw:: html

    <br clear="right"><center>
    <a href="https://youtu.be/0rtV5esQT6I?t=50"><img
        src="../../../i/kerf_retardedness.jpg"
        alt="Finally, I thought the wall of text would never end"
        style="width:100%;max-width:750px" align="center"
        hspace="8pt" vspace="8pt"></a>
    </center>


Lessons for future blog article writers
---------------------------------------

1. Try to avoid writing sweeping generalizations. You'll always find somebody
   annoyed enough to contradict you with little details that don't matter for
   the point that you are trying to make (making your stuff attractive for
   people to buy it).

2. If you use anecdotes to illustrate your case try to not base the article on
   them, anecdotes tend to be flimsy when scrutinized. Prefer source code
   comparisons which also serve to bore your readers to death and thus prevent
   any complaints about factual errors or mistakes in your logic (dead readers
   don't complain).

3. Beware of programming language discussions, they are a religious topic.
   Tread carefully to avoid stepping on landmines.  If you can't resist
   comparing languages, at least try to compare yourself to equivalent
   languages who can stand their own in a fight. Comparing yourself to lesser
   languages doesn't have merit, it would be like claiming you are the fastest
   runner on earth and showcase this comparing yourself to a `Korean pop idol
   <https://www.youtube.com/watch?v=_YnrVnUoWAU>`_.

4. Put random unrelated pictures or GIFs to spice your endless walls of text.
   Readers are still humans, you know? They'll appreciate the distraction and
   will hopefully have something to laugh about other than your sad article.

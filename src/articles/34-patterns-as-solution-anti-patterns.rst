---
title: Patterns as solution anti-patterns
pubdate: 2016-06-23 23:51
moddate: 2016-06-23 23:51
tags: design, languages, programming, bureaucracy
---

Patterns as solution anti-patterns
==================================

.. raw:: html

    <a href="http://antikpopfangirl.blogspot.com.es/2016/06/the-kpopalypse-guide-to-university-life.html"
        ><img src="../../../i/patterns_university_iu.jpg"
        alt="Unfortunately I'm stupidier than IU"
        style="width:100%;max-width:460px" align="right"
        hspace="8pt" vspace="8pt"></a>

I don't remember the exact time I *crashed* against software design patterns.
Most likely it was my university days, most of the stuff I learnt there I hated
with a passion. But since `you can't hate forever
<http://arcadey.net/2015/05/netizens-finally-start-to-realize-that-they-were-wrong-about-t-aras-bullying-scandal/>`_,
slowly the hate turned into apathy, and at least I stopped trying to run away
from them. Recent `directives <https://youtu.be/t1_Pw563opc?t=35>`_ at my
current workplace have reminded me of patterns, but now I've tried to
understand what drove me crazy about patterns. What makes patterns so vilified
by some, or followed blindly by others like a `religion
<https://www.java.com/>`_? Is there something we can do to avoid the bickering?
Are patterns bad per se, good, or neutral? Is it us who wield them incorrectly?
If you are bored enough and want to waste your time, follow me along this
public introspection. Otherwise my TL;DR for you is patterns can't be taught at
will and making them a requirement for software development is usually a bad
idea.


Building a fictional situation
------------------------------

Programmers tend to gravitate between two extremes: either those who learn
everything by practice (or sometimes reinvent it themselves!), or those who go
to a theory source and learn it hard before even thinking of touching a
machine. Depending on interest, self improvement, years of experience and
environment, people can slide between these extremes. I clearly fall on the
learn by practice category because I love getting dirty with code and hate red
tape. With such a pedigree, at some point I said the following to other
programmers:

    *Programming is like cooking, you can spend hours looking at a cake recipe
    and think you have figured it out, but the truth is that until you actually
    try to make the cake you know nothing.*

And they liked it because it resonated with their experience. For those of you
who don't cook, recipes are essentially instructions to build stuff. Sometimes
more vague, sometimes more detailed, just like many software project
requirements.  But even after planning, even after years of experience, even
after painfully high levels of detail in the spec, all projects end up having
surprise unplanned events.  Let's face it, we are humans and we can't escape
making mistakes either. There is a limit to the amount of *in memory* planning,
or software developing we can do. Just like source code, we can look at it all
day round but at some point we have to sit in front of a debugger and figure
out why it is not working as we intend it to.  To illustrate part of what is
wrong with patterns let me build up two different characters coming from both
ends of our hypothetical learning behaviour spectrum.

.. raw:: html

    <br clear="right"><center>
    <a href="http://www.idol-grapher.com/1644"><img
        src="../../../i/patterns_skeptic.jpg"
        alt="So you mean to tell me software patterns won't save the world?"
        style="width:100%;max-width:750px" align="center"
        hspace="8pt" vspace="8pt"></a>
    </center>

Alice is a hardcore software engineer. She eats assembler and C for breakfast
and spits satellite firmware in the evenings. NASA calls her when everything is
fucked up because she has this getting things done skill which cuts through
bureaucracy like a butter knife through… wait for it: butter. However the deep
specialization has put her in an awkward situation, with few job openings for
her, so she has decided to look into other software fields to expand her
programming expertise.

Bob is on the other hand an ivory tower strategist. He enjoys mastering
patterns in a secluded bunker, far away from the battle field noise. Devouring
book after book, he has ascended to a middle management position and sends wave
after wave of coders to find, corner and annihilate bugs, task, and features
with surgical precision, all working in unison like a German clock.  He's an
expert chess master who would put Kasparov or Deep Blue to great shame. He just
doesn't bother proving it, everything plays out perfectly in his mind.

As different as these two engineers are, they end up meeting in a mobile app
development environment. Both feel unsure and new to the field. Mobile app
development looks like a joke to Alice, all this weird object orientation crap,
building layer after layer of stuff which blinds you from the true code and
bloats the program reducing precious performance. She resolves to keep coding
as usual, as long as the Java compiler doesn't complain about the many global
and static class methods.  After all, it compiles and it works, right? Bob is
also struggling here, some of the management techniques he has learned so far
are a little unwieldy for mobile development, and there are new patterns he had
not heard of before, like `MVVM
<https://en.wikipedia.org/wiki/Model–view–viewmodel>`_ or `VIPER
<http://mutualmobile.github.io/blog/2013/12/04/viper-introduction/>`_. A
`reptilian <https://www.youtube.com/watch?v=3jLaf5qj8cs>`_ pattern? 

The clash between these two different forces of natures happens soon. Bob
reviews pull requests and notices Alice writes code which doesn't fit well into
typical patterns. This cannot be allowed, so Bob tells Alice that she **must**
take some time to read about patterns and apply them.  It's good that software
works, but Alice is not working alone, there is also a team who has to
understand her code, and at any given time new coders might need to pick up the
old code and improve it. How are they going to do that efficiently if the code
doesn't follow the usual patterns? Warnings are given, future source code
commits will be picked at random and reviewed for compliance. If things are not
to his liking, heads will rock and roll.

Ah, well, it's not the first time either Alice has to deal with this kind of
guys, so far from earth they wouldn't recognise their own feet. She starts
reading some stuff online about patterns and oh boy, there are swaths of them
to pick from! Just like at a supermarket there are dozens for each letter of
the alphabet. For a new feature, some kind of download manager, resolves to use
a finite state machine. In the good old days, with nobody watching over her
shoulder a few constants or enums plus a big switch would be enough. But to
meet required standards this time applies the `State pattern
<https://en.wikipedia.org/wiki/State_pattern>`_. The result doesn't end up
pretty, it's the first time she applies this and the result is a little messy
because she doesn't yet grok all the inheritance and getter setter mumbo jumbo,
but it seems to work. The performance must be terrible though, the dozens of
classes are going to be a pain for the CPU's cache as well as not being able to
use constants anywhere because the class instances for each state are dynamic.
It's not clear either how splitting a few pages of code over dozens of source
files in Java makes it easier for others to understand, it feels like the
proliferation of source code files is used only to hide the actual intent of
the code. But once it all works she shrugs and moves on to the next task.

After a while Bob takes a look again at source code commits and sees better
looking code. Unsure about it, he sits down with Alice and tells her to pick
some source code and explain what patter was applied and how. It's showtime,
Alice `turns up the jargon knob to eleven <https://www.xkcd.com/670/>`_ and
explains the state pattern showing all the classes she had to generate. After
crossing a line in his lingo bingo card Bob says he has seen enough and is
satisfied, praising Alice for doing a good job. "*Keep at it and everything
will go smoothly for everybody in the company*". After this *exam* Alice
relaxes and goes back to her original self, since Bob is now busy instilling
the fear of patterns into the hearts of new software engineers joining the
company, and figures she's gained enough trust not to be bothered again with
such silly requests.

The previous scene filled with hyperbole has several things based on the
reality I've experienced multiple times. In no particular order:

* Somebody on the team wants everybody else to move development to a new
  `silver bullet <https://en.wikipedia.org/wiki/No_Silver_Bullet>`_. In this
  case it would be Bob forcing everybody to use software development patterns
  (any, regardless of usefulness!).  But I've seen it also happens with
  somebody *from the trenches* having been recently *illuminated by the ray of
  truth*. The new toys problem.
* New silver bullets have the infuriating habit of *getting in the way*. Thus,
  external rewards and/or punishments are established to help moving in the
  **good** direction. In this case a hypothetical punishment awaits, but maybe
  you have also heard of being paid `per line of code written
  <http://www.yegor256.com/2014/04/11/cost-of-loc.html>`_. The appeal problem.
* Enforcement of the new policy doesn't last long. Either due to interest or
  lack of resources, the new silver bullet is shortly dropped. Even in those
  cases where the new policy is kept for some long time (say half a year or
  more) it usually ends with the person interested in it. Aka, the team doesn't
  adopt it. The interiorization problem.
* In the act of using patterns, not much was actually learnt or improved. In
  fact, we can argue that the wrong things were learnt (how to avoid
  punishment) and the overall result for the software and maintenance was
  worse. The solution problem.


What are software design patterns anyway?
-----------------------------------------

.. raw:: html

    <center>
    <a href="http://thestudio.kr/1877"><img
        src="../../../i/patterns_locs.jpg"
        alt="Very clever… quoting wikipedia to increase the line count"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>
    </center>


We can easily find a readable description of `software design patterns
<https://en.wikipedia.org/wiki/Software_design_pattern>`_, quoting from
Wikipedia:

    *In software engineering, a software design pattern is a general reusable
    solution to a commonly occurring problem within a given context in software
    design. It is not a finished design that can be transformed directly into
    source or machine code. It is a description or template for how to solve a
    problem that can be used in many different situations. Design patterns are
    formalized best practices that the programmer can use to solve common
    problems when designing an application or system.*

Here is the deal breaker for me: they are a solution to **a problem**. We can
go through the four problems mentioned above, but all of them can be traced to
the fact that there was no problem to solve in first place!


The new toys problem
####################

I'm guilty as charged of this. It's way easy to get carried away with a new fad
and try to apply it everywhere. Your new screwdriver requires loose screws, and
you don't have to look far away to find them. Maybe the best way to mitigate
the problem is to experiment first with it without hurting others as this could
blow off the steam from the hot novelty. If you have learned about a new
pattern, try it first in a small, hopefully limited and personal project were
failure is not a problem. Trying to impose a solution to others just because
you read a blog somewhere (ahem) is bad. In fact, the best way to convince a
technical person is to show them how you solved something. Comparing against
the previous way of doing things is usually very effective because measurements
and conclusions can be extracted.

In the case of software design patterns the crucial appeal might be the bold
claim that patterns are "*best practices that blah blah blah blah*". Somebody
reading such a statement can easily ignore all the caveats in the text around
and simply march forward thinking that just by applying patterns everything
will be a best practice.


The appeal problem
##################

Let's say that something actually is better. However, how much better is it? Is
it quantifiable? How long do you have to wait to see the return on investment?
Maybe whatever technique or solution you want to propose to your colleagues has
a very long horizon until it materializes. This can explain why others are
reluctant to adopt it. If the solution can't be seen to produce a benefit in a
short time you are going to have a very difficult way of convincing people.
Given that I'm used to projects spanning years, it's not much of a stretch to
ask for a solution that proves useful after one month, especially when some
firms have a turnover rate that long. The problem might be also one of human
nature, a month can be a long time (especially if you are on crunch time) and
you just forget what and how you were doing earlier. Do you remember what life
was before Google? Which leads us to…


The interiorization problem
###########################

Let's say that we can measure the development speed of a team. Does the team
using this technique work faster? Does it deliver more lines of code, or
features, or epic stories, or whatever jargon you kids are playing with these
days? Once you measure that, you have to think back: was it worth it? Most of
the times I've seen a solution being enforced and applied successfully, the
benefits were lost to the sound of grumbling and teeth gnashing of people
reluctant to change. Starting to run in circles here, if there is no appeal to
a technique, it is hard to make people interiorize the solution.  And if people
don't interiorize the solution, they are not going to apply it willingly. Once
the carrot is removed or the whip stops you go back to your old self and you
merely remember the experience as a waste of time.


The solution problem
####################

The worst of applying a seemingly random solution to a problem is that maybe
there was no problem in first place. Or maybe the solution works but it has
unexpected second effects, like higher maintenance cost. Or maybe you are using
a really superb technique that is so difficult to master few people are able to
use it effectively. `How big is the pool of developers you can pick from?
<http://discuss.fogcreek.com/joelonsoftware/default.asp?cmd=show&ixPost=31402>`_
For example I've wanted for years to be employed in a `Nim
<http://nim-lang.org>`_ project, but so far I'm still waiting to meet another
human being who knows what Nim is.

In the fable above, a competent developer misuses the state pattern and the
source code ends up looking like scorched earth. I've seen this so many times
because for some reason I end up maintaining such code and sometimes I'm still
able to talk to the original culpr… authors. In most cases I get shrugging and
"*orders from above*" excuse. Really, they might be your *minions*, but even
they have an idea or two on what makes the boat float, so maybe talk to them a
little bit and listen to their gripes before imposing something?


The annoying things about patterns
----------------------------------

Despite a software design pattern being good and solving a problem, monitoring
new changes to guarantee compliance, and spending time to teach other people
about patterns, the biggest difficulty is that learning from a third party and
experiencing something first hand are different things. Many times in my life
I've heard other people more experienced and knowledgeable than me to recommend
me something. I agree, say "of course, of course", and when I reach the moment
to put this knowledge into practice… I don't do it. Why?

You may have heard of the `don't repeat yourself (DRY) principle
<https://en.wikipedia.org/wiki/Don%27t_repeat_yourself>`_. To avoid repeating
yourself your brain first has to match a pattern. If the thing you are coding
is slightly different or has some other externality which seems to make it a
separate case, even if you are willing to not repeat yourself you will do so.
The same happens with third party advice, no matter how much certain things are
read about, until they happen to you it's hard to recognize the situation, and
thus reach that portion of your brain which holds the appropriate knowledge for
it.

That's the essential problem with patterns. Knowing about them is nice, but
even if you read about them you still have to experience the problem they try
to solve. And experiencing that usually means consuming time and producing
failures, the most solid things to learn from, but also the worst in terms of
project scale and deadlines. When a pattern is imposed without the recipient
knowing why, or what does it solve, `you can sing about it all day but it will
fall on deaf ears
<http://steved-imaginaryreal.blogspot.com.es/2015/06/the-flub-paradox.html>`_.

Patterns are really just names we apply to repeated solutions. As such they are
nothing more than a taxonomy, they are not a tool themselves. In fact, when I
first read about patterns I realized I was already applying some of them,
without even knowing. But the most annoying thing was reading about this or
that pattern and being left in suspense out of the conversation, only to learn
later I actually knew what was being meant. You can tell others you want to go
outside to walk on `poaceae or gramineae
<https://en.wikipedia.org/wiki/Poaceae>`_, or you can tell them you want to
walk on the grass. Figure out which one of those sentences has a higher chance
of antagonizing others.


Conclusion
----------

Patterns could haunt you forever because some people enjoy wielding their name,
which is not a very productive behaviour. If you want to talk about a pattern
and somebody doesn't know it, don't be a dick and explain it rather than
stating aloud how uneducated people are these days, or what good is the salary
being paid to the victim. Also, don't explain *what* the pattern is, explain
what kind of situation it is trying to solve. Applying a pattern is a matter of
experience, if the people receiving the new knowledge doesn't seem to get it,
don't force them to do it. Monitor their code and let them fail a little,
starting to derail from the optimal path. Once the problem is visible, explain
where it is and how applying the pattern can help.

It is harder to do, it takes much longer, and you need a high willpower to do
it. But if you teach patterns through mistakes, always applied to recent
experiences, patterns will stop being a silver bullet and will look more like
the library of knowledge programmers should visit from time to time to review
and improve their skills. It's a place you should go willingly, putting a gun
to your head won't help.


.. raw:: html

    <center>
    <a href="http://www.idol-grapher.com/1644"><img
        src="../../../i/patterns_rules.jpg"
        alt="The first rule of Pattern Club is: you don't talk about Pattern Club"
        style="width:100%;max-width:750px" align="center"
        hspace="8pt" vspace="8pt"></a>
    </center>

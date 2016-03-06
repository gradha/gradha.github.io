---
title: Kerf timestamps done almost right: C++
pubdate: 2016-03-06 23:51
moddate: 2016-03-06 23:51
tags: design, nim, java, cpp, languages, kerf, programming, swift
---

Kerf timestamps done almost right: C++
======================================

In the `first chapter of the series
<kerf-timestamps-done-almost-right-a-new-type.html>`_ we reached the conclusion
that to implement Kerf's timestamp types we need the following features from a
programming language:

1. Value type semantics with strong typing to avoid mistakes.
2. Instancing types on the stack to avoid slow heap memory allocations and
   alleviate manual memory handling or garbage collector pressure.
3. Custom literals for easier construction of such types.
4. Operator overloading to implement all possible custom operations.
5. Generics are not necessary but help with implementation.

.. raw:: html

    <table border="1" bgcolor="#cccccc"><tr><td style="vertical-align: middle;"
    ><b>META NAVIGATION START</b>
    <p>This is a really long article (<a
    href="http://www.amazon.com/Effective-Modern-Specific-Ways-Improve/dp/1491903996"
    >Buy Effective Modern C++!</a>) which has
    been split in different chapters because it is (<a
    href="http://www.amazon.com/Effective-Modern-Specific-Ways-Improve/dp/1491903996"
    >Effective Modern C++ on sale!</a>) unsuitable for today's average attention span
    and lets me
    maximize (<a href="http://www.amazon.com/Effective-Modern-Specific-Ways-Improve/dp/1491903996"
    >Get Effective Modern C++ now!</a>) page ads.
    <p><b>META NAVIGATION END</b>
    </td><td nowrap>
    <ol>
    <li><a href="kerf-timestamps-done-almost-right-a-new-type.html">a new type?</a>
    <li><a href="kerf-timestamps-done-almost-right-nim.html">Nim</a>
    <li>C++ <b>You are here!</b>
    <li><a href="kerf-timestamps-done-almost-right-swift.html">Swift</a>
    <li><a href="kerf-timestamps-done-almost-right-wtf…-java.html">WTF… Java?</a>
    <li><a href="kerf-timestamps-done-almost-right-conclusions.html">conclusions</a>
    </ol></td></tr></table>

.. raw:: html
    <a href="http://arcturus127.tistory.com/858"><img
        src="../../../i/kerf_cpp.jpg"
        alt="C++?! That language is older than me! How can you even use something like that?"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>

`C++ <https://en.wikipedia.org/wiki/C%2B%2B>`_ is a general purpose programming
language. It has imperative, object-oriented and generic programming features,
while also providing facilities for low-level memory manipulation. Before the
initial standardization in 1998, C++ was developed by Bjarne Stroustrup at Bell
Labs since 1979, as an extension of the C language. Running our requirement
list against C++'s feature set we get:

1. C++ has value type semantics with strong typing to avoid mistakes (yay!).
2. Allows instancing types on the stack, either through strong typedefs or
   through custom structs (yay!).
3. `Allows user-defined literals
   <http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2007/n2378.pdf>`_ (yay!).
4. Allows operator overloading (yay!).
5. Supports generics, but they kind of fall short when you try to extend things
   like the `standard template library (STL)
   <https://en.wikipedia.org/wiki/Standard_Template_Library>`_ (booo). Luckily
   this is not a requirement.

There was a time where I was on top of C++ for work but now I don't follow it.
The implementation I'll show off (`available at GitHub
<https://github.com/gradha/kerf_timestamps_done_almost_right/tree/master/cpp>`_)
is `based on the Nim implementation
<kerf-timestamps-done-almost-right-nim.html>`_ and likely inferior to what you
would get from a hardcore C++ developer. In fact I had to learn a few things to
make my mess compile. The main problem is that C++ has evolved into a complex
syntax which is ambiguous, `requires serious compiler implementations
<http://stackoverflow.com/a/1004737/172690>`_ and looks like `Perl
<https://www.perl.org>`_, so you really have to be practicing it to know all
the rough corners (so you can avoid them).  But you will shortly see for
yourself that these are no barriers to emulate Kerf's timestamp types.


Structs as distinct types
-------------------------

C++ doesn't have `Nim's distinct types
<http://stackoverflow.com/a/1004737/172690>`_ but we can emulate them through
`a structure which contains a single long value
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/time_nanos.h#L7-L30>`_:

```c
struct Nano
{
	long long val; // The timestamp
	// construct a Value from a long long
	constexpr explicit Nano(unsigned long long int x) : val(x) {}

	inline Nano operator+(const Nano& rhs) const;
	inline Nano operator-(const Nano& rhs) const;
	inline Nano operator*(const int& rhs) const;
	inline Nano operator/(const int& rhs) const;
	inline int year(void) const;
	inline int month(void) const;
	inline int week(void) const;
	inline int day(void) const;
	inline int hour(void) const;
	inline int minute(void) const;
	inline int second(void) const;
	inline int millisecond(void) const;
	inline int microsecond(void) const;
	inline int nanosecond(void) const;

	template<typename T>
	std::vector<Nano> operator*(const std::vector<T>& rhs) const;
};
```

Right there you see the ``val`` instance variable and a bunch of forward
declarations for operators and calendar component getters. There are `even more
constants and forward declarations outside of the structure
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/time_nanos.h#L32-L59>`_,
but I tried to make it *clean* putting the implementation of those methods
inside the `time_nanos_inline.h header file
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/time_nanos_inline.h>`_
which is `automatically included by time_nanos.h
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/time_nanos.h#L61>`_.
The user defined literals have to be a ``constexpr``, so they have to be
`included in all the compilations
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/time_nanos_inline.h#L40-L75>`_
for the compiler to be able to inline them. This is essentially the same as the
Nim compiler did, with the difference that in Nim you don't split the header
from the implementation. C++ doesn't have nice built in ``echo()`` like
functions, so we need to `roll our own vector contents dumping code
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/time_nanos_inline.h#L108-L118>`_.
Something similar happens with ``map()`` like functions, the STL `needs help in
the right direction
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/time_nanos_inline.h#L120-L127>`_.

To output a ``Nano`` in C++ object oriented fashion we `overload the <<
operator
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/time_nanos.cpp#L19-L65>`_:

```c
ostream& operator<<(ostream& o, const Nano& x)
{
	assert(x.val >= 0);
	if (x.val < 1) {
		o << "0s";
		return o;
	}

	long long nano = x.val % 1000000000;
	long long seconds = (x.val / 1000000000) % 60;
	long long minutes = x.val / 60000000000;
	long long hours, days, years;

	string buf = string("");
	if (nano) { buf += to_string(nano); buf += "ns"; }
	if (seconds) { buf.insert(0, to_string(seconds) + "s"); }

	if (minutes < 1)
		goto end;

	hours = minutes / 60;
	minutes = minutes % 60;

	if (minutes) { buf.insert(0, to_string(minutes) + "m"); }
	if (hours < 1)
		goto end;

	days = hours / 24;
	hours = hours % 24;

	if (hours) { buf.insert(0, to_string(hours) + "h"); }
	if (days < 1)
		goto end;

	years = days / 365;
	days = days % 365;

	if (days) { buf.insert(0, to_string(days) + "d"); }
	if (years < 1)
		goto end;

	buf.insert(0, to_string(years) + "y");

end:
	o << buf;
	return o;
}
```

As you can see this is a straight copy from the Nim version, which goes
decomposing the value internally and generating the necessary parts of the
string if they are not zero. Not clean, but does the job. The ``Nano`` `unit
testing code
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/time_nanos.cpp#L69-L93>`_
is pretty similar to the previous Nim implementation and even Kerf:

```c
void test_nanos()
{
	cout << "Testing nanos module" << endl << endl;
	cout << Nano(500) << " = " << 500_ns << endl;
	cout << u_second << " = " << 1_s << endl;
	cout << u_minute + u_second + Nano(500)
		<< " = " << 1_i + 1_s + 500_ns << endl;
	cout << u_hour << " = " << 1_h << endl;
	cout << 1_h + 23_i + 45_s << " = " << composed_difference << endl;
	cout << u_day << " = " << 1_d << endl;
	cout << u_year << " = " << 1_y << endl;
	cout << u_year - 1_d << endl;

	const auto a = composed_difference + 3_y + 6_m + 4_d + 12987_ns;
	cout << "total " << a << endl;
	cout << "\tyear " << a.year() << endl;
	cout << "\tmonth " << a.month() << endl;
	cout << "\tday " << a.day() << endl;
	cout << "\thour " << a.hour() << endl;
	cout << "\tminute " << a.minute() << endl;
	cout << "\tsecond " << a.second() << endl;
	cout << "\tmicrosecond " << a.microsecond() << endl;
	cout << "\tmillisecond " << a.millisecond() << endl;
	cout << "\tnanosecond " << a.nanosecond() << endl;
}
```

.. raw:: html
    <a href="http://dijkcrayon.tistory.com/448"><img
        src="../../../i/kerf_ugly.jpg"
        alt="Slightly ugly? I don't want to see what's next"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>

The main differences here are that we are using ``cout`` standard output object
with the ``<<`` operator which has terribly verbose line terminators
(``endl``). However the real code is actually quite similar to the Nim version,
we just have to replace the dot used to separate the literal from the postfix
proc invocation into an underscore (``1_h + 23_i + 45_s``). Of course C++
doesn't let you omit the parentheses in method calls, so the date component
getters like ``year()`` or ``week()`` are slightly ugly.


The Stamp type
--------------

The ``Stamp`` implementation is `not going to surprise anybody, being a copy of
the Nano type with a few changes here and there
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/time_stamp.h#L9-L34>`_.
Here's an excerpt:

```c
struct Stamp {
	long long val;

	// …lots of boring stuff goes here…
};

std::ostream& operator<<(std::ostream& o, const Stamp& x);
constexpr Stamp operator"" _date(const char* x, const size_t len);
```

There is not much to explain here given what has already been said about Nim in
the previous chapter and about C++ in this one.  While the stream ``<<``
operator can be `implemented in a .cpp file
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/time_stamp.cpp#L21-L62>`_
and hidden behind a header file, the string input accepting ``_date`` user
defined literal `has to appear in the header file
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/time_stamp_inline.h#L17-L95>`_:

```c
// Requires C++14 support.
constexpr Stamp operator"" _date(const char* x, const size_t len)
{
	assert(len >= 10 and len < MAX_STAMP_LEN);

	int temp = ((*x++) - '0') * 1000;
	temp += ((*x++) - '0') * 100;
	temp += ((*x++) - '0') * 10;
	temp += ((*x++) - '0') * 1;
	assert(temp >= EPOCH_OFFSET);
	x++;

	Stamp result = Stamp(((long long)temp - EPOCH_OFFSET)
		* ONE_SECOND * 60 * 60 * 24 * 365);

	temp = ((*x++) - '0') * 10;
	temp += (*x++) - '0';
	assert(temp > 0 && temp < 13);
	x++;

	result.val += ((long long)temp - 1) * ONE_SECOND * 60 * 60 * 24 * 30;

	temp = ((*x++) - '0') * 10;
	temp += (*x++) - '0';
	assert(temp > 0 && temp < 32);

	result.val += ((long long)temp - 1) * ONE_SECOND * 60 * 60 * 24;

	if (len < MINUTES_START - 1)
		return result;

	assert('T' == *x);
	x++;

	temp = ((*x++) - '0') * 10;
	temp += (*x++) - '0';
	assert(temp >= 0 && temp < 24);
	result.val += (long long)temp * ONE_SECOND * 60 * 60;

	if (len < SECONDS_START - 1)
		return result;

	assert(':' == *x);
	x++;

	temp = ((*x++) - '0') * 10;
	temp += (*x++) - '0';
	assert(temp >= 0 && temp < 60);
	result.val += (long long)temp * ONE_SECOND * 60;

	if (len < NANOS_START - 1)
		return result;

	assert(':' == *x);
	x++;

	temp = ((*x++) - '0') * 10;
	temp += (*x++) - '0';
	assert(temp >= 0 && temp < 60);
	result.val += (long long)temp * ONE_SECOND;

	if (len > NANOS_START) {
		assert('.' == *x);
		x++;
#define _CHECK() do { if (*x < '0' || *x > '9') return result; } while(0)
		_CHECK(); result.val += (long long)(*x++ - '0') * 100000000;
		_CHECK(); result.val += (long long)(*x++ - '0') * 10000000;
		_CHECK(); result.val += (long long)(*x++ - '0') * 1000000;
		_CHECK(); result.val += (long long)(*x++ - '0') * 100000;
		_CHECK(); result.val += (long long)(*x++ - '0') * 10000;
		_CHECK(); result.val += (long long)(*x++ - '0') * 1000;
		_CHECK(); result.val += (long long)(*x++ - '0') * 100;
		_CHECK(); result.val += (long long)(*x++ - '0') * 10;
		_CHECK(); result.val += (long long)(*x++ - '0') * 1;
#undef _VALID
	}

	return result;
}
```

This implementation looks even uglier thanks to the ``_CHECK()`` define, which
being a nasty pre processor construct uses one of the typical ``do {…}
while(0)`` constructs to avoid surprises. Despite the perceived ugliness the
`final test code still holds its own valiantly
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/time_stamp.cpp#L66-L95>`_:

```c
cout << "Testing stamp module" << endl << endl;

auto a = "2012-01-01"_date;
cout << "let's start at " << a << endl;
cout << "plus one day is " << a + 1_d << endl;
cout << "plus one month is " << a + 1_m << endl;
cout << "plus one month and a day is " << a + 1_m + 1_d << endl;
cout << "…plus 1h15i17s " << a + 1_m + 1_d + 1_h + 15_i + 17_s << endl;
cout << "…plus 23 hours " << a + 1_m + 2_d - 1_h << endl;
cout << "2001.01.01T01"_date << endl;
cout << "2001.01.01T02:01"_date << endl;
cout << "2001.01.01T03:02:01"_date << endl;
cout << "2001.01.01T04:09:02.1"_date << endl;
cout << "2001.01.01T04:09:02.12"_date << endl;
cout << "2001.01.01T04:09:02.123"_date << endl;
cout << "2001.01.01T05:04:03.0123"_date << endl;
cout << "2001.01.01T06:05:04.012345678"_date << endl;
a = "2001.01.01T06:05:04.012345678"_date;
cout << "\tyear " << a.year() << endl;
cout << "\tmonth " << a.month() << endl;
cout << "\tday " << a.day() << endl;
cout << "\thour " << a.hour() << endl;
cout << "\tminute " << a.minute() << endl;
cout << "\tsecond " << a.second() << endl;
cout << "\tmicrosecond " << a.microsecond() << endl;
cout << "\tmillisecond " << a.millisecond() << endl;
cout << "\tnanosecond " << a.nanosecond() << endl;
```

The output is as expected from the Nim and Kerf implementations so it will be
omitted. The input is pretty much the same as Nim, though a little less
flexible and cluttered. But hey, if you are writing C++ for a living you
already `filter out all those signs anyway
<../../2015/04/whitespace-goto-fail.html>`_. Good for you!


The uglier finale
-----------------

For the comparison with the Kef blog examples we wanted to mimic, you can look
at the full source code in the `units.cpp file at GitHub
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/units.cpp#L9>`_.
Just like the previous section the code is similar to Nim, only a little bit
uglier, so I won't copy everything. The new and interesting bits are in `the
use of STL containers
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/units.cpp#L21-L26>`_:

```c
auto r = range(0, 10);
auto offsets = map(r, [] (int i) {
	return (1_m + 1_d + 1_h + 15_i + 17_s) * i;
	});
auto values = map(offsets, [] (Nano x) { return "2012.01.01"_date + x; });
cout << "Example 4: " << values << endl;
```

In the beginning C++ didn't have type inference, but through the years it has
been implemented in the form of the ``auto`` keyword, which avoids us having to
explicitly type whatever ``range()`` or ``map()`` return. And we have to be
glad for that, because the things STL containers return tend to look like
`mythical Cthulhu creatures <https://www.youtube.com/watch?v=3kQuMVffbWA>`_,
not necessarily ugly but with the potential of driving you crazy. Just like in
the Nim implementation we initially take little first steps to define the parts
of the expression, then we `override the necessary operators to make it short
and sweet
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/units.cpp#L28-L30>`_.

```c
cout << "…using helper procs… "
	<< "2012.01.01"_date + (1_m + 1_d + 1_h + 15_i + 17_s) * range(0, 10)
	<< endl;
// Kerf: 2012.01.01 + (1m1d + 1h15i17s) times mapright  range(10)
```

Hah, C++ sweet and short. That's a first, at least for me, but indeed the line
looks comparable to the Kerf version, which was added below as a comment.
Unfortunately I had to give up with the sweet and short version of the last
example, which was `implementing the subscript operator to extract the
components of a sequence
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/cpp/units.cpp#L32-L35>`_:

```c
cout << "Example 5 b[week]: " <<
	map(values, [] (Stamp x) { return x.week(); }) << endl;
cout << "Example 5 b[second]: " <<
	map(values, [] (Stamp x) { return x.second(); }) << endl;
```

Yes, that's the whole ``map()`` call, no subscript operator overload. Why?
Making our custom type as a struct works pretty nicely. However it seems that
`inheriting from vectors to overload operators is not recommended
<http://stackoverflow.com/questions/14420209/overloading-operators-for-vectordouble-class>`_,
and most people suggest using `composition
<http://stackoverflow.com/questions/16660437/vector-and-operator-overloading>`_
which would make the code even uglier and cumbersome. Doable, but I just don't
have the patience to do it. Except for this last *trouble* from an
inexperienced C++ programmer, the C++ language allows us to efficiently
implement Kerf's timestamp and the surrounding operators for the same final
expressiveness. The only problem is the time you need to invest to learn about
all the historical quirks the language has accrued over time and write piles of
code to do things which are one liners in more modern languages.

All in all, not bad for a language born in 1983, from the shadow of the `C
programming language <https://en.wikipedia.org/wiki/C_(programming_language)>`_
which was created in 1972. Let's see what we can do with a newer `hipster
language next… <kerf-timestamps-done-almost-right-swift.html>`_

.. raw:: html

    <br clear="right"><center>
    <a href="http://thestudio.kr/2100"><img
        src="../../../i/kerf_fine.jpg"
        alt="Fine, it works, but look what it did to my hair"
        style="width:100%;max-width:750px" align="center"
        hspace="8pt" vspace="8pt"></a>
    </center>

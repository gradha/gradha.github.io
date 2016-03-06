---
title: Kerf timestamps done almost right: Swift
pubdate: 2016-03-05 18:04
moddate: 2016-03-05 18:04
tags: design, nim, java, cpp, languages, kerf, programming, swift
---

Kerf timestamps done almost right: Swift
========================================

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
    href="http://www.amazon.com/Swift-Programming-Ranch-Guide-Guides/dp/0134398017"
    >Buy Swift Programming!</a>) which has
    been split in different chapters because it is (<a
    href="http://www.amazon.com/Swift-Programming-Ranch-Guide-Guides/dp/0134398017"
    >Swift Programming on sale!</a>) unsuitable for today's average attention span
    and lets me
    maximize (<a href="http://www.amazon.com/Swift-Programming-Ranch-Guide-Guides/dp/0134398017"
    >Get Swift Programming now!</a>) page ads.
    <p><b>META NAVIGATION END</b>
    </td><td nowrap>
    <ol>
    <li><a href="kerf-timestamps-done-almost-right-a-new-type.html">a new type?</a>
    <li><a href="kerf-timestamps-done-almost-right-nim.html">Nim</a>
    <li><a href="kerf-timestamps-done-almost-right-c-plus--plus-.html">C++</a>
    <li>Swift <b>You are here!</b>
    <li><a href="kerf-timestamps-done-almost-right-wtf…-java.html">WTF… Java?</a>
    <li><a href="kerf-timestamps-done-almost-right-conclusions.html">Conclusions</a>
    </ol></td></tr></table>

`Swift <https://en.wikipedia.org/wiki/Swift_(programming_language)>`_ is a
multi-paradigm, compiled programming language created for iOS, OS X, watchOS,
tvOS and Linux development by Apple Inc. Swift is designed to work with Apple's
Cocoa and Cocoa Touch frameworks and the large body of existing Objective-C
code written for Apple products. Swift is intended to be more resilient to
erroneous code ("safer") than Objective-C and also more concise. It is built
with the LLVM compiler framework included in Xcode 6 and later and uses the
Objective-C runtime, which allows C, Objective-C, C++ and Swift code to run
within a single program. Running our requirement
list against Swift's feature set we get:

1. Swift has value type semantics with strong typing to avoid mistakes (yay!).
2. Allows instancing types on the stack through custom structs (yay!).
3. There are no custom literals but we can write literal extensions to fake
   them (ok, I hope).
4. Allows operator overloading (yay!).
5. Supports generics, but they seem daunting to use due to the perceived type
   complexity (hmmmm). Luckily this is not a requirement.

The key concept to understand Swift is that it is bogged down by its mandatory
inheritance. Swift has a very specific task: `replace Objective-C
<https://en.wikipedia.org/wiki/Objective-C>`_. And with such a requirement the
first thing you have to do is being able to interface at binary level with
Objective-C's libraries. This involves interfacing with code that still uses
reference counting below, either manually or through `automatic reference
counting (ARC) <https://en.wikipedia.org/wiki/Automatic_Reference_Counting>`_,
which can be a landmine by itself.  So if you thought that either C++ or
Objective-C having C compatibility was already a handicap, imagine having to
interact with all those together and still present the façade of an
unencumbered language. That may be the reason why the compiler is slow. But
let's not get ahead of ourselves, lets implement first our friendly ``Nano``
and ``Stamp`` structures to appease the Kerf gods.


Faking new types one struct at a time
-------------------------------------

.. raw:: html
    <a href="http://www.idol-grapher.com/1690"><img
        src="../../../i/kerf_banana.jpg"
        alt="Trust me, I'm not a banana, I'm a new timestamp type"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>

Since Swift doesn't have any language support for distinct types `we will have
to revert to writing piles of code
<https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160104/005369.html>`_
just like for the C++ implementation. And copying C++'s implementation we will
create two structs, `let's start with the Nano one
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/time_nanos.swift>`_:

```java
let u_nano = Nano(1)
let u_second = Nano(1_000_000_000)
let u_minute = u_second * 60
let u_hour = u_minute * 60
let u_day = 24 * u_hour
let u_month = 30 * u_day
let u_year = u_day * 365

struct Nano : CustomStringConvertible {
	var value: Int64 = 0

	init(_ x: Int64) { self.value = x }
	init(_ x: Stamp) { self.value = x.value }

	var description: String {
		return …
	}

	var s: String { return description }
	// …more code goes here…
}
```

Unlike C++ or Nim, the first thing that catches the eye is that you can
actually use the ``Nano(1)`` initializer despite the ``Nano`` class not being
known to the compiler on that very first line. Maybe the designers of Swift
thought that forward declarations are bad for human programmers and decided to
get rid of them.  Masses of careless programmers rejoiced, but there is a cost
to pay: non deterministic compilation times. I'm not claiming that the compiler
throws up a dice and decides compilation will take longer on even days, but now
the compiler has to plow forward and keep code in a temporal maybe it
compiles/maybe it doesn't Schrödinger state because some lines later *may* make
the previous code compile. Java eliminated the header vs implementation
duplication problem ages ago without requiring extra work for compilers.  But
in Swift the compiler is required to juggle multiple potential parallel
compilation universes due to language design. Nice, extra gratuitous complexity
for very low end user benefit. I'm so glad I don't have to implement compilers.
Another case of non forward declaration is the secondary ``init(_ x: Stamp)``
initializer. This constructor *converts* the value of a ``Stamp`` to a ``Nano``
despite the ``Stamp`` type not existing yet.

The ramifications of the non forwardness of declarations can also be seen in
the lack of any ``import`` or ``include`` lines. Our ``Nano`` structure
inherits from the ``CustomStringConvertible`` protocol. Where does this
protocol come from? Who knows, the compiler is doing *magic* to include or know
about this protocol beforehand. So again, does the compiler actually scan and
parse all known protocols in its standard library for every simple compilation
unit? That would be crazy, as in batshit crazy, but could explain the slow
compile times.  Just so you know, the ``CustomStringConvertible`` protocol is
required to make our ``Nano`` type valid input to other code expecting objects
conforming to this protocol, like  ``print()``. This protocol defines a
``description`` pseudo variable. This feels arbitrary to me, you can define a
variable which works as a function, and the only difference between a normal
function is that you are not using parentheses to invoke it. But as a user of
the code you have to know which is which or the compiler will give you an
error. There are other ways of making a type conform to a protocol, like using
an extension, we will look at extensions in a moment.

Since the ``description`` pseudo variable of the ``CustomStringConvertible``
protocol is too long, I decided to write an alias as the ``s`` pseudo variable
returning whatever ``description`` does. That custom ``s`` variable is used in
the `following operator functions
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/time_nanos.swift#L105-L115>`_:

```java
func *(lhs: Nano, rhs: Int) -> Nano { return Nano(lhs.value * Int64(rhs)) }
func *(lhs: Int, rhs: Nano) -> Nano { return Nano(Int64(lhs) * rhs.value) }
func +(lhs: Nano, rhs: String) -> String { return lhs.s + rhs }
func +(lhs: String, rhs: Nano) -> String { return lhs + rhs.s }
func +(lhs: Nano, rhs: Nano) -> Nano { return Nano(lhs.value + rhs.value) }
func -(lhs: Nano, rhs: Nano) -> Nano { return Nano(lhs.value - rhs.value) }
func -(lhs: Nano, rhs: Int64) -> Nano { return Nano(lhs.value - rhs) }
func %(lhs: Nano, rhs: Nano) -> Int64 { return lhs.value % rhs.value }
func %(lhs: Int64, rhs: Nano) -> Int64 { return lhs % rhs.value }
func /(lhs: Nano, rhs: Nano) -> Int64 { return lhs.value / rhs.value }
func /(lhs: Int64, rhs: Nano) -> Int64 { return lhs / rhs.value }
```

Of interest is the overloading of the addition operator for string
concatenation, which seems quite normal in Swift land, and it's where I'm using
the ``s`` variable. In `the Nim implementation chapter
<kerf-timestamps-done-almost-right-nim.html>`_ I mentioned that it is better if
string concatenation is done using an operator other than addition. If you use
the same, you can end up writing code whose intent is not clear. Consider the
following lines of potential code:

```java
let normal = Nano(1)
let sneaky = normal.s
print("Values \(sneaky + normal)")
```

The first line defines our ``Nano`` variable, the second converts it to a
string representation. Due to type inference we *might* miss this bit (cue all
the pedants changing their obnoxious style guides to force everybody explicitly
state types everywhere), and the third line prints the values using `string
interpolation
<../../2014/11/swift-string-interpolation-with-nimrod-macros.html>`_. What is
the expected output? The cat is out of the bag, and I have already mentioned
that ``sneaky`` is a string representation. So we will get ``1ns1ns`` printed,
which is two nanoseconds joined together as strings. But maybe the **intent**
was to add numerically those two values? If Swift didn't use the addition
operator for string concatenation this would have not compiled, the compiler
would have told that you can't add a ``Nano`` to a ``String``. Not a serious
issue you say? Right, tell that to those who write numerical crunching code. Or
me, because I made this mistake myself when I was `trying to write Nim code
which looked like Swift using the addition operator
<https://github.com/gradha/kerf_timestamps_done_almost_right/commit/7ef75336bc33a953c118db40d30a939e64d26cbb>`_
(the right side to that equal sign was being concatenated as strings due to the
associativity of the addition operator). In Swift you have to add `defensive
parentheses to make sure you don't make such mistakes
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/time_nanos.swift#L138>`_
or maybe play with the operator priority rules.

In the introduction I said that you can't define custom user literals like in
C++. In Swift we can fake conversions in a similar way to Nim using `literal
extensions
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/time_nanos.swift#L117-L125>`_:

```java
extension Int {
	var ns: Nano { return Nano(Int64(self)) }
	var s: Nano { return self * u_second }
	var i: Nano { return self * u_minute }
	var h: Nano { return self * u_hour }
	var d: Nano { return self * u_day }
	var m: Nano { return self * u_month }
	var y: Nano { return self * u_year }
}
```

The extension tells the compiler that all ``Int`` types have suddenly new
variables called ``ns``, ``s``, ``i``, etc which return ``Nano`` types. With
this extension we can finally write a `thoroughly verbose test case similar to
our previous implementations
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/time_nanos.swift#L131-L151>`_:

```java
print("Testing second operations:\n")
print("\(Nano(500)) = \(500.ns)")
print(Nano(500) + " = " + 500.ns)
print(u_second + " = " + 1.s)
// Uncomment this line to make the swift 2.1.1 compiler cry like a child.
//print(u_minute + u_second + Nano(500) + " = " + 1.i + 1.s + 500.ns)
print("\(u_minute + u_second + Nano(500)) = \(1.i + 1.s + 500.ns)")
print((u_minute + u_second + Nano(500)) + " = " + (1.i + 1.s + 500.ns))
print("\(1.h + 23.i + 45.s) = \(composed_difference) = \(composed_string)")
print("\(u_day) = \(1.d)")
print("\(u_year) = \(1.y)")
print("\(u_year - 1.d)")

let a = composed_difference + 3.y + 6.m + 4.d + 12_987.ns
print("total \(a)")
print("\tyear \(a.year)")
print("\tmonth \(a.month)")
print("\tday \(a.day)")
print("\thour \(a.hour)")
print("\tminute \(a.minute)")
print("\tsecond \(a.second)")
```

As you can see this is the usual test we have been repeating so far, with the
expected output. The syntax is pretty much like Nim's, only harder to read due
to Swift's awkward string interpolation which adds noise in the form of extra
parentheses and backslashes. But, you may have noticed that comment right
there, the one about crying, what the hell is that?


Slowness intermission
---------------------

The Swift compiler is not slow, it is just allowing you to exercise the virtue
of patience. Let's compare the speeds of the Swift 2.1.1 compiler against the
Nim 0.13.0 compiler:

```none
$ time swiftc -o units.exe *.swift

real	0m25.137s
user	0m24.235s
sys	0m0.863s

$ time nim c -o:units.exe units
Hint: system [Processing]
Hint: units [Processing]
Hint: time_nanos [Processing]
Hint: time_stamp [Processing]
Hint: strutils [Processing]
Hint: parseutils [Processing]
Hint: sequtils [Processing]
Users/gradha/project/kerf_timestamps_done_almost_right/nim/units.nim(18, 17) Warning: mapIt is deprecated [Deprecated]
Users/gradha/project/kerf_timestamps_done_almost_right/nim/units.nim(18, 16) Warning: mapIt is deprecated [Deprecated]
Users/gradha/project/kerf_timestamps_done_almost_right/nim/units.nim(19, 22) Warning: mapIt is deprecated [Deprecated]
Users/gradha/project/kerf_timestamps_done_almost_right/nim/units.nim(19, 21) Warning: mapIt is deprecated [Deprecated]
Users/gradha/project/kerf_timestamps_done_almost_right/nim/units.nim(24, 8) Warning: mapIt is deprecated [Deprecated]
Users/gradha/project/kerf_timestamps_done_almost_right/nim/units.nim(24, 7) Warning: mapIt is deprecated [Deprecated]
Users/gradha/project/kerf_timestamps_done_almost_right/nim/units.nim(25, 8) Warning: mapIt is deprecated [Deprecated]
Users/gradha/project/kerf_timestamps_done_almost_right/nim/units.nim(25, 7) Warning: mapIt is deprecated [Deprecated]
CC: units
CC: stdlib_system
CC: time_nanos
CC: time_stamp
CC: stdlib_strutils
CC: stdlib_parseutils
CC: stdlib_sequtils
Hint:  [Link]
Hint: operation successful (13343 lines compiled; 0.374 sec total; 20.204MB; Debug Build) [SuccessX]

real	0m0.384s
user	0m0.445s
sys	0m0.093s
```

Yep, that's right. For a hopefully equivalent implementation (the Swift code is
443 lines long, the Nim version 411 lines long) the Nim compiler takes about
half a second to compile and generate a binary, while the Swift compiler sends
my source code to the NSA for inspection through a slow hybrid goat/pigeon link
in Afghanistan, which takes about 25 seconds, or **50 fucking times more than
the Nim compiler**. These are times from what we could consider *cold boot*,
because the Nim compiler actually halves the compilation time I quoted if it is
allowed to reuse the ``nimcache`` directory from a previous compilation.  On
the other hand running the Swift compiler several times only makes me
consistently more impatient.

But wait, there's more! We haven't yet `uncommented the deadly line of
umpossible compilation
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/time_nanos.swift#L135>`_.
With this line in place, here is the result:

```none
$ time swiftc -o units.exe *.swift
time_nanos.swift:136:2: error: expression was too complex to be solved in reasonable time; consider breaking up the expression into distinct sub-expressions
        print(u_minute + u_second + Nano(500) + " = " + 1.i + 1.s + 500.ns)
        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

real	0m24.637s
user	0m23.967s
sys	0m0.612s
```

Wow, that's a really complex expression. Or maybe not? Let's put into
perspective now the things I complained about earlier:

1. No forward declarations.
2. No need to import protocols, they are magic!
3. `Extremely complex type hierarchies
   <http://blog.krzyzanowskim.com/2015/03/01/swift_madness_of_generic_integer/>`_.
4. Use of the addition operator for String concatenation, but also for numeric
   operations!

Now these things start to add up and the compiler is actually having trouble
with all those parallel Schrödinger universes where an expression could mean
this, or could mean that, or maybe if we compiled a few lines more could mean
something else entirely because a chained sub expression changes its output
type depending on *maybe-even-a-few-lines-more* down the file…! I understand
your pain, Swift compiler. And if you tell me that this is not a fault of
language design, does that mean that the people writing the Swift compiler are
morons?  Ok, ok, that's too harsh, let's not make ad hominem attacks. Also,
Swift is still a language in its infancy, with a shape shifting compiler. I was
testing version 2.1.1, what would happen with newer releases?

```none
$ swiftc -v
Apple Swift version 2.2-dev (LLVM 846c513aa9, Clang 71eca7da8e, Swift 96628e41cc)
Target: x86_64-apple-macosx10.9
$ time swiftc -o units.exe *.swift
time_nanos.swift:136:2: error: expression was too complex to be solved in reasonable time; consider breaking up the expression into distinct sub-expressions
        print(u_minute + u_second + Nano(500) + " = " + 1.i + 1.s + 500.ns)
        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
time_nanos.swift:138:2: error: expression was too complex to be solved in reasonable time; consider breaking up the expression into distinct sub-expressions
        print((u_minute + u_second + Nano(500)) + " = " + (1.i + 1.s + 500.ns))
        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

real	0m29.855s
user	0m28.892s
sys	0m0.670s
```

Oh, right, I forgot to comment out that *deadly complex expression*:

```none
$ git checkout time_nanos.swift
$ time swiftc -o units.exe *.swift
time_nanos.swift:138:2: error: expression was too complex to be solved in reasonable time; consider breaking up the expression into distinct sub-expressions
        print((u_minute + u_second + Nano(500)) + " = " + (1.i + 1.s + 500.ns))
        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

real	0m26.188s
user	0m25.619s
sys	0m0.546s
```

Wow, that's pretty awesome, the 2.2-dev version is **going backwards** and
making previously easy to compile expression **umpossible complex** now. Wait,
let's not give up here, we are so close to success I can smell it, let's try
the latest and greatest:

```none
$ swiftc -v
Apple Swift version 3.0-dev (LLVM b361b0fc05, Clang 11493b0f62, Swift 24a0c3de75)
Target: x86_64-apple-macosx10.9
$ time swiftc -o units.exe *.swift
time_stamp.swift:199:3: warning: 'inout' before a parameter name is deprecated, place it before the parameter type instead
                inout _ token: String,
                ^~~~~~
                               inout 
time_stamp.swift:199:3: warning: 'inout' before a parameter name is deprecated, place it before the parameter type instead
                inout _ token: String,
                ^~~~~~
                               inout 
time_nanos.swift:138:2: error: expression was too complex to be solved in reasonable time; consider breaking up the expression into distinct sub-expressions
        print((u_minute + u_second + Nano(500)) + " = " + (1.i + 1.s + 500.ns))
        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

real	0m29.556s
user	0m28.732s
sys	0m0.532s
```

.. raw:: html
    <a href="http://mang2goon.tistory.com/438"><img
        src="../../../i/kerf_excuses.jpg"
        alt="Trust me, I'm not a banana, I'm a new timestamp type"
        style="width:100%;max-width:600px" align="right"
        hspace="8pt" vspace="8pt"></a>

So the compiler takes 4s more to tell me that a parameter is deprecated but is
still unable to handle that expression. Thanks, Swift compiler, that warning is
really helpful, unlike actually producing a binary I can run. Of course I
reported this as `bug SR-838 with a reduced test case that runs faster
<https://bugs.swift.org/browse/SR-838?jql=text%20~%20%22expression%20was%20too%20complex%22>`_ (you can get `the reduced comparison test from GitHub <https://github.com/gradha/kerf_timestamps_done_almost_right/tree/master/swift/performance_problems>`_.
Browsing their repo looks like other people are also experiencing such
compilation problems with apparently less complex code. This experience makes
me doubt Swift's viable future as a nice programming language `unless waiting
for the compiler is your cup of tea <https://xkcd.com/303/>`_. Also the bug
tracker feels a little bit desolate. If it is anything like `the old one
<http://fixradarorgtfo.com>`_ I won't bother with future reports.

So now that the intermission is done, keep in mind that you need Swift compiler
version 2.1.1 or this little exercise might be too much to handle!


One Stamp after another
-----------------------

If you had not enough protocols yet, you will squeal of joy to find that `we
ourselves define a new TimeComponents protocol for the Stamp
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/time_stamp.swift#L13-L26>`_:

```java
protocol TimeComponents {
	var year: Int { get }
	var week: Int { get }
	var month: Int { get }
	var day: Int { get }
	var hour: Int { get }
	var minute: Int { get }
	var second: Int { get }
	var microsecond: Int { get }
	var millisecond: Int { get }
	var nanosecond: Int { get }
}

struct Stamp : CustomStringConvertible, TimeComponents {
	var value: Int64 = 0
	… more code here…
}
```

For the ``Nano`` struct I didn't apply this protocol. The reason to create and
use this protocol is that later we want to extend the ``Array`` type, a generic
collection type, with this protocol in order to be able to call these methods
on the sequence items.  Apart from this protocol, which will be exercised
later, the rest of the implementation is pretty mundane. After the struct
definition we see a `String extension
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/time_stamp.swift#L157-L161>`_:

```java
extension String {
	var date: Stamp { return Stamp(self) }
	// Avoid losing sanity. Hey, at least this is not java!
	var len: Int { return self.characters.count }
}
```

What we are defining here is our pseudo custom literal for strings to invoke
the ``Stamp`` initializer. On top of that I added the ``len`` extension because
I dislike typing unnecessary characters. Just after this extension we get the
one I mentioned above, an `extension on Arrays to overload the subscript
operator
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/time_stamp.swift#L163-L184>`_:

```java
extension Array where Element: TimeComponents {
	// Marking as optional because swift 2.1 doesn't allow throwing inside
	// subscripts yet: http://stackoverflow.com/a/33724709/172690 or does it?
	subscript(position: String) -> [Int]? {
		get {
			switch (position) {
				case "week": return self.map() { $0.week }
				case "year": return self.map() { $0.year }
				case "month": return self.map() { $0.month }
				case "day": return self.map() { $0.day }
				case "hour": return self.map() { $0.hour }
				case "minute": return self.map() { $0.minute }
				case "second": return self.map() { $0.second }
				case "microsecond": return self.map() { $0.microsecond }
				case "millisecond": return self.map() { $0.millisecond }
				case "nanosecond": return self.map() { $0.nanosecond }
				default: return nil
			}
		}
	}
}
```

In the `bonus generic subscript operator section of the Nim implementation
chapter <kerf-timestamps-done-almost-right-nim.html>`_ I implemented Kerf's
subscript operator using filter procs, which allowed us to pass any kind of
proc to be applied to sequences. Here I'm taking a different turn and
implementing a string based version `like I mentioned in the introduction
chapter <kerf-timestamps-done-almost-right-a-new-type.html>`_. This version
shows that using strings can be done, but it is not extensible, and in the case
of typos this extension returns Nil. This forces extra checks on the caller
code. The generic ``Array`` type was forced with ``where Element:
TimeComponents`` to a concrete protocol, so I could write the ``map()`` calls
using the proper calendar component getters. In Swift you can't coerce the
generic ``Array`` to a ``Stamp``, if you try you get the message ``error: type
'Element' constrained to non-protocol type 'Stamp'`` from the compiler (and
also a crash with stacktrace on version 2.1.1 of the compiler).

After `some lines dedicated to reimplement basic Nim parsing code
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/time_stamp.swift#L186-L216>`_
for the purpose of keeping it as close as possible to the original, we reach
`the final self test code of the file
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/time_stamp.swift#L219-L244>`_.
Nothing exceptional there, so let's take a look at the `main.swift file
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/main.swift>`_
which implements the Kerf syntax examples we want to copy:

```java
let a = "2012.01.01".date
print("Example 1: \(a)")
print("Example 2:")
print("\t\(a + 1.d)")
print("\t\("2012.01.01".date + 1.d)")

print("Example 3: \("2012.01.01".date + 1.m + 1.d + 1.h + 15.i + 17.s)")
```

Basic initialization and operator overloading works fine, this looks just like
the Nim code plus the weird string interpolation. Then, just like in the Nim version, we attempt `Kerf's 4th example using temporary variables <https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/main.swift#L12-L16>`_:

```java
let r = (0..<10)
let offsets = r.map() { (1.m + 1.d + 1.h + 15.i + 17.s) * $0 }
let values = offsets.map() { "2012.01.01".date + $0 }

print("Example 4: \(values)")
```

And it works. In Nim a template was used to map arbitrary expressions to the
input sequence. Here in Swift the ``map()`` functions accept as parameter
closures. If the closure is the last parameter in the function definition it
can be omitted from the actual call (between the parentheses) and placed within
braces after it. Inside this closure the implicit input parameter is
represented as ``$0`` which stands for the first parameter. The second Nim
version which was rolled in a single expression can't be used with string
interpolation, so `a temporary variable is used instead
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/main.swift#L18-L27>`_:

```java
let x = String((0..<10)
	.map() { (1.m + 1.d + 1.h + 15.i + 17.s) * $0 }
	.map() { "2012.01.01".date + $0 })
// Swift's compiler agrees that string interpolation is crap and bails out
// if you try to embed the previous expression, so we create a temporal.
print("…again but compressed… \(x)")

print("…again with explicit concatenation… " + String((0..<10)
	.map() { (1.m + 1.d + 1.h + 15.i + 17.s) * $0 }
	.map() { "2012.01.01".date + $0 }))
```

Alternatively, instead of string interpolation explicit concatenation can be
used, as the last expression shows. And at this point we would implement the
shorter operator overloaded version for arrays so we could match Kerf's syntax.
Unfortunately the *complex expression* bugs stopped me in all attempts to do
so, maybe in a future when Swift is more mature I'll try again. For the last
example using the subscript operator to access calendar components, I placed it
`near to the alternative strongly typed map version
<https://github.com/gradha/kerf_timestamps_done_almost_right/blob/master/swift/main.swift#L31-L35>`_:

```java
print("Example 5 b[week]: \(values.map() { $0.week })")
print("Example 5 b[second]: \(values.map() { $0.second })")
print("Example 5 b[second]: \(values["week"])")
print("Example 5 b[second]: \(values["runtime error"])")
```

As mentioned above, the subscript version may look cleaner, but it allows
potential typos, which is why it returns a nil. On the other hand if you use
the ``map()`` version and try to access the ``weak`` variable, you will get a
nice compiler error:

```none
main.swift:31:45: error: value of type 'Stamp' has no member 'weak'
        print("Example 5 b[week]: \(values.map() { $0.weak })")
                                                   ^~ ~~~~
```

For completeness, here is the successful output of this last example part, note
the optional sequence syntax in the output:

```none
Example 5 b[week]: [1, 5, 9, 14, 18, 23, 27, 32, 36, 40]
Example 5 b[second]: [0, 17, 34, 51, 8, 25, 42, 59, 16, 33]
Example 5 b[second]: Optional([1, 5, 9, 14, 18, 23, 27, 32, 36, 40])
Example 5 b[second]: nil

```

Conclusion
----------

Working with Swift is particularly unsatisfying, but I can't put my finger yet
on what exactly is causing me more grief. Is it is because the language design
feels unnecessarily complex? Is it because the compiler takes ages to do simple
things?  Is it because of bugs? What matters is that in Swift you can also
implement Kerf's timestamp types. Now we only have to wait for better compiler
implementations to *maybe enjoy* the language in the future.  In the meantime,
you might want to take a laugh at the `horrifying Java implementation I came up
with <kerf-timestamps-done-almost-right-wtf…-java.html>`_.

.. raw:: html

    <br clear="right"><center>
    <a href="http://mang2goon.tistory.com/466"><img
        src="../../../i/kerf_patient.jpg"
        alt="Patient Woohee is patiently waiting for the compiler to finish, or for a newer compiler that doesn't suck"
        style="width:100%;max-width:600px" align="center"
        hspace="8pt" vspace="8pt"></a>
    </center>

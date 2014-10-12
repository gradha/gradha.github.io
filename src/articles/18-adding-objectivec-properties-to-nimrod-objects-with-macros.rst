---
title: Adding Objective-C properties to Nimrod objects with macros
pubDate: 2014-10-12 01:08
modDate: 2014-10-12 01:08
tags: nimrod, programming, languages, objc
---

Adding Objective-C properties to Nimrod objects with macros
===========================================================

The `Nimrod programming language <http://nimrod-lang.org>`_ allows one to use
`macros <http://nimrod-lang.org/manual.html#macros>`_ to extend the language.
In a `previous article <../06/dirrty-objects-in-dirrty-nimrod.html>`_ we were
guided by `Christina Aguilera
<https://en.wikipedia.org/wiki/Christina_Aguilera>`_ into adding Objective-C
like object properties to the Nimrod programming language. However, the result,
while effective, looked quite spartan and low class, like `Christina's slutdrop
<https://en.wikipedia.org/wiki/File:Dirrty_Slutdrop.jpg>`_. Here is the code I
ended up with:

```nimrod
import utils

type
  Person = object of Dirrty
    Fname, Fsurname: string
    Fage: int

generateProperties(Person, name, string)
generateProperties(Person, surname, string)
generateProperties(Person, age, int)

proc test() =
  ## Exercise the setters and getters.
  var a: Person
  a.name = "Christina"
  echo "Is ", a.name, " dirrty? ", a.dirrty

when isMainModule: test()
```

This code has several issues on the long run:

1. The ``type`` definition is separate from the ``generateProperties`` calls.
   This means it is easy to *lose sync* between both.
2. There is much repeating of simple identifiers. Worse, because the type and
   the property generating macro is separate, the type definition has to use
   the *implied* ``F`` prefix for instance variables being used as properties,
   and the non-F version for the property (or vice versa, should you write your
   macro the other way round). It is easy to get distracted and mess up one or
   the other and later get shocked by the compiler.
3. Just like with the identifiers, the type for each field is repeated too.
   This is just nonsense. It is all you can do with C like macros though, so to
   the experienced C/C++ programmer it may not look *that horrible*.

With Nimrod you can do better. And better than the obviousness of Christina's
slutdrop, I find `Ace of Angels' <https://en.wikipedia.org/wiki/AOA_(band)>`_
`miniskirt unzipping and ass shaking
<http://www.youtube.com/watch?v=q6f-LLM1H6U>`_ more tasteful and pleasant to
the eye (after all, at the moment I'm writing this Christina loses with
9.986.070 views to the 11.394.880 views of Ace of Angels, yet AOA's video has
existed for far less time). Following the steps of these Queens Of Teasing,
here is a quick peek at how the code will end up after we drive ourselves crazy
with some serious macro writing:

```nimrod
import utils

makeDirtyWithStyle:
  type
    Person = object of Dirrty
      dirty, name*, surname*: string
      clean, age*: int
      internalValue: float

proc test() =
  var a: Person
  a.name = "Christina"
  echo "Is ", a.name, " dirrty? ", a.dirrty

when isMainModule: test()
```

The roadmap ahead
=================

We can see by the previous teaser that we got rid of the ``generateProperties``
macro completely. Yay! That code has been moved into the ``makeDirtyWithStyle``
macro. Instead of a call, what we are doing here is `invoking our macro as a
statement <http://nimrod-lang.org/tut2.html#statement-macros>`_. Everything
indented after the colon will be passed in to the macro as its last parameter.
How? As an `abstract syntax tree
<https://en.wikipedia.org/wiki/Abstract_syntax_tree>`_ or AST for short.

.. raw:: html

    <center><a href="http://knowyourmeme.com/memes/x-x-everywhere"><img
        src="../../../i/asts-asts-everywhere.jpg"
        alt="If you close your eyes hard you can sometimes see the ASTs"
        style="width:100%;max-width:600px"
        hspace="8pt" vspace="8pt"></a></center><br>

Our new version of the macro will still use the same `quasi-quoting
<http://nimrod-lang.org/macros.html#quote>`_ to generate the setter and getter
procs. However, before generating any code the macro will be able to traverse
the input AST and figure out itself what fields of the object are meant to be
used for the setter and getter. On top of that, it will automatically mangle
the fields to use the ``F`` prefix letter (similar to Objective-C prefixing
properties with an underscore in case you need to access them directly), and we
will simulate our own mini DSL through identifiers to fake language support to
specify which property setters need to mark the object's dirty flag as dirty or
not. You can see that in the example code through the words ``dirty`` and
``clean``.

The `Nimrod Tutorial <http://nimrod-lang.org/tut1.html>`_ has a `Building your
first macro <http://nimrod-lang.org/tut2.html#building-your-first-macro>`_
section. You are meant to have at least skimmed through that because I won't be
explaining all the basics, only the ones I'm interested in. Also, much of the
typical error handling code you find in macros won't be present for brevity.
What error handling code would be this? In the previous ``generateProperties``
version the user of this macro can pass only three very specific parameters,
but in the statement version you can now pass any random Nimrod code to our
macro, and it has to figure out how to treat it.  If the user makes any
mistakes in the construct, rather than simply quitting or aborting a helpful
error message should be provided. That makes the code a lot more verbose
checking for all possible inputs (and you are sort of becoming a Nimrod
compiler developer at the same time!).

Don't get scared now of the length of this blog post, it is all due to the
example code lines being repeated several times to make the text more
contextual. In any case I recommend you to either download the source code
(utils.nim and miniskirt.nim) or view them through GitHub, which I will use to
quickly point to the appropriate lines (see utils.nim and miniskirt.nim on
GitHub). The truth is that most of the macro is pretty simple, it has already
been explained and what is left as an exercise for the writer is to transform
words into code.

While the original and destination source code files help to get an idea of
what the user will end up writing, the compiler only cares about ASTs. Just
like the `Building your first macro
<http://nimrod-lang.org/tut2.html#building-your-first-macro>`_ tutorial
recommends, we can use the `dumpTree() macro
<http://nimrod-lang.org/macros.html#dumpTree>`_ to dump the input AST and see
what the compiler is processing. For convenience, here you have the result
``dumpTree`` along the final result of `treeRepr()
<http://nimrod-lang.org/macros.html#treeRepr>`_ called inside the macro to show
how the final AST will look **after** to the compiler. The input AST is on the
left, the final AST is on the right. Additional unicode numbered markers have
been placed to point out the interesting parts::

    type
      Person = object of Dirrty
        dirty ⓵, name* ⓶, surname* ⓶: string
        clean ⓵, age* ⓶: int
        internalValue ⓷: float
    ----
    StmtList                   StmtList
      TypeSection                TypeSection
        TypeDef                    TypeDef
          Ident !"Person"            Ident !"Person"
          Empty                      Empty
          ObjectTy                   ObjectTy
            Empty                      Empty
            OfInherit                  OfInherit
              Ident !"Dirrty"            Ident !"Dirrty"
            RecList                    RecList
              IdentDefs                  IdentDefs
                Ident !"dirty"             ⓵
                Postfix                    Postfix
                  Ident !"*"                 Ident !"*"
                  Ident !"name"              Ident !"Fname" ⓶
                Postfix                    Postfix
                  Ident !"*"                 Ident !"*"
                  Ident !"surname"           Ident !"Fsurname" ⓶
                Ident !"string"            Ident !"string"
                Empty                      Empty
              IdentDefs                  IdentDefs
                Ident !"clean"             ⓵
                Postfix                    Postfix
                  Ident !"*"                 Ident !"*"
                  Ident !"age"               Ident !"Fage" ⓶
                Ident !"int"               Ident !"int"
                Empty                      Empty
              IdentDefs                  IdentDefs ⓷
                Ident !"internalValue"     Ident !"internalValue"
                Ident !"float"             Ident !"float"
                Empty                      Empty

1. The ``dirty`` and ``clean`` identifiers are removed from the right AST. They
   are not used by the compiler, they are markers our macro uses to modify the
   behaviour of the proc generating code.
2. The fields marked as properties will be mangled in the final tree to contain
   the prefix ``F`` letter. Note how all the identifiers on each line get
   mangled, we have to control this too. And remember that the last identifier
   is the type which we should not touch!
3. In this example, any list of identifiers starting with the identifier
   ``dirty`` or ``clean``  will be mangled into a property. The
   ``internalValue`` is there precisely to test that we don't generate a
   property for it. As you can see it is identical to the left AST.

For the purpose of making our macro traversing code more resilient (and fun!)
this version of the example includes the ``*`` postfix operator, which is used
in Nimrod to *export* symbols out of the module's scope. Not required for the
small example to work, it is something very common our macro would find in the
real world. Our version will deal with it correctly when traversing the AST but
we won't be using it to change the visibility of the procs generated for each
property for brevity (it's quite easy to add but increases the verbosity of the
example, and its already quite long as it is).

What is missing in this AST is that the right version will be followed with a
lot of proc definitions which are generated to emulate the Objective-C like
properties. This would be the output from our previous ``generateProperties``
macro but is not particularly interesting in itself and only adds line noise so
it has not been included in this AST representation.


Row, row, row your AST…
=======================

Let's start then with the ``makeDirtyWithStyle`` macro:

```nimrod
macro makeDirtyWithStyle*(body: stmt): stmt {.immediate.} =
  var foundObjects = initTable[string, seq[procTuple]]()
  # Find and mangle
  for n in body.children:
    if n.kind != nnkTypeSection: continue
    for n in n.children:
      if n.kind != nnkTypeDef: continue
      let
        typeName = $n[0]
        typeNode = n[2]
      if typeNode.kind != nnkObjectTy: continue
      let mangledObject = n[2].rewriteObject
      n[2] = mangledObject.node
      # Store the found symbols for a second proc phase.
      if mangledObject.found.len > 0:
        foundObjects[typeName] = mangledObject.found

  result = body
  # Iterate through fields and generate property procs.
  for objectName, mangledSymbols in foundObjects.pairs:
    for dirty, name, typ in mangledSymbols.items:
      result.add(generateProperties(dirty,
        objectName, name, typ))
```
The macro has two clear parts: iterating through the AST looking for
``foundObjects``, and then looping over the found results to call the
``generateProperties`` helper. During the search we also modify the ``body`` to
remove some identifiers and prefix others with the letter ``F``. This is fine
with the compiler. If the macro doesn't find any object to mangle, the ``result
= body`` line will essentially pass the user input raw to the compiler, plus
the following loop won't do anything. The ``generateProperties`` is nearly
intact from the previous article, the only modification has been to add the
``dirty`` parameter. With this parameter we specify if we want the generated
setter to set the ``dirrty`` field to ``true``, which allows us to generate
setters which don't modify the ``dirrty`` state of the object.

Traversing the AST is quite easy, first we check that we are inside a
``nnkTypeSection``. Inside this node, we continue to go deeper until we find a
``nnkTypeDef`` node, which is what we wanted in first place. The user could be
defining types **other** than objects. For instance, they could be defining a
``tuple`` along their object. So we are only interested in ``nnkObjectTy``
nodes. Finally, we call the ``rewriteObject`` helper proc which returns the
mangled AST node plus a sequence of ``procTuple`` elements which contain what
fields need to be mangled. Maybe the object had none, so we check for the
length of the ``mangledObject.found`` list before doing anything. Still, we can
happily replace the AST node with the returned value (``n[2] =
mangledObject.node``) because it won't have changed at all.

So what does the ``rewriteObject`` helper do?

```nimrod
proc rewriteObject(parentNode: PNimrodNode): rewriteTuple =
  # Create a copy which we will modify and return.
  result.node = copyNimTree(parentNode)
  result.found = @[]

  # Ignore the object unless it inherits from Dirrty.
  let inheritanceNode = parentNode[1]
  if inheritanceNode.kind != nnkOfInherit:
    return
  inheritanceNode.expectMinLen(1)
  if $inheritanceNode[0] != "Dirrty":
    return

  # Get the list of records for the object.
  var recList = result.node[2]
  if recList.kind != nnkRecList:
    error "Was expecting a record list"
  for nodeIndex in 0 .. <recList.len:
    var idList = recList[nodeIndex]
    # Only mutate those which start with fake keywords.
    let firstRawName = $basename(idList[0])
    if firstRawName in ["clean", "dirty"]:
      var found: procTuple
      found.dirty = (firstRawName == "dirty")
      del(idList) # Removes the first identifier.
      found.typ = $idList[idlist.len - 2]
      # Get the identifiers.
      for identifier in idList.stripTypeIdentifier:
        found.name = identifier
        result.found.add(found)
      # Mangle the remaining identifiers
      idList.prefixIdentifiersWithF
```
The first line which calls `copyNimTree()
<http://nimrod-lang.org/macros.html#copyNimTree>`_ is not strictly needed, but
can be useful in case we would need to do multiple passes on the AST and have
to compare our working version with the original one. Then we make sure the
object type definition we are dealing with actually inherits from our custom
``Dirrty`` class. This means we won't get automatic properties on objects which
inherit from other classes. Alternatively, we could detect this case and
prevent the generated setter from attempting to modify the field ``dirrty``
which won't be present. I've decided to only add properties to dirrty objects
for clarity (otherwise it's just a matter of more ``ifs`` in the following
lines).

When we deal with the identifier record list what we do is detect if the first
identifier is ``clean`` or ``dirty``. These are our *fake* DSL keywords which
tell the macro that the remaining fields need to be mangled. If the found
keyword is ``dirty``, the generated setter will modify the ``dirrty`` field,
but otherwise the rest of the code is quite similar. In any case we remove the
first fake identifier, then we loop over the remaining identifiers modifying
our ``var found: procTuple`` with the name and adding a copy to the
``result.found`` sequence. For this loop the ``stripTypeIdentifier`` helper is
used which simply iterates through the list of identifiers (except the last
one, which is the type definition!) and returns them as strings:

```nimrod
proc stripTypeIdentifier(identDefsNode: PNimrodNode):
    seq[string] =
  # Returns the names minus the type from an identifier list.
  identDefsNode.expectMinLen(3)
  let last = identDefsNode.len - 1
  identDefsNode[last].expectKind(nnkEmpty)
  identDefsNode[last - 1].expectKind(nnkIdent)

  result = @[]
  for i in 0 .. <last - 1:
    let n = identDefsNode[i]
    result.add($n.basename)
```

Once the identifiers without mangling have been added to the list of found
fields we pass control to the ``prefixIdentifiersWithF`` helper proc to
actually mangle them with the ``F`` prefix:

```nimrod
proc prefixNode(n: PNimrodNode): PNimrodNode =
  # Returns the ident node with a prefix F.
  case n.kind
  of nnkIdent: result = ident("F" & $n)
  of nnkPostfix:
    result = n.copyNimTree
    result.basename = "F" & $n.basename
  else:
    error "Don't know how to prefix " & treeRepr(n)

proc prefixIdentifiersWithF(identDefsNode: PNimrodNode) =
  # Replace all nodes except last with F version.
  let last = identDefsNode.len - 1
  for i in 0 .. <last - 1:
    let n = identDefsNode[i]
    identDefsNode[i] = n.prefixNode
```

As you can see ``prefixIdentifiersWithF`` is pretty similar to
``stripTypeIdentifier``, but instead of adding the identifier to a result list
it calls the ``prefixNode`` helper which mangles the node identifier. Here you
can see us dealing with ``nnkPostfix`` nodes, which are fields marked with
``*``. Again, as mentioned above, we could detect which of the fields are
marked with ``*`` to propagate the appropriate symbol visibility to the
generated property procs.  This is left as an exercise to the reader (hint: add
a visibility field to ``procTuple`` which already contains other field info).

For completeness, the snippets of code shown so far use two types which haven't
been defined, ``rewriteTuple`` and ``procTuple``:

```nimrod
type
  procTuple =
    tuple[dirty: bool, name: string, typ: string]

  rewriteTuple =
    tuple[node: PNimrodNode, found: seq[procTuple]]
```

Nothing too fancy, they are just the internal structures used to group and
communicate results between the procs. And… that's all folks! To verify
everything is working as expected, here is an extended version of our original
property usage test case:

```nimrod
proc extraTest() =
  var a: Person
  echo "Doing now extra test"
  a.name = "Christina"
  echo "Is ", a.name, " dirrty? ", a.dirrty
  a.dirrty = false
  a.age = 18
  echo "Is ", a.name, " with ", $a.age, " years dirrty? ", a.dirrty
  a.internalValue = 3.14
  echo "And after changing the internal value? ", a.dirrty
  # --> Doing now extra test
  #     Is Christina dirrty? true
  #     Is Christina with 18 years dirrty? false
  #     And after changing the internal value? false
```

In this version of the test we repeat the original dirtying of the ``Person``
object through the generated ``name=`` setter, which modifies the ``dirrty``
field. Then, we reset the ``dirrty``  field and modify the age. The
modification of the ``age`` property uses also a setter, but since this one was
marked as ``clean`` the ``dirrty`` field won't change its value. Finally, we
modify the ``internalValue``. This value was not marked with our fake keywords,
so the macro won't be generating any setter or getter. How can we verify this?
We could modify our macro to dump the final AST after the generated procs are
added. We can also inspect our ``nimcache`` folder which `should contain the
generated C files
<http://build.nimrod-lang.org/docs/backends.html#nimcache-naming-logic>`_. In
my case this is part of the generated code for the ``extraTest`` proc:

```c
...
    nimln(22, "miniskirt.nim");
    nimln(22, "miniskirt.nim");
    LOC4 = 0;
    LOC4 = age_111032(&a);
    LOC5 = 0;
    LOC5 = nimIntToStr(LOC4);
    nimln(22, "miniskirt.nim");
    LOC6 = 0;
    LOC6 = nimBoolToStr(a.Sup.Dirrty);
    printf("%s%s%s%s%s%s\012",
        (((NimStringDesc*) &TMP230))->data,
        (LOC3)->data, (((NimStringDesc*) &TMP233))->data,
        (LOC5)->data, (((NimStringDesc*) &TMP234))->data,
        (LOC6)->data);
    nimln(23, "miniskirt.nim");
    a.Internalvalue = 3.1400000000000001e+00;
    nimln(24, "miniskirt.nim");
    nimln(24, "miniskirt.nim");
    LOC7 = 0;
    LOC7 = nimBoolToStr(a.Sup.Dirrty);
    printf("%s%s\012",
        (((NimStringDesc*) &TMP235))->data, (LOC7)->data);
    popFrame();
...
```

While there is much low level and debug keeping stuff, note how the
modification of the age invokes the ``LOC4 = age_111032(&a);`` function call
(our custom generated setter), while the modification of the ``internalValue``
doesn't do any call, simply assigns with ``a.Internalvalue =
3.1400000000000001e+00;``. That means we have successfully created a property
generation macro, with cool fake pseudo keywords, and it works exactly were we
want it to work! That's a great deal better than simple C preprocessor macros.


Looking under the rug
=====================

While we have accomplished what we wanted (cooler Objective-C property like
generation code in Nimrod), there are still some rough edges we can't deal
with, or annoying stuff which hopefully will be improved in future versions of
Nimrod. From our user perspective, to the left you can see the code we now can
write. To the right you can see what could be written if the language provided
native property support (which is impossible, or do you know of any language
providing built-in object dirty field setting?)::

    makeDirtyWithStyle:                  dirtyType:
      type                                 Person = object of Dirrty
        Person = object of Dirrty            dirtyProperties:
          dirty, name*, surname*: string         name*, surname*: string
          clean, age*: int                   cleanProperties:
          internalValue: float                   age*: int
                                             privateFields:
                                                 internalValue: float

If we had our way and our hypothetical language would implement this feature
directly, we could mark our objects directly with ``dirtyProperties``,
``cleanProperties`` and ``privateFields`` sections. These would be recognised
as keywords by IDEs and editors. We have to settle for fake identifiers. It's
not bad, but could be worse. What is more annoying is that we can't get rid of
the explicit ``type`` keyword. Why? Because the Nimrod compiler still has to
parse that code into **VALID AST** before it can pass it to our macro. And it
is the ``type`` keyword which tells the parser that what follows should be
treated as a ``TypeSection`` with ``TypeDef`` and other stuff instead of say, a
``proc`` definition. Here you can hear lisp programmers laughing at our puny
syntax limitations. Still, Nimrod achieves the power of true macros with little
limitations. Would it be possible for Nimrod (or just any other language) to
allow user code extend the compiler parser with custom DSL rules? I think that
would be neat. And madness. Madness is neat, I'm still patiently waiting for
macros which modify the AST of the caller to the shock and horror of anybody
reading my code…

Possibly the most frustrating issue with writing Nimrod macros now is the lack
of proper documentation. While there is that `introductory tutorial
<http://nimrod-lang.org/tut2.html#building-your-first-macro>`_, the `macros
module API <http://nimrod-lang.org/macros.html>`_ seems to have more sections
filled with ``To be written`` than actual text, and many of the actual
descriptions are rather useless to newcomers (don't tell me `newEmptyNode()
<http://nimrod-lang.org/macros.html#newEmptyNode>`_ creates an empty node, tell
me in what situations I would like that, or how do I use the result with other
procs!). It's not a surprise that one of the past enhancements to the
documentation generator was to add the ``See source`` link, it's nearly the
only crutch you have to figure out how to do stuff (and that's if you figure
out what each proc does).

One more annoying issue is the lack of helpful stack traces during AST error
handling, which can happen a lot when developing macros. When you are writing
normal code, you get runtime stack traces which show where the execution of the
program was and hopefully by going to the mentioned lines you can fix something
to keep going. I present you the most useless stack trace **from hell**::

    miniskirt.nim(3, 0) Info: instantiation from here
    ???(???, ???) Error: type expected

.. raw:: html

    <center><a href="http://www.idol-grapher.com/1239"><img
        src="../../../i/error-type-expected.jpg"
        alt="Error: type expected"
        style="width:100%;max-width:600px"
        hspace="8pt" vspace="8pt"></a></center><br>

That's it. Nothing more. It's actually pretty awesome, can't do better short of
pulling out a gun and shooting you right in the face. Let me tell you how to
reproduce this, just comment the ``objType`` assignment in the
``generateProperties`` static proc, like this:

```nimrod
  proc generateProperties(dirrty: bool, objType,
      varName, varType: string): PNimrodNode =
    # Create identifiers from the parameters.
    let
      #objType = !(objType)
      varType = !(varType)
      setter = !($varName & "=")
```
This error happens because the ``objType`` is a string literal, but instead of
a string literal the ``quasi-quoting`` macro needs a ``TNimrodIdent``, which is
obtained through the `!() operator
<http://nimrod-lang.org/macros.html#!,string>`_. That's why removing this
re-assignment breaks everything and you are left wondering with **where to
start looking for problems because there is no starting point at all**. And
unfortunately it can't be fixed easily. By the time the compiler goes through
the quasi-quoting it doesn't know better if what it is generating is right or
wrong, and by the time it reaches a further phase of the compiler, since it was
all generated code, there are no actual line numbers to keep track of what was
generated where.

How could this be improved? Maybe the ``macros`` module could grow an
``annotateNode`` helper which when used would annotate the specified node with
the current line/column where the ``annotateNode`` helper actually is in the
source file. Kind of like ``printf`` cavemen debugging. Or maybe instead of
trying to preserve stack traces which are typical of runtime environments the
compiler could actually dump the AST it is processing with a little arrow
pointing at the node that is giving problems? Honestly, if instead of this
error I had gotten the AST with an arrow pointing at the string literal I would
at least know where to start looking at, even if by the mere AST I still might
have trouble finding out why a string literal is not expected. But you would at
least have a starting point. The ASTs can get quite big, so it would help if
the compiler could dump the problematic AST to a temporary file for inspection
with an editor rather than scrolling through pages of output.

Talking about cavemen debugging, the only sources of information you have now
for development of macros are the ``dumpTree`` and ``treeRepr`` helpers. It
would be really nice if the `official Nimrod IDE Aporia
<https://github.com/nimrod-code/Aporia>`_ had a mode where you could open a bit
of code in a separate window and it would refresh the AST as you write,
pointing at problematic places, or maybe offering links to the documentation as
you write code. Or maybe a mode where you directly write the AST, and the IDE
generates the source code for you? Maybe this could work off with proper auto
completion. Right now the amount of different AST nodes is quite scary but many
of them don't interact with each other unless specific conditions are met.  Who
knows, it could be easier to follow than looking through the documentation. Or
maybe it would be useless anyway because programming in Java is all the rage.


Conclusion
==========

Even with the rough edges, expected in a programming language which hasn't yet
reached version 1.0 and is already running circles around established
programming languages, macros are a complete win for programming. They allow
you to become a compiler developer and extend the language just that little bit
in the direction you need to make your life easier. Only without the pain and
embarrassment of pull requests being reviewed and rejected. And let's face it,
figuring out how macros work and how to write them is in itself a fun exercise.

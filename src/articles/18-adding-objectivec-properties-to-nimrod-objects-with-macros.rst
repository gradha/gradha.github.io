---
title: Adding Objective-C properties to Nimrod objects with macros
pubDate: 2014-10-12 22:46
moddate: 2016-09-22 00:35
tags: nim, nimrod, programming, languages, objc
---

Adding Objective-C properties to Nim objects with macros
========================================================

The `Nim programming language <http://nim-lang.org>`_ allows one to use `macros
<http://nim-lang.org/docs/manual.html#macros>`_ to extend the language.  In a
`previous article <../06/dirrty-objects-in-dirrty-nimrod.html>`_ we were guided
by `Christina Aguilera <https://en.wikipedia.org/wiki/Christina_Aguilera>`_
into adding Objective-C like object properties to the Nim programming language.
However, the result, while effective, looked quite spartan and low class, like
`Christina's slutdrop
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

1. The ``type`` definition is separate from the ``generateProperties()`` calls.
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

With Nim you can do better. And better than the obviousness of Christina's
slutdrop, I find `Ace of Angels' <https://en.wikipedia.org/wiki/AOA_(band)>`_
`miniskirt unzipping and ass shaking
<https://www.youtube.com/watch?v=q6f-LLM1H6U>`_ more tasteful and pleasant to
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

We can see by the previous teaser that we got rid of the
``generateProperties()`` macro completely. Yay! That code has been moved into
the ``makeDirtyWithStyle()`` macro. Instead of a call, what we are doing here
is `invoking our macro as a statement
<http://nim-lang.org/docs/tut2.html#macros-statement-macros>`_. Everything
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
<http://nim-lang.org/docs/macros.html#quote>`_ to generate the setter and getter
procs. However, before generating any code the macro will be able to traverse
the input AST and figure out itself what fields of the object are meant to be
used for the setter and getter. On top of that, it will automatically mangle
the fields to use the ``F`` prefix letter (similar to Objective-C prefixing
properties with an underscore in case you need to access them directly), and we
will simulate our own mini DSL through identifiers to fake language support to
specify which property setters need to mark the object's dirty flag as dirty or
not. You can see that in the example code through the words ``dirty`` and
``clean``.

The `Nim Tutorial <http://nim-lang.org/docs/tut1.html>`_ has a `Building your
first macro
<http://nim-lang.org/docs/tut2.html#macros-building-your-first-macro>`_
section. You are meant to have at least skimmed through that because I won't be
explaining all the basics, only the ones I'm interested in. Also, much of the
typical error handling code you find in macros won't be present for brevity.
What error handling code would be this? In the previous ``generateProperties``
version the user of this macro can pass only three very specific parameters,
but in the statement version you can now pass any random Nim code to our macro,
and it has to figure out how to treat it.  If the user makes any mistakes in
the construct, rather than simply quitting or aborting a helpful error message
should be provided. That makes the code a lot more verbose checking for all
possible inputs (and you are sort of becoming a Nim compiler developer at the
same time!).

Don't get scared now of the length of this blog post, it is all due to the
example code lines being repeated several times to make the text more
contextual. In any case I recommend you to either download the source code
(`utils.nim <../../../code/18/utils.nim>`_ and `miniskirt.nim
<../../../code/18/miniskirt.nim>`_) or view them through GitHub, which I will
use to quickly point to the appropriate lines (see `utils.nim
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim>`_
and `miniskirt.nim
<https://github.com/gradha/gradha.github.io/blob/master/code/18/miniskirt.nim>`_
on GitHub). The truth is that most of the macro is pretty simple, it has
already been explained and what is left as an exercise for the writer is to
transform words into code.

While the original and destination source code files help to get an idea of
what the user will end up writing, the compiler only cares about ASTs. Just
like the `Building your first macro
<http://nim-lang.org/docs/tut2.html#macros-building-your-first-macro>`_
tutorial recommends, we can use the `dumpTree() macro
<http://nim-lang.org/docs/macros.html#dumpTree>`_ to dump the input AST and see
what the compiler is processing. For convenience, here you have the result
`dumpTree() <http://nim-lang.org/docs/macros.html#dumpTree>`_ along the final
result of `treeRepr() <http://nim-lang.org/docs/macros.html#treeRepr>`_ called
inside the macro to show how the final AST will look **after** to the compiler.
The input AST is on the left, the final AST is on the right. Additional unicode
numbered markers have been placed to point out the interesting parts::

    type
      Person = object of Dirrty
        dirty ①, name* ②, surname* ②: string
        clean ①, age* ②: int
        internalValue ③: float
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
                Ident !"dirty"             ①
                Postfix                    Postfix
                  Ident !"*"                 Ident !"*"
                  Ident !"name"              Ident !"Fname" ②
                Postfix                    Postfix
                  Ident !"*"                 Ident !"*"
                  Ident !"surname"           Ident !"Fsurname" ②
                Ident !"string"            Ident !"string"
                Empty                      Empty
              IdentDefs                  IdentDefs
                Ident !"clean"             ①
                Postfix                    Postfix
                  Ident !"*"                 Ident !"*"
                  Ident !"age"               Ident !"Fage" ②
                Ident !"int"               Ident !"int"
                Empty                      Empty
              IdentDefs                  IdentDefs ③
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
in Nim to *export* symbols out of the module's scope. Not required for the
small example to work, it is something very common our macro would find in the
real world. Our version will deal with it correctly when traversing the AST but
we won't be using it to change the visibility of the procs generated for each
property for brevity (it's quite easy to add but increases the verbosity of the
example, and its already quite long as it is).

What is missing in this AST is that the right version will be followed with a
lot of proc definitions which are generated to emulate the Objective-C like
properties. This would be the output from our previous ``generateProperties()``
macro but is not particularly interesting in itself and only adds line noise so
it has not been included in this AST representation.


Row, row, row your AST…
=======================

Let's start then with the `makeDirtyWithStyle()
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim#L118>`_
macro:

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
`generateProperties()
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim#L87>`_
helper. During the search we also modify the ``body`` to remove some
identifiers and prefix others with the letter ``F``. This is fine with the
compiler. If the macro doesn't find any object to mangle, the ``result = body``
line will essentially pass the user input raw to the compiler, plus the
following loop won't do anything. The `generateProperties()
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim#L87>`_
helper is nearly intact from the previous article, the only modification has
been to add the ``dirty`` parameter. With this parameter we specify if we want
the generated setter to set the ``dirrty`` field to ``true``, which allows us
to generate setters which don't modify the ``dirrty`` state of the object.

Traversing the AST is quite easy, first we check that we are inside a
``nnkTypeSection``. Inside this node, we continue to go deeper until we find a
``nnkTypeDef`` node, which is what we wanted in first place. The user could be
defining types **other** than objects. For instance, they could be defining a
``tuple`` along their object. So we are only interested in ``nnkObjectTy``
nodes. Finally, we call the `rewriteObject()
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim#L54>`_
helper proc which returns the mangled AST node plus a sequence of `procTuple
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim#L17>`_
elements which contain what fields need to be mangled. Maybe the object had
none, so we check for the length of the ``mangledObject.found`` list before
doing anything. Still, we can happily replace the AST node with the returned
value (``n[2] = mangledObject.node``) because it won't have changed at all.

So what does the `rewriteObject()
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim#L54>`_
helper do?

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
<http://nim-lang.org/docs/macros.html#copyNimTree>`_ is not strictly needed, but
can be useful in case we would need to do multiple passes on the AST and have
to compare our working version with the original one. Then we make sure the
object type definition we are dealing with actually inherits from our custom
`Dirrty
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim#L14>`_
object. This means we won't get automatic properties on objects which inherit
from other classes. Alternatively, we could detect this case and prevent the
generated setter from attempting to modify the field ``dirrty`` which won't be
present. I've decided to only add properties to dirrty objects for clarity
(otherwise it's just a matter of more ``ifs`` in the following lines).

When we deal with the identifier record list what we do is detect if the first
identifier is ``clean`` or ``dirty``. These are our *fake* DSL keywords which
tell the macro that the remaining fields need to be mangled. If the found
keyword is ``dirty``, the generated setter will modify the ``dirrty`` field,
but otherwise the rest of the code is quite similar. In any case we remove the
first fake identifier, then we loop over the remaining identifiers modifying
our ``var found: procTuple`` with the name and adding a copy to the
``result.found`` sequence. For this loop the `stripTypeIdentifier()
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim#L24>`_
helper is used which simply iterates through the list of identifiers (except
the last one, which is the type definition!) and returns them as strings:

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
fields we pass control to the `prefixIdentifiersWithF()
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim#L47>`_
helper proc to actually mangle them with the ``F`` prefix:

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

As you can see `prefixIdentifiersWithF()
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim#L47>`_
is pretty similar to `stripTypeIdentifier()
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim#L24>`_,
but instead of adding the identifier to a result list it calls the
`prefixNode()
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim#L37>`_
helper which mangles the node identifier. Here you can see us dealing with
``nnkPostfix`` nodes, which are fields marked with ``*``. Again, as mentioned
above, we could detect which of the fields are marked with ``*`` to propagate
the appropriate symbol visibility to the generated property procs.  This is
left as an exercise to the reader (hint: add a visibility field to
``procTuple`` which already contains other field info).

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
everything is working as expected, here is an `extended version of our original
property usage test case
<https://github.com/gradha/gradha.github.io/blob/master/code/18/miniskirt.nim#L15>`_:

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
object through the generated ``name=()`` setter, which modifies the ``dirrty``
field. Then, we reset the ``dirrty``  field and modify the age. The
modification of the ``age`` property uses also a setter, but since this one was
marked as ``clean`` the ``dirrty`` field won't change its value. Finally, we
modify the ``internalValue``. This value was not marked with our fake keywords,
so the macro won't be generating any setter or getter. How can we verify this?
We could modify our macro to dump the final AST after the generated procs are
added. We can also inspect our ``nimcache`` folder which `should contain the
generated C files
<http://nim-lang.org/docs/backends.html#interfacing-nimcache-naming-logic>`_.
In my case this is part of the generated code for the ``extraTest()`` proc:

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
generation code in Nim), there are still some rough edges we can't deal
with, or annoying stuff which hopefully will be improved in future versions of
Nim. From our user perspective, to the left you can see the code we now can
write. To the right you can see what could be written if the language provided
native property support (which is impossible, or do you know of any language
providing built-in object dirty field tracking?)::

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
the explicit ``type`` keyword. Why? Because the Nim compiler still has to
parse that code into **VALID AST** before it can pass it to our macro. And it
is the ``type`` keyword which tells the parser that what follows should be
treated as a ``TypeSection`` with ``TypeDef`` and other stuff instead of say, a
``proc`` definition. Here you can hear lisp programmers laughing at our puny
syntax limitations. Still, Nim achieves the power of true macros with little
limitations. Would it be possible for Nim (or just any other language) to
allow user code extend the compiler parser with custom DSL rules? I think that
would be neat. And madness. Madness is neat, I'm still patiently waiting for
macros which modify the AST of the caller to the shock and horror of anybody
reading my code…

Possibly the most frustrating issue with writing Nim macros now is the lack of
proper documentation. While there is that `introductory tutorial
<http://nim-lang.org/docs/tut2.html#macros-building-your-first-macro>`_, the
`macros module API <http://nim-lang.org/docs/macros.html>`_ seems to have more
sections filled with ``To be written`` than actual text, and many of the actual
descriptions are rather useless to newcomers (don't tell me `newEmptyNode()
<http://nim-lang.org/docs/macros.html#newEmptyNode>`_ creates an empty node,
tell me in what situations I would like that, or how do I use the result with
other procs!). It's not a surprise that one of the past enhancements to the
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
reproduce this, just comment the `objType assignment
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim#L91>`_
in the `generateProperties()
<https://github.com/gradha/gradha.github.io/blob/master/code/18/utils.nim#L87>`_
static proc, like this:

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
<http://nim-lang.org/docs/macros.html#!,string>`_. That's why removing this
re-assignment breaks everything and you are left wondering **where to start
looking for problems because there is no starting point at all**. And
unfortunately it can't be fixed easily. By the time the compiler goes through
the quasi-quoting it doesn't know better if what it is generating is right or
wrong, and by the time it reaches a further phase of the compiler, since it was
all generated code, there are no actual line numbers to keep track of what was
generated where.

How could this be improved? Maybe the `macros
<http://nim-lang.org/docs/macros.html>`_ module could grow an ``annotateNode``
helper which when used would annotate the specified node with the current
line/column where the ``annotateNode`` helper actually is in the source file.
Kind of like ``printf`` cavemen debugging. Or maybe instead of trying to
preserve stack traces which are typical of runtime environments the compiler
could actually dump the AST it is processing with a little arrow pointing at
the node that is giving problems? Honestly, if instead of this error I had
gotten the AST with an arrow pointing at the string literal I would at least
know where to start looking at, even if by the mere AST I still might have
trouble finding out why a string literal is not expected. But you would at
least have a starting point. The ASTs can get quite big, so it would help if
the compiler could dump the problematic AST to a temporary file for inspection
with an editor rather than scrolling through pages of terminal output.

Talking about cavemen debugging, the only sources of information you have now
for development of macros are the `dumpTree()
<http://nim-lang.org/docs/macros.html#dumpTree>`_ and `treeRepr()
<http://nim-lang.org/docs/macros.html#treeRepr>`_ helpers and repeated trips to
the command line to compile stuff. It would be really nice if the `official Nim
IDE Aporia <https://github.com/nimrod-code/Aporia>`_ had a mode where you could
open a bit of code in a separate window and it would refresh the AST as you
write, pointing at problematic places, or maybe offering links to the
documentation as you write code. Or maybe a mode where you directly write the
AST, and the IDE generates the source code for you? Maybe this could work off
with proper auto completion. Right now the amount of different AST nodes is
quite scary but many of them don't interact with each other unless specific
conditions are met.  Who knows, it could be easier to follow than looking
through the documentation. Or maybe it would be useless anyway because
programming in Java is all the rage.


Conclusion
==========

`Even <http://www.youtube.com/watch?v=-i_2DIGBmO4>`_
`with <http://www.youtube.com/watch?v=-uZj3EVuSiM>`_
`the <http://www.youtube.com/watch?v=1KMF2cDG-Aw>`_
`rough <http://www.youtube.com/watch?v=22vDm0JSc7E>`_
`edges, <http://www.youtube.com/watch?v=27Cs_W5EptU>`_
`expected <http://www.youtube.com/watch?v=2KYQH2a5u-Y>`_
`in <http://www.youtube.com/watch?v=2KtflWoHIeE>`_
`a <http://www.youtube.com/watch?v=2TxSSILNibY>`_
`programming <http://www.youtube.com/watch?v=2w-nmLcZUFA>`_
`language <http://www.youtube.com/watch?v=2x_4Odo8BzI>`_
`which <http://www.youtube.com/watch?v=39B3AeTD0lY>`_
`hasn't <http://www.youtube.com/watch?v=3Tw-90vdfnQ>`_
`yet <http://www.youtube.com/watch?v=43dbZq6bv1o>`_
`reached <http://www.youtube.com/watch?v=4ZBDWpneAgw>`_
`version <http://www.youtube.com/watch?v=4oL9XLCktOQ>`_
`1.0 <http://www.youtube.com/watch?v=58xk5L5pCMg>`_
`and <http://www.youtube.com/watch?v=5P7QGBIFAgo>`_
`is <http://www.youtube.com/watch?v=5XHEgyNZPQA>`_
`already <http://www.youtube.com/watch?v=6JhZhMYx780>`_
`running <http://www.youtube.com/watch?v=6_HHut7u29w>`_
`circles <http://www.youtube.com/watch?v=6hqSmVRXwTE>`_
`around <http://www.youtube.com/watch?v=85kgIuq3HY4>`_
`established <http://www.youtube.com/watch?v=8NFXElCZY4I>`_
`programming <http://www.youtube.com/watch?v=91FleKcgKbE>`_
`languages, <http://www.youtube.com/watch?v=9g2YPmzDfkI>`_
`macros <http://www.youtube.com/watch?v=A_MCEHd6now>`_
`are <http://www.youtube.com/watch?v=Ac7SN63L6po>`_
`a <http://www.youtube.com/watch?v=B99pOzAfFy4>`_
`complete <http://www.youtube.com/watch?v=BygwsVYUbO8>`_
`win <http://www.youtube.com/watch?v=CTAAn5vbVPs>`_
`for <http://www.youtube.com/watch?v=D0TkSCpBSc0>`_
`programming. <http://www.youtube.com/watch?v=DBNAWLlPxCY>`_
`They <http://www.youtube.com/watch?v=DO8SJ2uxV4s>`_
`allow <http://www.youtube.com/watch?v=Dgwth72XZCQ>`_
`you <http://www.youtube.com/watch?v=EDxOSsiaEYU>`_
`to <http://www.youtube.com/watch?v=FAeu3esj1nM>`_
`become <http://www.youtube.com/watch?v=FnxEUBZ-9WY>`_
`a <http://www.youtube.com/watch?v=G2r5KVosjIw>`_
`compiler <http://www.youtube.com/watch?v=GnJ1KMY_k_M>`_
`developer <http://www.youtube.com/watch?v=Gnsjy8lpIH8>`_
`and <http://www.youtube.com/watch?v=HIymqJtD3fw>`_
`extend <http://www.youtube.com/watch?v=Hpp4mXPihZg>`_
`the <http://www.youtube.com/watch?v=Htjh6Vyxkws>`_
`language <http://www.youtube.com/watch?v=Hxxoyc05hWQ>`_
`just <http://www.youtube.com/watch?v=IJDckhfF0Z4>`_
`that <http://www.youtube.com/watch?v=J9_rfRC49P0>`_
`little <http://www.youtube.com/watch?v=JfBzQQ12W5M>`_
`bit <http://www.youtube.com/watch?v=KCfyNlp7rmw>`_
`in <http://www.youtube.com/watch?v=KYwyzTFQ_W4>`_
`the <http://www.youtube.com/watch?v=Kf-naZmRJoI>`_
`direction <http://www.youtube.com/watch?v=KvfmywBHNaI>`_
`you <http://www.youtube.com/watch?v=L-I0o5bB0D0>`_
`need <http://www.youtube.com/watch?v=LRnblsA54ZI>`_
`to <http://www.youtube.com/watch?v=MQ2sOfXhr3I>`_
`make <http://www.youtube.com/watch?v=MX4JXqOCcTs>`_
`your <http://www.youtube.com/watch?v=MrTrlRLAH-s>`_
`life <http://www.youtube.com/watch?v=Mwf6jxUBU0Q>`_
`easier. <http://www.youtube.com/watch?v=NTEOMaXxc3w>`_
`Only <http://www.youtube.com/watch?v=NWD3C0ax-ZY>`_
`without <http://www.youtube.com/watch?v=NeAgohY9hqM>`_
`the <http://www.youtube.com/watch?v=tQZlwr1JQ1Q>`_
`pain <http://www.youtube.com/watch?v=tZYJXI93RCw>`_
`and <http://www.youtube.com/watch?v=thabOb8WX34>`_
`embarrassment <http://www.youtube.com/watch?v=uwhZgR2Wuew>`_
`of <http://www.youtube.com/watch?v=v7cpVcnrPu4>`_
`pull <http://www.youtube.com/watch?v=wyIC3Z0_9J8>`_
`requests <http://www.youtube.com/watch?v=x7cMdxp49XQ>`_
`being <http://www.youtube.com/watch?v=xpbs6SRQsTI>`_
`reviewed <http://www.youtube.com/watch?v=xqmjmR-vRP0>`_
`and <http://www.youtube.com/watch?v=xryLWlBfXa0>`_
`rejected. <http://www.youtube.com/watch?v=yku6QKz6Drc>`_
`And <http://www.youtube.com/watch?v=zWi9Vk77bkY>`_
`let's <http://www.youtube.com/watch?v=zp5CwgMSOMU>`_
`face <http://www.youtube.com/watch?v=O0srg6Lgzgg>`_
`it, <http://www.youtube.com/watch?v=OOejPz9kV6I>`_
`figuring <http://www.youtube.com/watch?v=PA-mnyNU8VE>`_
`out <http://www.youtube.com/watch?v=PMgZ5gia64U>`_
`how <http://www.youtube.com/watch?v=Pxb7KAbADf0>`_
`macros <http://www.youtube.com/watch?v=QUYILpXU1eQ>`_
`work <http://www.youtube.com/watch?v=QpAimvj3PFs>`_
`and <http://www.youtube.com/watch?v=QtRKy7uEYks>`_
`how <http://www.youtube.com/watch?v=Qwr_aRE-PRw>`_
`to <http://www.youtube.com/watch?v=R7pfg5E-JQ4>`_
`write <http://www.youtube.com/watch?v=RCybFtD9ROg>`_
`them <http://www.youtube.com/watch?v=Rie4knPIKPw>`_
`is <http://www.youtube.com/watch?v=RjwjFmfLfps>`_
`in <http://www.youtube.com/watch?v=SQq8lPtK65g>`_
`itself <http://www.youtube.com/watch?v=dQw4w9WgXcQ>`_
`a <http://www.youtube.com/watch?v=SnmUALfrJMw>`_
`fun <http://www.youtube.com/watch?v=TUrxPOF9kZs>`_
`exercise. <http://www.youtube.com/watch?v=UzkAGgBDHTM>`_

`I'd <http://www.youtube.com/watch?v=VDJRMjtzvlg>`_
`also <http://www.youtube.com/watch?v=V_lvh4HuOKA>`_
`like <http://www.youtube.com/watch?v=Vdd-z87h0Ek>`_
`to <http://www.youtube.com/watch?v=WHTqrECQZyw>`_
`thank <http://www.youtube.com/watch?v=WyN7uzv55Qs>`_
`the <http://www.youtube.com/watch?v=XSxbmpBMz0E>`_
`wonderful <http://www.youtube.com/watch?v=XfXZcXOCKNg>`_
`Ace <http://www.youtube.com/watch?v=Xl_2aOOpTmg>`_
`of <http://www.youtube.com/watch?v=Y4l0vyLEQ8g>`_
`Angels <http://www.youtube.com/watch?v=Y6JVsIiMLyU>`_
`for <http://www.youtube.com/watch?v=YLnZWkMUKRA>`_
`their <http://www.youtube.com/watch?v=YsxKBvJFtuU>`_
`performances <http://www.youtube.com/watch?v=YvnlMaYUe24>`_
`and <http://www.youtube.com/watch?v=ZiRcTCfAjdM>`_
`the <http://www.youtube.com/watch?v=ZpgTevBUStE>`_
`dozens <http://www.youtube.com/watch?v=_2oVTghzm5I>`_
`of <http://www.youtube.com/watch?v=_39a5TJC47E>`_
`Korean <http://www.youtube.com/watch?v=_9l_xrpg9J4>`_
`camera <http://www.youtube.com/watch?v=_HizAsI9KnM>`_
`men <http://www.youtube.com/watch?v=_R1W21n5f74>`_
`offering <http://www.youtube.com/watch?v=_sBtnpRE4r0>`_
`high <http://www.youtube.com/watch?v=_xSixaY-KKE>`_
`quality <http://www.youtube.com/watch?v=aJ0cBPTZugo>`_
`captures <http://www.youtube.com/watch?v=afgWZGd-3gg>`_
`of <http://www.youtube.com/watch?v=arx-pq-7Z1o>`_
`them. <http://www.youtube.com/watch?v=bQ3XlIQyPEI>`_
`They <http://www.youtube.com/watch?v=biCkA4q2_FE>`_
`were <http://www.youtube.com/watch?v=chkdylyKgJE>`_
`crucial <http://www.youtube.com/watch?v=dC2iOh831Jg>`_
`to <http://www.youtube.com/watch?v=dCDij8E7fwo>`_
`overcome <http://www.youtube.com/watch?v=dLTSeAiPK34>`_
`the <http://www.youtube.com/watch?v=d_SO284MFfs>`_
`hurdles <http://www.youtube.com/watch?v=eK3KJ7AlxNs>`_
`mentioned <http://www.youtube.com/watch?v=ePuj3g2giUY>`_
`above. <http://www.youtube.com/watch?v=f0uY0zFG0y8>`_
`At <http://www.youtube.com/watch?v=fLZG31_AKsQ>`_
`times <http://www.youtube.com/watch?v=fZ8ebCBb8z4>`_
`of <http://www.youtube.com/watch?v=haOvfeui2K0>`_
`difficulty, <http://www.youtube.com/watch?v=i0jDsG94m90>`_
`clearing <http://www.youtube.com/watch?v=iAertuXKvnc>`_
`your <http://www.youtube.com/watch?v=iG7sb6PlbeQ>`_
`mind <http://www.youtube.com/watch?v=k8K7SDf54LY>`_
`of <http://www.youtube.com/watch?v=lBbC5L2p5gM>`_
`thoughts <http://www.youtube.com/watch?v=l_eNMOFXcM8>`_
`by <http://www.youtube.com/watch?v=ljwkRDdhjVM>`_
`looking <http://www.youtube.com/watch?v=lrzPvetaDUY>`_
`at <http://www.youtube.com/watch?v=mCFIWB_gIBQ>`_
`something <http://www.youtube.com/watch?v=mG_UY_SCKqg>`_
`else <http://www.youtube.com/watch?v=mSinameBSN0>`_
`can <http://www.youtube.com/watch?v=n3cZIdMd5QM>`_
`help. <http://www.youtube.com/watch?v=nflUbvqSgMU>`_
`More <http://www.youtube.com/watch?v=nkHPrIJtAD8>`_
`so <http://www.youtube.com/watch?v=o2Rx2TeErho>`_
`if <http://www.youtube.com/watch?v=o4Wa7nwB29M>`_
`what <http://www.youtube.com/watch?v=oG48HRGe5LA>`_
`you <http://www.youtube.com/watch?v=ojvES51dOUY>`_
`are <http://www.youtube.com/watch?v=ooJiMFG-Uuo>`_
`looking <http://www.youtube.com/watch?v=otJ8jzIBtMM>`_
`at <http://www.youtube.com/watch?v=ozDnGDxh7ZA>`_
`inspires <http://www.youtube.com/watch?v=pW7NSL9STp4>`_
`you <http://www.youtube.com/watch?v=qeOycPTKbl0>`_
`to <http://www.youtube.com/watch?v=qgen0Hv4rBk>`_
`keep <http://www.youtube.com/watch?v=r-4_j1V6frE>`_
`working. <http://www.youtube.com/watch?v=r4jFOB0cu6s>`_
`Ace <http://www.youtube.com/watch?v=s1StWjh0oFo>`_
`of <http://www.youtube.com/watch?v=sQdoijEyc3g>`_
`Angels, <http://www.youtube.com/watch?v=sbG87-GbQWM>`_
`fighting! <http://www.youtube.com/watch?v=stBjpAXjRpY>`_


::
    $ nim c -r miniskirt
    miniskirt.nim(3, 0) Info: instantiation from here
    ???(???, ???) Error: 4k youtube video expected

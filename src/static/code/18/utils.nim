import macros, tables

## Special macros to generate dirrty object properties.
##
## For more information see
## http://gradha.github.io/articles/2014/06/dirrty-objects-in-dirrty-nimrod.html
## and its follow up at
## http://gradha.github.io/articles/2014/10/adding-objectivec-properties-to-nimrod-objects-with-macros.html.
##
## This code works with version 0.9.6 of Nimrod, future versions of the
## compiler won't work due to Nimrod->Nim symbol renames.

type
  Dirrty* = object of TObject
    dirrty*: bool

  procTuple =
    tuple[dirty: bool, name: string, typ: string]

  rewriteTuple =
    tuple[node: PNimrodNode, found: seq[procTuple]]

static:
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

  proc generateProperties(dirrty: bool, objType,
      varName, varType: string): PNimrodNode =
    # Create identifiers from the parameters.
    let
      objType = !(objType)
      varType = !(varType)
      setter = !($varName & "=")
      iVar = !("F" & $varName)
      getter = !($varName)

    # Generate the code using quasiquoting.
    result = quote do:
      proc `getter`(x: var `objType`):
          `varType` {.inline.} =
        x.`iVar`

    # Branch on being dirrty or not.
    if dirrty:
      result.add(quote do:
        proc `setter`*(x: var `objType`,
            value: `varType`) {.inline.} =
          x.`iVar` = value
          x.dirrty = true
        )
    else:
      result.add(quote do:
        proc `setter`*(x: var `objType`,
            value: `varType`) {.inline.} =
          x.`iVar` = value
        )

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

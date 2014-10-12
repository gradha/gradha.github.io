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

when isMainModule:
  test()
  extraTest()

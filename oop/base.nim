import typetraits

type A* = ref object of RootObj
  name:string

template new*(this:A) =
  echo this.type.name

proc getName*(this:A):string =
  this.name

# echo A(name:"Taro").getName()

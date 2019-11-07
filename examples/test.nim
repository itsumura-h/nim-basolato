type A = ref object
  name:string

var a = A(name:"taro")

proc changeName(a:A, name:string):A =
  var newA = a
  newA.name = name

var b = a.changeName("jiro")
echo b.name
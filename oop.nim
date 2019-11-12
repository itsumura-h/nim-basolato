type User* = ref object
  name:string

proc setName(this:User, name:string):User =
  this.name = name
  return this

proc getName(this:User):string =
  this.name

var taro = User().setName("taro")
echo taro.getName()
var jiro = taro.setName("jiro")
echo jiro.getName()
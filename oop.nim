type User* = ref object
  name:string

proc add1(s: var string) =
  s.add("1")

proc setName(this:var User, name:string) =
  this.name = name
  # return this

proc getName(this:User):string =
  this.name

var user = User()
user.setName("taro")
echo user.getName()
user.setName("jiro")
echo user.getName()

# var jiro = taro.setName("jiro")
# echo jiro.getName()



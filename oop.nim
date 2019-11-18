type User* = ref object
  name:string

proc setName(this:var User, name:string) =
  this.name = name

proc getName(this:User):string =
  this.name

var user = User()
user.setName("taro")
echo user.getName()
user.setName("jiro")
echo user.getName()

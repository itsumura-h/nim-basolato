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


type
  Parent = ref object of RootObj
    name:string

  Child = ref object of Parent

proc getName(this:Parent): string =
  echo this.name

let c =  Child(name:"child")
echo c.repr
echo c.getName()
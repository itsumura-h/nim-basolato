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


type Parent = ref object of RootObj
  name:string

proc new(this:typedesc, name:string):this.type =
  this.type(name:name)


type Child = ref object of Parent

proc newChild(name:string):Child =
  Child.new(name)

proc getName(this:Child): string =
  this.name

echo newChild("taro").getName()
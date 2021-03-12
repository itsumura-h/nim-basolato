type User* = ref object
  name:string

proc setName(self:var User, name:string) =
  self.name = name

proc getName(self:User):string =
  self.name

var user = User()
user.setName("taro")
echo user.getName()
user.setName("jiro")
echo user.getName()


type Parent = ref object of RootObj
  name:string

proc new(self:typedesc, name:string):self.type =
  self.type(name:name)


type Child = ref object of Parent

proc newChild(name:string):Child =
  Child.new(name)

proc getName(self:Child): string =
  self.name

echo newChild("taro").getName()
import interface_class

type Cat* = ref object
  name:string

proc newCat*():Cat =
  return Cat(name:"cat")

# 実装
proc walk*(this:Cat):string =
  return this.name & " walk"

# 実装のメソッドをインターフェースのメソッドに組み替える(DI？)
proc toInterface*(this:Cat):IAnimal =
  return (
    walk: proc():string = this.walk
  )

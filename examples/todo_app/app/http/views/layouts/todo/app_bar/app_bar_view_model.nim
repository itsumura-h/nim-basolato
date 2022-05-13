type AppBarViewModel* = ref object
  name:string

proc name*(self:AppBarViewModel):string = self.name

proc new*(_:type AppBarViewModel, name:string):AppBarViewModel =
  return AppBarViewModel(
    name:name
  )

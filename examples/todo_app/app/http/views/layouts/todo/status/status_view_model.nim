type StatusViewModel* = ref object
  id:int
  name:string

proc id*(self:StatusViewModel):int = self.id
proc name*(self:StatusViewModel):string = self.name

proc new*(_:type StatusViewModel, id:int, name:string):StatusViewModel =
  return StatusViewModel(
    id:id,
    name:name
  )

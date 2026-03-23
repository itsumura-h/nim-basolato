type Title* = object
  value*:string

proc new*(_:type Title, value:string):Title =
  return Title(value: value)

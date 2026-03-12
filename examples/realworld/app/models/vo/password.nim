type Password* = object
  value*:string

proc new*(_:type Password, value:string):Password =
  return Password(value: value)

type Description* = object
  value*:string

proc new*(_:type Description, value:string):Description =
  return Description(value:value)

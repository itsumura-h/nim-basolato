type Email* = object
  value*:string

proc new*(_:type Email, value:string):Email =
  return Email(value: value)

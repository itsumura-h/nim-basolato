type Image*  = object
  value*:string

proc new*(_:type Image, value:string):Image =
  return Image(value:value)

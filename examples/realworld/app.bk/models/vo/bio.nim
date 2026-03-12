type Bio*  = object
  value*:string

proc new*(_:type Bio, value:string):Bio =
  return Bio(value:value)

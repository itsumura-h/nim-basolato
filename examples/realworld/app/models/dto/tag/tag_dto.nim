type TagDto* = object
  id*:string
  name*:string

proc new*(_:type TagDto, id:string, name:string):TagDto =
  return TagDto(id: id, name: name)

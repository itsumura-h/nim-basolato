type TagDto* = object
  id*:string
  name*:string
  popularCount*:int

proc new*(_:type TagDto, id:string, name:string, popularCount:int):TagDto =
  return TagDto(
    id: id,
    name: name,
    popularCount: popularCount,
  )

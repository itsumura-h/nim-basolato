type PaginatorDto* = object
  current*:int
  display*:int
  total*:int

proc new*(_:type PaginatorDto, current:int, display:int, total:int):PaginatorDto =
  return PaginatorDto(
    current:current,
    display:display,
    total:total
  )

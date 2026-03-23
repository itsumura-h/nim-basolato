import ../../../../models/dto/tag/tag_dto


type Tag*  = object
  id*:string
  name*:string
  popularCount*:int

proc new*(_:type Tag, id:string, name:string, popularCount:int):Tag =
  return Tag(
    id:id,
    name:name,
    popularCount:popularCount
  )


type IslandTagListViewModel*  = object
  tags*:seq[Tag]

proc new*(_:type IslandTagListViewModel, tagDtoList:seq[TagDto]):IslandTagListViewModel =
  var tags:seq[Tag]
  for row in tagDtoList:
    let tag = Tag.new(
      id = row.id,
      name = row.name,
      popularCount = row.popularCount
    )
    tags.add(tag)

  return IslandTagListViewModel(
    tags:tags
  )

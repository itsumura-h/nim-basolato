import std/sequtils
import ../../../../models/dto/tag/tag_dto


type TagList* = object
  id*: string
  name*: string

type PopularTagsTemplateModel* = object
  tagList*:seq[TagList]


proc new*(_:type[PopularTagsTemplateModel], tagDtoList:seq[TagDto]):PopularTagsTemplateModel =
  let tagList = tagDtoList.map(
    proc(tagDto:TagDto):TagList =
      return TagList(id: tagDto.id, name: tagDto.name)
  )
  return PopularTagsTemplateModel(tagList: tagList)

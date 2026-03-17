import std/asyncdispatch
import std/sequtils
import basolato/view
import ../../../../di_container
import ../../../../models/dto/tag/tag_dao_interface
import ../../../../models/dto/tag/tag_dto


type TagList* = object
  id*: string
  name*: string

type PopularTagsTemplateModel* = object
  tagList*: seq[TagList]


proc new*(_: type PopularTagsTemplateModel, tagDtoList: seq[TagDto]): PopularTagsTemplateModel =
  let tagList = tagDtoList.map(
    proc(tagDto: TagDto): TagList =
      TagList(id: tagDto.id, name: tagDto.name)
  )
  return PopularTagsTemplateModel(tagList: tagList)


proc new*(_: type PopularTagsTemplateModel, context: Context): Future[PopularTagsTemplateModel] {.async.} =
  let tagDtoList = di.tagDao.getPopularTagList().await
  return PopularTagsTemplateModel.new(tagDtoList)

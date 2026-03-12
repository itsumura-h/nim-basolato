import std/asyncdispatch
import ../../models/dto/tag/tag_dao_interface
import ../../models/dto/tag/tag_dto
import ../../http/views/templates/popular_tags/popular_tags_template_model
import ../../di_container

type PopularTagListPresenter* = object
  dao:ITagDao

proc new*(_:type PopularTagListPresenter):PopularTagListPresenter =
  return PopularTagListPresenter(
    dao:di.tagDao
  )


proc invoke*(self:PopularTagListPresenter):Future[PopularTagsTemplateModel] {.async.} =
  let tagDtoList = self.dao.getPopularTagList().await
  let model = PopularTagsTemplateModel.new(tagDtoList)
  return model

import std/asyncdispatch
import ../../models/dto/tag/tag_list_query_interface
import ../../http/views/islands/island_tag_list/island_tag_list_view_model
import ../../di_container


type PopularTagListPresenter* = object
  tagListQuery: ITagListQuery

proc new*(_:type PopularTagListPresenter):PopularTagListPresenter =
  return PopularTagListPresenter(
    tagListQuery: di.tagListQuery
  )


proc invoke*(self:PopularTagListPresenter):Future[IslandTagListViewModel] {.async.} =
  const tagCount = 10
  let tagDtoList = self.tagListQuery.invoke(tagCount).await
  let viewModel = IslandTagListViewModel.new(tagDtoList)
  return viewModel

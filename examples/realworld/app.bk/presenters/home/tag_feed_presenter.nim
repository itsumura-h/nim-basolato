import ../../http/views/pages/home/home_view_model


type TagFeedPresenter* = object

proc new*(_:type TagFeedPresenter):TagFeedPresenter =
  return TagFeedPresenter()


proc invoke*(self:TagFeedPresenter, tagName:string, hasPage:bool, page:int):HomeViewModel =
  let viewModel = HomeViewModel.new(
    "tag",
    tagName,
    hasPage,
    page
  )
  return viewModel

import ../../http/views/pages/home/home_view_model


type YourFeedPresenter* = object

proc new*(_:type YourFeedPresenter):YourFeedPresenter =
  return YourFeedPresenter()


proc invoke*(self:YourFeedPresenter, hasPage:bool, page:int):HomeViewModel =
  let viewModel = HomeViewModel.new(
    "personal",
    "",
    hasPage,
    page
  )
  return viewModel

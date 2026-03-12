import ../../http/views/pages/home/home_view_model


type GlobalFeedPresenter* = object

proc new*(_:type GlobalFeedPresenter):GlobalFeedPresenter =
  return GlobalFeedPresenter()


proc invoke*(self:GlobalFeedPresenter):HomeViewModel =
  return HomeViewModel.new()

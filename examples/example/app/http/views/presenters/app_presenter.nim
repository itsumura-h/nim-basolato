import ../layouts/app/app_layout_model
import ../layouts/head/head_layout_model


type AppPresenter* = object

proc new*(_:type AppPresenter):AppPresenter =
  return AppPresenter()


proc invoke*(self:AppPresenter, title:string):AppLayoutModel =
  let headLayoutModel = HeadLayoutModel.new(title)
  let appLayoutModel = AppLayoutModel.new(headLayoutModel)
  return appLayoutModel

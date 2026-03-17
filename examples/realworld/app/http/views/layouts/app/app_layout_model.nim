import std/asyncdispatch
import basolato/view
import ../head/head_layout_model
import ../navbar/navbar_layout_model

type AppLayoutModel* = object
  headLayoutModel*: HeadLayoutModel
  navbarLayoutModel*: NavbarLayoutModel

proc new*(_: type AppLayoutModel, headLayoutModel: HeadLayoutModel, navbarLayoutModel: NavbarLayoutModel): AppLayoutModel =
  AppLayoutModel(headLayoutModel: headLayoutModel, navbarLayoutModel: navbarLayoutModel)

proc new*(_: type AppLayoutModel, context: Context, title: string): Future[AppLayoutModel] {.async.} =
  let headLayoutModel = HeadLayoutModel.new(title)
  let navbarLayoutModel = await NavbarLayoutModel.new(context)
  return AppLayoutModel.new(headLayoutModel, navbarLayoutModel)

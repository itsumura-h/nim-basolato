import std/asyncdispatch
import basolato/view
import ../head/head_layout_model
import ../navbar/navbar_layout_model

type AppLayoutModel* = object
  headLayoutModel*: HeadLayoutModel
  navbarLayoutModel*: NavbarLayoutModel
  body*: Component


proc new*(_: type AppLayoutModel, context: Context, title: string, body: Component): Future[AppLayoutModel] {.async.} =
  let headLayoutModel = HeadLayoutModel.new(title)
  let navbarLayoutModel = await NavbarLayoutModel.new(context)
  return AppLayoutModel(
    headLayoutModel: headLayoutModel,
    navbarLayoutModel: navbarLayoutModel,
    body: body
  )

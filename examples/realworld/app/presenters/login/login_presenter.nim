import std/asyncdispatch
import ../../http/views/pages/login/login_page_model


type LoginPresenter* = object


proc new*(_:type LoginPresenter):LoginPresenter =
  return LoginPresenter()


proc invoke*(self:LoginPresenter):Future[LoginPageModel] {.async.} =
  let errorMessages:seq[string] = @[]
  return LoginPageModel(errorMessages:errorMessages)

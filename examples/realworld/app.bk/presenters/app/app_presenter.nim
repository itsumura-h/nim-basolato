import std/asyncdispatch
import std/options
import ../../http/views/layouts/app/app_view_model
import ../../http/views/layouts/navbar/navbar_view_model
import ../../models/dto/user/user_query_interface
import ../../models/vo/user_id
import ../../di_container


type AppPresenter* = object
  userQuery:IUserQuery

proc new*(_:type AppPresenter):AppPresenter =
  return AppPresenter(
    userQuery: di.userQuery
  )


proc invoke*(self:AppPresenter, isLogin:bool, loginUserId:Option[string], title:string):Future[AppViewModel] {.async.} =
  if isLoginUserId.isSome():
    let userId = UserId.new(loginUserId.get())
    let userDto = self.userQuery.invoke(userId).await
    let navbarViewModel = NavbarViewModel.new(true, userDto.id, userDto.name, userDto.image)
    let appViewModel = AppViewModel.new(title, navbarViewModel)
    return appViewModel
  else:
    let navbarViewModel = NavbarViewModel.new(false, "", "", "")
    let appViewModel = AppViewModel.new(title, navbarViewModel)
    return appViewModel

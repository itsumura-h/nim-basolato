import std/asyncdispatch
import ../../http/views/pages/setting/setting_view_model
import ../../models/dto/user/user_query_interface
import ../../models/vo/user_id
import ../../di_container


type SettingWithSuccessMessagePresenter* = object
  userQuery: IUserQuery

proc new*(_:type SettingWithSuccessMessagePresenter):SettingWithSuccessMessagePresenter =
  return SettingWithSuccessMessagePresenter(
    userQuery: di.userQuery
  )


proc invoke*(self:SettingWithSuccessMessagePresenter, userId:string):Future[SettingViewModel] {.async.} =
  let userId = UserId.new(userId)
  let userDto = self.userQuery.invoke(userId).await
  let viewModel = SettingViewModel.new(userDto, "Successfully updated")
  return viewModel

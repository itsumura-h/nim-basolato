import std/asyncdispatch
import std/options
import ../../http/views/pages/user/user_show_view_model
import ../../http/views/islands/follow_button/follow_button_view_model
import ../../models/dto/user/user_query_interface
import ../../models/dto/follow_button/follow_button_query_interface
import ../../models/vo/user_id
import ../../di_container


type UserShowPresenter* = object
  userQuery:IUserQuery
  followButtonQuery:IFollowButtonQuery

proc new*(_:type UserShowPresenter):UserShowPresenter =
  return UserShowPresenter(
    userQuery: di.userQuery,
    followButtonQuery: di.followButtonQuery
  )


proc invoke*(self:UserShowPresenter, userId:string, loginUserId:Option[string], page:int):Future[UserShowViewModel] {.async.} =
  let userId = UserId.new(userId)
  let loginUserId =
    if loginUserId.isSome():
      UserId.new(loginUserId.get()).some()
    else:
      none(UserId)

  let userDto = self.userQuery.invoke(userId).await

  let followButtonDto = self.followButtonQuery.invoke(userId, loginUserId).await

  const loadFavorites = false
  let isSelf =
    if loginUserId.isSome() and userId.value == loginUserId.get().value:
      true
    else:
      false

  let hasPage = page > 1

  let viewModel = UserShowViewModel.new(userDto, followButtonDto, isSelf, loadFavorites, hasPage, page)
  return viewModel

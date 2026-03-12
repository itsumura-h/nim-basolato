import std/asyncdispatch
import std/options
import ../../models/dto/follow_button/follow_button_query_interface
import ../../models/vo/user_id
import ../../http/views/islands/follow_button/follow_button_view_model
import ../../di_container


type FollowButtonInUserPresenter* = object
  followButtonQuery:IFollowButtonQuery

proc new*(_:type FollowButtonInUserPresenter):FollowButtonInUserPresenter =
  return FollowButtonInUserPresenter(
    followButtonQuery: di.followButtonQuery
  )


proc invoke*(self:FollowButtonInUserPresenter, userId:string, loginUserId:string):Future[FollowButtonViewModel] {.async.} =
  let userId = UserId.new(userId)
  let loginUserId = UserId.new(loginUserId).some()
  let followButtonInUserDto = self.followButtonQuery.invoke(userId, loginUserId).await
  let viewModel = FollowButtonViewModel.new(followButtonInUserDto)
  return viewModel

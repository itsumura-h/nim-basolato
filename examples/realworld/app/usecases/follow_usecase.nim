import std/asyncdispatch
import ../di_container
import ../models/aggregates/follow/follow_entity
import ../models/aggregates/follow/follow_repository_interface
import ../models/vo/user_id

type FollowUsecase* = object
  repository: IFollowRepository

proc new*(_:type FollowUsecase):FollowUsecase =
  return FollowUsecase(
    repository: di.followRepository,
  )


proc invoke*(self:FollowUsecase, loginUserId:string, userId:string):Future[void] {.async.} =
  let follow = Follow.new(UserId.new(userId), UserId.new(loginUserId))
  if self.repository.isExists(follow).await:
    await self.repository.delete(follow)
  else:
    await self.repository.create(follow)

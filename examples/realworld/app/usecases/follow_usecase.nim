import std/asyncdispatch

type FollowUsecase* = object

proc new*(_:type FollowUsecase):FollowUsecase =
  return FollowUsecase()


proc invoke*(self:FollowUsecase, loginUserId:string, userId:string):Future[void] {.async.} =
  discard

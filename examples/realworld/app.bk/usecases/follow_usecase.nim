import std/asyncdispatch
import ../di_container
import ../models/vo/user_id
import ../models/aggregates/follow_relationship/user_entity
import ../models/aggregates/follow_relationship/follow_relationship_entity
import ../models/aggregates/follow_relationship/follow_relationship_repository_interface
import ../models/aggregates/follow_relationship/follow_relationship_service

type FollowUsecase* = object
  repository:IFollowRelationshipRepository
  service: FollowRelationshipService

proc new*(_:type FollowUsecase):FollowUsecase =
  return FollowUsecase(
    repository: di.followRelationshipRepository,
    service: FollowRelationshipService.new(di.followRelationshipRepository)
  )


proc invoke*(self:FollowUsecase, userId, followerId:string) {.async.} =
  let userId = UserId.new(userId)
  let user = User.new(userId)
  let followerId = UserId.new(followerId)
  let follower = User.new(followerId)
  let relationship = FollowRelationship.new(user, follower)
  if self.service.isFollow(relationship).await:
    self.repository.delete(relationship).await
  else:
    self.repository.create(relationship).await

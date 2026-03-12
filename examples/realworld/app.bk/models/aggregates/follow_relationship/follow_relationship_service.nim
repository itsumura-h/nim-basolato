import std/asyncdispatch
import ./follow_relationship_repository_interface
import ./follow_relationship_entity

type FollowRelationshipService* = object
  repository: IFollowRelationshipRepository


proc new*(_:type FollowRelationshipService, repository:IFollowRelationshipRepository): FollowRelationshipService =
  return FollowRelationshipService(
    repository: repository
  )

proc isFollow*(self:FollowRelationshipService, relationship:FollowRelationship):Future[bool] {.async.} =
  return self.repository.isExists(relationship).await

import std/asyncdispatch
import ../../../models/aggregates/follow_relationship/follow_relationship_repository_interface
import ../../../models/aggregates/follow_relationship/follow_relationship_entity


type MockFollowRelationshipRepository* = object of IFollowRelationshipRepository

proc new*(_:type MockFollowRelationshipRepository):MockFollowRelationshipRepository =
  return MockFollowRelationshipRepository()


method create*(self:MockFollowRelationshipRepository, relationship:FollowRelationship) {.async.} =
  discard

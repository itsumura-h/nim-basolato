import std/asyncdispatch
import interface_implements
import ./follow_relationship_entity


interfaceDefs:
  type IFollowRelationshipRepository* = object of Rootobj
    isExists:proc(self:IFollowRelationshipRepository, relationship:FollowRelationship):Future[bool]
    create:proc(self:IFollowRelationshipRepository, relationship:FollowRelationship):Future[void]
    delete:proc(self:IFollowRelationshipRepository, relationship:FollowRelationship):Future[void]

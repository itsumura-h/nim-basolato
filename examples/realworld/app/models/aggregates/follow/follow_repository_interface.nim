import std/asyncdispatch
import interface_implements
import ./follow_entity

interfaceDefs:
  type IFollowRepository* = object of RootObj
    isExists: proc(self: IFollowRepository, follow: Follow): Future[bool]
    create: proc(self: IFollowRepository, follow: Follow): Future[void]
    delete: proc(self: IFollowRepository, follow: Follow): Future[void]

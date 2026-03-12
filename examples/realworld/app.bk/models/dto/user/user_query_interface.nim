import std/asyncdispatch
import interface_implements
import ../../vo/user_id
import ./user_dto

interfaceDefs:
  type IUserQuery* = object of RootObj
    invoke: proc(self: IUserQuery, userId: UserId): Future[UserDto]

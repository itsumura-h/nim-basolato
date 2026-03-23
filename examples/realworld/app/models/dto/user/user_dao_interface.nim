import std/asyncdispatch
import std/options
import interface_implements
import ./user_dto

interfaceDefs:
  type IUserDao* = object of RootObj
    getUserById: proc(self: IUserDao, userId: string, loginUserId: Option[string] = none(string)): Future[UserDto]

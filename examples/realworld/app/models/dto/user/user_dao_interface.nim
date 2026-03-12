import std/asyncdispatch
import interface_implements
import ./user_dto

interfaceDefs:
  type IUserDao* = object of RootObj
    getUserById: proc(self: IUserDao, userId: string): Future[UserDto]

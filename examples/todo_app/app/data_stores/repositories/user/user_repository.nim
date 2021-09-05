import asyncdispatch, json, options
import interface_implements
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../models/user/user_value_objects
import ../../../models/user/user_entity
import ../../../models/user/user_repository_interface


type UserRepository* = ref object

func new*(typ:type UserRepository):UserRepository =
  typ()

implements UserRepository, IUserRepository:
  proc getUserByEmail(self:UserRepository, email:Email):Future[User] {.async.} =
    let userOpt = await rdb.table("users").where("email", "=", $email).first()
    if not userOpt.isSome():
      raise newException(Exception, "user is not found")
    let user = userOpt.get
    let id = UserId.new(user["id"].getInt)
    let name = UserName.new(user["name"].getStr)
    let email = Email.new(user["email"].getStr)
    let password = Password.new(user["password"].getStr)
    return User.new(
      UserId.new(user["id"].getInt),
      UserName.new(user["name"].getStr),
      Email.new(user["email"].getStr),
      Password.new(user["password"].getStr)
    )

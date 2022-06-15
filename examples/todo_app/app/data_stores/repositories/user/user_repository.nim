import asyncdispatch, json, options
import interface_implements
import ../../../../../../src/basolato/password
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../models/user/user_value_objects
import ../../../models/user/user_entity
import ../../../models/user/user_repository_interface


type UserRepository* = ref object

func new*(typ:type UserRepository):UserRepository =
  UserRepository()

implements UserRepository, IUserRepository:
  proc getUserByEmail(self:UserRepository, email:Email):Future[Option[User]] {.async.} =
    let userOpt = await rdb.table("users").where("email", "=", $email).first()
    if not userOpt.isSome():
      return none(User)
    let user = userOpt.get
    return User.new(
      UserId.new(user["id"].getStr),
      UserName.new(user["name"].getStr),
      Email.new(user["email"].getStr),
      Password.new(user["password"].getStr),
      Auth.new(user["auth_id"].getInt)
    ).some

  proc getUserById(self:UserRepository, id:UserId):Future[Option[User]] {.async.} =
    let userOpt = await rdb.table("users").find($id)
    if not userOpt.isSome():
      return User.none
    let user = userOpt.get
    return User.new(
      UserId.new(user["id"].getStr),
      UserName.new(user["name"].getStr),
      Email.new(user["email"].getStr),
      Password.new(user["password"].getStr),
      Auth.new(user["auht_id"].getInt)
    ).some

  proc save(self:UserRepository, user:DraftUser):Future[int] {.async.} =
    return rdb.table("users").insertId(%*{
      "name": $user.name,
      "email": $user.email,
      "password": genHashedPassword($user.password)
    }).await

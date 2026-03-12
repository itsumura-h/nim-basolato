import std/asyncdispatch
import std/options
import std/json
import std/times
import allographer/query_builder
from ../../../../config/database import rdb
import ../../../../database/schema
import ../../../models/vo/user_id
import ../../../models/vo/user_name
import ../../../models/vo/email
import ../../../models/vo/password
import ../../../models/vo/hashed_password
import ../../../models/vo/bio
import ../../../models/vo/image
import ../../../models/aggregates/user/user_entity
import ../../../models/aggregates/user/user_repository_interface


type UserDb* = object
  id*:UserTable.id
  name*:UserTable.name
  email*:UserTable.email
  password*:UserTable.password
  bio*:UserTable.bio
  image*:UserTable.image


type UserRepository*  = object of IUserRepository

proc new*(_:type UserRepository):UserRepository =
  return UserRepository()


method getUserByEmail(self:UserRepository, email:Email):Future[Option[User]] {.async.} =
  let rowOpt =
    rdb.table("user")
    .where("email", "=", email.value)
    .first()
    .orm(UserDb)
    .await

  if not rowOpt.isSome():
    return none(User)

  let row = rowOpt.get()
  let user = User.new(
    UserId.new(row.id),
    UserName.new(row.name),
    Email.new(row.email),
    HashedPassword.new(row.password),
    Bio.new(row.bio),
    Image.new(row.image),
  )
  return user.some()


method getUserById*(self:UserRepository, userId:UserId):Future[Option[User]] {.async.} =
  let rowOpt =
    rdb.table("user")
    .where("id", "=", userId.value)
    .first()
    .orm(UserDb)
    .await
  
  if not rowOpt.isSome():
    return none(User)

  let row = rowOpt.get()
  let user = User.new(
    UserId.new(row.id),
    UserName.new(row.name),
    Email.new(row.email),
    HashedPassword.new(row.password),
    Bio.new(row.bio),
    Image.new(row.image),
  )
  return user.some()


method create*(self:UserRepository, user:DraftUser) {.async.} =
  rdb.table("user").insert(%*{
    "id":user.id.value,
    "name":user.name.value,
    "email":user.email.value,
    "password":user.password.value,
    "created_at": user.createdAt.format("yyyy-MM-dd hh:mm:ss"),
  }).await


method update*(self:UserRepository, user:User) {.async.} =
  let val = %*{
    "name": user.name.value,
    "email": user.email.value,
    "bio": user.bio.value,
    "image": user.image.value,
  }
  if user.password.value != "":
    val["password"] = %user.password.value

  rdb.table("user")
  .where("id", "=", user.id.value)
  .update(val)
  .await

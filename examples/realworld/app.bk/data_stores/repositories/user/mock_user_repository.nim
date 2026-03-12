import std/asyncdispatch
import std/options
import std/json
import std/times
import allographer/query_builder
from ../../../../config/database import testRdb
import ../../../models/vo/user_id
import ../../../models/vo/user_name
import ../../../models/vo/email
import ../../../models/vo/password
import ../../../models/vo/hashed_password
import ../../../models/vo/bio
import ../../../models/vo/image
import ../../../models/aggregates/user/user_entity
import ../../../models/aggregates/user/user_repository_interface

let rdb = testRdb

type MockUserRepository*  = object of IUserRepository

proc new*(_:type MockUserRepository):MockUserRepository =
  return MockUserRepository()


method getUserByEmail*(self:MockUserRepository, email:Email):Future[Option[User]] {.async.} =
  let rowOpt = rdb.table("user")
                  .where("email", "=", email.value())
                  .first()
                  .await

  if not rowOpt.isSome():
    return none(User)

  let row = rowOpt.get()
  let user = User.new(
    UserId.new(row["id"].getStr),
    UserName.new(row["name"].getStr),
    Email.new(row["email"].getStr),
    HashedPassword.new(row["password"].getStr),
    Bio.new(row["bio"].getStr),
    Image.new(row["image"].getStr),
  )
  return user.some()


method create*(self:MockUserRepository, user:DraftUser):Future[UserId] {.async.} =
  rdb.table("user").insert(%*{
    "id":user.id.value,
    "name":user.name.value,
    "email":user.email.value,
    "password":user.password.hashed(),
    "created_at": now().utc().format("yyyy-MM-dd hh:mm:ss"),
  }).await
  return user.id

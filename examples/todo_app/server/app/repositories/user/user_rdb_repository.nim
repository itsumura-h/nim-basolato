import json, options
import allographer/query_builder
import ../../core/models/user/user_repository_interface
import ../../core/models/user/user_entity
import ../../core/models/user/value_objects


type UserRdbRepository* = ref object

proc newUserRdbRepository*():UserRdbRepository =
  return UserRdbRepository()


proc storeUser*(
    self:UserRdbRepository,
    name:UserName,
    email:UserEmail,
    hashedPassword:HashedPassword):UserId =
  let userIdData =
    rdb()
    .table("users")
    .insertID(%*{
      "name": $name,
      "email": $email,
      "password": $hashedPassword
    })
  let userId = newUserId(userIdData)
  return userId

proc getUser*(self:UserRdbRepository, email:UserEmail):User =
  let userData = rdb().table("users").where("email", "=", $email).first()
  if not userData.isSome():
    raise newException(Exception, "user not found")
  let id = newUserId(userData.get["id"].getInt)
  let name = newUserName(userData.get["name"].getStr)
  let hashedPassword = newHashedPassword(userData.get["password"].getStr)
  let user = newUser(id=id, name=name, email=email, hashedPassword=hashedPassword)
  return user


proc toInterface*(self:UserRdbRepository):IUserRepository =
  return (
    storeUser: proc(
      name:UserName, email:UserEmail,hashedPassword:HashedPassword
    ):UserId = self.storeUser(name, email, hashedPassword),
    getUser: proc(email:UserEmail):User = self.getUser(email)
  )

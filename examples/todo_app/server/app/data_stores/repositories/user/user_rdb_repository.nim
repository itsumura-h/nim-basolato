import json, options, asyncdispatch
import interface_implements
import allographer/query_builder
import ../../../../database
import ../../../models/user/user_repository_interface
import ../../../models/user/user_entity
import ../../../models/user/user_value_objects


type UserRdbRepository* = ref object

proc newUserRdbRepository*():UserRdbRepository =
  result = new UserRdbRepository

implements UserRdbRepository, IUserRepository:
  proc storeUser(
      self:UserRdbRepository,
      name:UserName,
      email:UserEmail,
      hashedPassword:HashedPassword):Future[UserId] {.async.} =
    let userIdData =
      await rdb
            .table("users")
            .insertID(%*{
              "name": $name,
              "email": $email,
              "password": $hashedPassword
            })
    let userId = newUserId(userIdData)
    return userId

  proc getUser(self:UserRdbRepository, email:UserEmail):Future[User] {.async.} =
    let userData = await rdb.table("users").where("email", "=", $email).first()
    if not userData.isSome():
      raise newException(Exception, "user not found")
    let id = newUserId(userData.get["id"].getInt)
    let name = newUserName(userData.get["name"].getStr)
    let hashedPassword = newHashedPassword(userData.get["password"].getStr)
    let user = newUser(id=id, name=name, email=email, hashedPassword=hashedPassword)
    return user

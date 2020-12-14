import json
import allographer/query_builder
import ../user_entity
import ../../value_objects


type UserRdbRepository* = ref object


proc newUserRepository*():UserRdbRepository =
  return UserRdbRepository()

proc storeUser*(this:UserRdbRepository,
  name:UserName,
  email:UserEmail,
  hashedPassword:HashedPassword
):UserId =
  let userIdData = rdb()
                  .table("users")
                  .insertID(%*{
                    "name": name.get(),
                    "email": email.get(),
                    "password": hashedPassword.get()
                  })
  let userId = newUserId(userIdData)
  return userId

proc getUser*(this:UserRdbRepository, email:UserEmail):User =
  let userData = rdb().table("users").where("email", "=", email.get).first()
  let id = newUserId(userData["id"].getInt)
  let name = newUserName(userData["name"].getStr)
  let hashedPassword = newHashedPassword(userData["password"].getStr)
  let user = newUser(id, name, email, hashedPassword)
  return user

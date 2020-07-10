import json, options

import user_repository

import ../../../../active_records/rdb
import ../user_entity
import ../../value_objects


proc newUserRdbRepository*():UserRepository =
  return UserRepository()


proc find*(this:UserRepository, email:Email):Option[User] =
  let userData = newUserTable().select("*").where("email", "=", email.get()).first()
  if userData.len > 0:
    return some(newUser(
      newUserId(userData["id"].getInt),
      newUserName(userData["name"].getStr),
      newEmail(userData["email"].getStr),
      newHashedPassword(userData["password"].getStr)
    ))
  else:
    return none(User)

proc save*(this:UserRepository, user:User):int =
  return newUserTable().insertID(%*{
    "name":user.name.get(),
    "email":user.email.get(),
    "password":user.password.getHashed()
  })
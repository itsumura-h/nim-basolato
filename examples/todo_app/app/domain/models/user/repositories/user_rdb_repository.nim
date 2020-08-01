import json, options
import allographer/query_builder
import ../user_entity
import ../../value_objects

type UserRdbRepository* = ref object

proc newUserRepository*():UserRdbRepository =
  return UserRdbRepository()


proc find*(this:UserRdbRepository, email:Email):Option[User] =
  let userData = RDB().table("users").select("*").where("email", "=", email.get()).first()
  if userData.len > 0:
    return some(newUser(
      newUserId(userData["id"].getInt),
      newUserName(userData["name"].getStr),
      newEmail(userData["email"].getStr),
      newHashedPassword(userData["password"].getStr)
    ))
  else:
    return none(User)

proc save*(this:UserRdbRepository, user:User):int =
  return RDB().table("users").insertID(%*{
    "name":user.name.get(),
    "email":user.email.get(),
    "password":user.password.getHashed()
  })

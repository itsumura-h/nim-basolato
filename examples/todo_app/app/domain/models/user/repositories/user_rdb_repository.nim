import json, options
import ../../../../active_records/rdb
import ../user_entity
import ../../value_objects

type UserRepository* = ref object

proc newUserRepository*():UserRepository =
  return UserRepository()

proc find*(this:UserRepository, email:string):Option[User] =
  let userData = newUserTable().select("id", "name", "email").where("email", "=", email).first()
  if userData.len > 0:
    return some(
      newUser(
        newUserId(userData["id"].getInt),
        newUserName(userData["name"].getStr),
        newEmail(userData["email"].getStr)
      )
    )
  else:
    return none(User)

proc save*(this:UserRepository, user:User):int =
  return newUserTable().insertID(%*{
    "name":user.name.get(),
    "email":user.email.get(),
    "password":user.password.getHashed()
  })
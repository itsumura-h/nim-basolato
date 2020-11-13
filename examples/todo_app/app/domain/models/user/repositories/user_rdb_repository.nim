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
  password:HashedPassword
) =
  rdb().table("users").insert(%*{
    "name": name.get(),
    "email": email.get(),
    "password": password.get()
  })

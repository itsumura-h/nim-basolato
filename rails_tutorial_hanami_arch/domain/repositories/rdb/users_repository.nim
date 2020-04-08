import json
import allographer/query_builder
import ../../entities/users_entity

type UserRepository = ref object
  db:RDB

proc newUserRepository*():UserRepository =
  return UserRepository(db:RDB())

proc show*(this:UserRepository, id:int):JsonNode =
  return this.db.table("users").find(id)

proc store*(this:UserRepository, user:User) =
  this.db.table("users").insert(%*{
    "name": user.name.get(),
    "email": user.email.get(),
    "password": user.password.get(),
  })

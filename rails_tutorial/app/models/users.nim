import json, strutils
import basolato/model
import allographer/query_builder

type User = ref object of Model

proc newUser*():User =
  return User.newModel()


proc show*(this:User, id:int):JsonNode =
  return this.db.find(id)

proc store*(this:User, name:string, email:string, password:string) =
  this.db.insert(%*{
    "name": name,
    "email": email,
    "password": password
  })

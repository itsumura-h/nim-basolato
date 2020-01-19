import json
import bcrypt
import allographer/query_builder

type User* = ref object
  db: RDB

proc newUser*(): User =
  return User(
    db: RDB().table("users")
  )


proc createUser*(this:User, name, email, password:string): int =
  let salt = genSalt(10)
  this.db.insertID(%*{
    "name": name,
    "email": email,
    "password": hash(password, salt)
  })

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

proc isEmailDuplication*(this:User, email:string): bool =
  let num = this.db.where("email", "=", email).count()
  return if num > 0: false else: true

proc getUserByEmail*(this:User, email:string): JsonNode =
  this.db
    .select("id", "name", "password")
    .where("email", "=", email)
    .first()

import json, tables
import bcrypt
import allographer/query_builder
import ../../src/basolato/validation

proc checkPassword*(this:Validation, key:string): Validation =
  let password = this.params["password"]
  let dbPass = RDB().table("users")
                  .select("password")
                  .where("email", "=", this.params["email"])
                  .first()["password"].getStr
  let hash = dbPass.substr(0, 28)
  let hashed = hash(password, hash)
  let isMatch = compare(hashed, dbPass)
  if not isMatch:
    this.putValidate(key, "password is not match")
  return this

import json, tables
import bcrypt
import allographer/query_builder
import ../../src/basolato/validation

proc checkPassword*(this:Validation, key:string): Validation =
  let password = this.params["password"]
  let response = RDB().table("users")
                  .select("password")
                  .where("email", "=", this.params["email"])
                  .first()
  let dbPass = if response.kind != JNull: response["password"].getStr else: ""
  let hash = dbPass.substr(0, 28)
  let hashed = hash(password, hash)
  let isMatch = compare(hashed, dbPass)
  if not isMatch:
    this.putValidate(key, "password is not match")
  return this

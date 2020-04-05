import strutils, re, json
import bcrypt
import allographer/query_builder


type Name = ref object
  value:string

proc newName(value:string):Name =
  if isNilOrWhitespace(value):
    raise newException(Exception, "Name can't be blank")
  if value.len == 0:
    raise newException(Exception, "Name can't be blank")
  if value.len > 50:
    raise newException(Exception, "Name should be shorter than 50")
  return Name(value:value)

proc get*(this:Name):string =
  return this.value
# ==============================
type Email = ref object
  value:string

proc newEmail(value:string):Email =
  var value = value.toLowerAscii
  if isNilOrWhitespace(value):
    raise newException(Exception, "Email can't be blank")
  if value.len == 0:
    raise newException(Exception, "Email can't be blank")
  if value.len > 255:
    raise newException(Exception, "Email should be shorter than 255")
  if not value.match(re"\A[\w+\-.]+@[a-zA-Z\d\-]+(\.[a-zA-Z\d\-]+)*\.[a-zA-Z]+\Z"):
    raise newException(Exception, "Invalid Email format")
  if RDB().table("users").where("email", "=", value).count() > 0:
    raise newException(Exception, "email should unique")
  return Email(value:value)

proc get*(this:Email):string =
  return this.value
# ==============================
type Password = ref object
  value:string

proc newPassword*(value:string):Password =
  if value.len < 6:
    raise newException(Exception, "email should at least 6 chard")
  if value.match(re"\s"):
    raise newException(Exception, "email should not blank")
  return Password(value:value)

proc get*(this:Password):string =
  return this.value.hash(genSalt(5))

# ==============================

type User* = ref object
  name*:Name
  email*:Email
  password*:Password

proc newUser*(name="", email="", password=""):User =
  return User(
    name:newName(name),
    email:newEmail(email),
    password:newPassword(password)
  )
import strutils, re
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
# ==============================
type Email = ref object
  value:string

proc newEmail(value:string):Email =
  if isNilOrWhitespace(value):
    raise newException(Exception, "Email can't be blank")
  if value.len == 0:
    raise newException(Exception, "Email can't be blank")
  if value.len > 255:
    raise newException(Exception, "Email should be shorter than 255")
  if not value.match(re"\A[\w+\-.]+@[a-zA-Z\d\-]+(\.[a-zA-Z\d\-]+)*\.[a-zA-Z]+\Z"):
    raise newException(Exception, "Invalid Email format")
  return Email(value:value)
# ==============================

type User* = ref object
  name*:Name
  email*:Email

proc newUser*(name:string, email:string):User =
  return User(
    name:newName(name),
    email:newEmail(email)
  )
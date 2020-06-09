import strutils, re
import bcrypt
import ../../../../../src/basolato/baseEnv
import allographer/query_builder

import json

type Id* = ref object
  value:int

proc newId*(value:int):Id =
  if value < 1:
    raise newException(Exception, "id should be an unsigned number")
  return Id(value:value)

proc get*(this:Id):int =
  return this.value
# =============================================================================
type UserName* = ref object
  value:string

proc newUserName*(value:string):UserName =
  if isEmptyOrWhitespace(value):
    raise newException(Exception, "Name can't be blank")
  if value.len == 0:
    raise newException(Exception, "Name can't be blank")
  if value.len > 50:
    raise newException(Exception, "Name should be shorter than 50")
  return UserName(value:value)

proc get*(this:UserName):string =
  return this.value
# =============================================================================
type Email* = ref object
  value:string

proc newEmail*(value:string):Email =
  var value = value.toLowerAscii
  if isEmptyOrWhitespace(value):
    raise newException(Exception, "Email can't be blank")
  if value.len == 0:
    raise newException(Exception, "Email can't be blank")
  if value.len > 255:
    raise newException(Exception, "Email should be shorter than 255")
  if not value.match(re"\A[\w+\-.]+@[a-zA-Z\d\-]+(\.[a-zA-Z\d\-]+)*\.[a-zA-Z]+\Z"):
    raise newException(Exception, "Invalid Email format")
  return Email(value:value)

proc get*(this:Email):string =
  return this.value

proc isUnique*(this:Email):bool =
  if RDB().table("users").where("email", "=", this.value).count() > 0:
    return false
  else:
    return true
# =============================================================================
type Password* = ref object
  value:string

proc newPassword*(value:string):Password =
  if value.len < 6:
    raise newException(Exception, "password should at least 6 chard")
  if value.match(re"\s"):
    raise newException(Exception, "password should not be blank")
  return Password(value:value)

proc get*(this:Password):string =
  return this.value

proc getHashed*(this:Password):string =
  return this.value.hash(SALT)
# =============================================================================
import asynchttpserver, os, json, re, tables, strformat, strutils, unicode
# from ./core/core import Request, params
import core/baseEnv
include core/validation
import core/request
import allographer/query_builder

let message_templats = getCurrentDir() / &"resources/lang/{LANGUAGE}/validation.json"


type RequestValidation* = ref object
  params*: Params
  errors*: JsonNode # JObject

type ValidationError* = object of CatchableError


proc newValidation*(params: Params):RequestValidation =
  return RequestValidation(
    params: params,
    errors: newJObject()
  )


proc putValidate*(self: var RequestValidation, key: string, error: JsonNode) =
  if isNil(self.errors):
    self.errors = %{key: error}
  else:
    self.errors[key] = error

proc putValidate*(self: var RequestValidation, key: string, msg: string) =
  if isNil(self.errors):
    self.errors = %*{key: [msg]}
  elif self.errors.hasKey(key):
    self.errors[key].add(%(msg))
  else:
    self.errors[key] = %[(msg)]

proc valid*(self:RequestValidation) =
  if self.errors.len > 0:
    raise newException(ValidationError, "")

# =============================================================================

proc accepted*(self: var RequestValidation, key: string, val = "on") =
  if self.params.hasKey(key):
    if self.params.getStr(key) != val:
      self.putValidate(key, &"{key} should be accepted")


proc contains*(self: var RequestValidation, key: string, val: string) =
  if self.params.hasKey(key):
    if not self.params.getStr(key).contains(val):
      self.putValidate(key, &"{key} should contain {val}")


proc digits*(self: var RequestValidation, key: string, digit: int) =
  let error = %digits(self.params.getStr(key), digit)
  if error.len > 0:
    self.putValidate(key, error)


proc domain*(self: var RequestValidation, key = "domain") =
  let error = %domain(self.params.getStr(key))
  if error.len > 0:
    self.putValidate(key, error)


proc email*(self: var RequestValidation, key = "email") =
  let error = %email(self.params.getStr(key))
  if error.len > 0:
    self.putValidate(key, error)


proc strictEmail*(self: var RequestValidation, key = "email") =
  let error = %strictEmail(self.params.getStr(key))
  if error.len > 0:
    self.putValidate(key, error)


proc equals*(self: var RequestValidation, key: string, val: string) =
  let error = %equals(self.params.getStr(key), val)
  if error.len > 0:
    self.putValidate(key, error)


proc exists*(self: var RequestValidation, key: string) =
  if not self.params.hasKey(key):
    self.putValidate(key, &"{key} should exists in request params")


proc gratorThan*(self: var RequestValidation, key: string, val: float) =
  let error = %gratorThan(self.params.getStr(key).parseFloat, val)
  if error.len > 0:
    self.putValidate(key, error)


proc inRange*(self: var RequestValidation, key: string, min: float,
              max: float) =
  let error = %inRange(self.params.getStr(key).parseFloat, min, max)
  if error.len > 0:
    self.putValidate(key, error)


proc ip*(self: var RequestValidation, key: string) =
  let error = %domain(&"[{self.params.getStr(key)}]")
  if error.len > 0:
    self.putValidate(key, error)


proc isBool*(self: var RequestValidation, key: string) =
  let error = %isBool(self.params.getStr(key))
  if error.len > 0:
    self.putValidate(key, error)


proc isFloat*(self: var RequestValidation, key: string) =
  let error = %isFloat(self.params.getStr(key))
  if error.len > 0:
    self.putValidate(key, error)


proc isIn*(self: var RequestValidation, key: string,
            vals: openArray[int|float|string]) =
  if self.params.hasKey(key):
    var count = 0
    for val in vals:
      if self.params.getStr(key) == $val:
        count.inc
    if count == 0:
      self.putValidate(key, &"{key} should be in {vals}")


proc isInt*(self: var RequestValidation, key: string) =
  let error = %isInt(self.params.getStr(key))
  if error.len > 0:
    self.putValidate(key, error)


proc isString*(self: var RequestValidation, key: string) =
  let error = %isString(self.params.getStr(key))
  if error.len > 0:
    self.putValidate(key, error)


proc lessThan*(self: var RequestValidation, key: string, val: float) =
  let error = %lessThan(self.params.getStr(key).parseFloat, val)
  if error.len > 0:
    self.putValidate(key, error)


proc numeric*(self: var RequestValidation, key: string) =
  let error = %numeric(self.params.getStr(key))
  if error.len > 0:
    self.putValidate(key, error)


proc oneOf*(self: var RequestValidation, keys: openArray[string]) =
  var count = 0
  for key, val in self.params:
    if keys.contains(key):
      count.inc
  if count == 0:
    self.putValidate("oneOf", &"at least one of {keys} is required")


proc password*(self: var RequestValidation, key = "password") =
  var error = newJArray()
  if self.params.getStr(key).len == 0:
    error.add(%"this field is required")

  if self.params.getStr(key).len < 8:
    error.add(%"password needs at least 8 chars")

  if not self.params.getStr(key).match(re"(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[!-~a-zA-Z\d]*"):
    error.add(%"invalid form of password")

  if error.len > 0:
    self.putValidate(key, error)


proc required*(self: var RequestValidation, keys: openArray[string]) =
  for key in keys:
    if not self.params.hasKey(key) or self.params.getStr(key).len == 0:
      self.putValidate(key, &"{key} is required")


proc unique*(self: var RequestValidation, key: string, table: string,
    column: string) =
  if self.params.hasKey(key):
    let val = self.params.getStr(key)
    let num = RDB().table(table).where(column, "=", val).count()
    if num > 0:
      self.putValidate(key, &"{key} should be unique")
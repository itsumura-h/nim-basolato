import json, re, tables, strformat, strutils, unicode
# from ./core/core import Request, params
include core/validation
import core/request
import allographer/query_builder



type RequestValidation* = ref object
  params*: RequestParams
  errors*: JsonNode # JObject

type ValidationError* = object of CatchableError


proc newValidation*(params: RequestParams):RequestValidation =
  return RequestValidation(
    params: params,
    errors: newJObject()
  )


proc putValidate*(this: var RequestValidation, key: string, error: JsonNode) =
  if isNil(this.errors):
    this.errors = %{key: error}
  else:
    this.errors[key] = error

proc putValidate*(this: var RequestValidation, key: string, msg: string) =
  if isNil(this.errors):
    this.errors = %*{key: [msg]}
  elif this.errors.hasKey(key):
    this.errors[key].add(%(msg))
  else:
    this.errors[key] = %[(msg)]

proc valid*(this:RequestValidation) =
  if this.errors.len > 0:
    raise newException(ValidationError, "")

# =============================================================================

proc accepted*(this: var RequestValidation, key: string, val = "on") =
  if this.params.hasKey(key):
    if this.params.get(key) != val:
      this.putValidate(key, &"{key} should be accespted")


proc contains*(this: var RequestValidation, key: string, val: string) =
  if this.params.hasKey(key):
    if not this.params.get(key).contains(val):
      this.putValidate(key, &"{key} should contain {val}")


proc digits*(this: var RequestValidation, key: string, digit: int) =
  let error = %digits(this.params.get(key), digit)
  if error.len > 0:
    this.putValidate(key, error)


proc domain*(this: var RequestValidation, key = "domain") =
  let error = %domain(this.params.get(key))
  if error.len > 0:
    this.putValidate(key, error)


proc email*(this: var RequestValidation, key = "email") =
  let error = %email(this.params.get(key))
  if error.len > 0:
    this.putValidate(key, error)


proc strictEmail*(this: var RequestValidation, key = "email") =
  let error = %strictEmail(this.params.get(key))
  if error.len > 0:
    this.putValidate(key, error)


proc equals*(this: var RequestValidation, key: string, val: string) =
  let error = %equals(this.params.get(key), val)
  if error.len > 0:
    this.putValidate(key, error)


proc exists*(this: var RequestValidation, key: string) =
  if not this.params.hasKey(key):
    this.putValidate(key, &"{key} should exists in request params")


proc gratorThan*(this: var RequestValidation, key: string, val: float) =
  let error = %gratorThan(this.params.get(key).parseFloat, val)
  if error.len > 0:
    this.putValidate(key, error)


proc inRange*(this: var RequestValidation, key: string, min: float,
              max: float) =
  let error = %inRange(this.params.get(key).parseFloat, min, max)
  if error.len > 0:
    this.putValidate(key, error)


proc ip*(this: var RequestValidation, key: string) =
  let error = %domain(&"[{this.params.get(key)}]")
  if error.len > 0:
    this.putValidate(key, error)


proc isBool*(this: var RequestValidation, key: string) =
  let error = %isBool(this.params.get(key))
  if error.len > 0:
    this.putValidate(key, error)


proc isFloat*(this: var RequestValidation, key: string) =
  let error = %isFloat(this.params.get(key))
  if error.len > 0:
    this.putValidate(key, error)


proc isIn*(this: var RequestValidation, key: string,
            vals: openArray[int|float|string]) =
  if this.params.hasKey(key):
    var count = 0
    for val in vals:
      if this.params.get(key) == $val:
        count.inc
    if count == 0:
      this.putValidate(key, &"{key} should be in {vals}")


proc isInt*(this: var RequestValidation, key: string) =
  let error = %isInt(this.params.get(key))
  if error.len > 0:
    this.putValidate(key, error)


proc isString*(this: var RequestValidation, key: string) =
  let error = %isString(this.params.get(key))
  if error.len > 0:
    this.putValidate(key, error)


proc lessThan*(this: var RequestValidation, key: string, val: float) =
  let error = %lessThan(this.params.get(key).parseFloat, val)
  if error.len > 0:
    this.putValidate(key, error)


proc numeric*(this: var RequestValidation, key: string) =
  let error = %numeric(this.params.get(key))
  if error.len > 0:
    this.putValidate(key, error)


proc oneOf*(this: var RequestValidation, keys: openArray[string]) =
  var count = 0
  for key, val in this.params:
    if keys.contains(key):
      count.inc
  if count == 0:
    this.putValidate("oneOf", &"at least one of {keys} is required")


proc password*(this: var RequestValidation, key = "password") =
  var error = newJArray()
  if this.params.get(key).len == 0:
    error.add(%"this field is required")

  if this.params.get(key).len < 8:
    error.add(%"password needs at least 8 chars")

  if not this.params.get(key).match(re"(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[!-~a-zA-Z\d]*"):
    error.add(%"invalid form of password")

  if error.len > 0:
    this.putValidate(key, error)


proc required*(this: var RequestValidation, keys: openArray[string]) =
  for key in keys:
    if not this.params.hasKey(key) or this.params.get(key).len == 0:
      this.putValidate(key, &"{key} is required")


proc unique*(this: var RequestValidation, key: string, table: string,
    column: string) =
  if this.params.hasKey(key):
    let val = this.params.get(key)
    let num = RDB().table(table).where(column, "=", val).count()
    if num > 0:
      this.putValidate(key, &"{key} should be unique")
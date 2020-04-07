import json, re, tables, strformat, strutils, unicode
from jester import Request, params
include validation
import allographer/query_builder



type RequestValidation* = ref object
  params*: Table[string, string]
  errors*: JsonNode # JObject


proc validate*(request: Request): RequestValidation =
  RequestValidation(
    params: request.params,
    errors: newJObject()
  )


proc putValidate*(this: RequestValidation, key: string, error: JsonNode) =
  if isNil(this.errors):
    this.errors = %{key: error}
  else:
    this.errors[key] = error

proc putValidate*(this: RequestValidation, key: string, msg: string) =
  if isNil(this.errors):
    this.errors = %*{key: [msg]}
  elif this.errors.hasKey(key):
    this.errors[key].add(%(msg))
  else:
    this.errors[key] = %[(msg)]

# =============================================================================

proc accepted*(this: RequestValidation, key: string, val = "on"): RequestValidation =
  if this.params.hasKey(key):
    if this.params[key] != val:
      this.putValidate(key, &"{key} should be accespted")
  return this

proc contains*(this: RequestValidation, key: string, val: string): RequestValidation =
  if this.params.hasKey(key):
    if not this.params[key].contains(val):
      this.putValidate(key, &"{key} should contain {val}")
  return this

proc email*(this: RequestValidation, key="email"): RequestValidation =
  let error = %email(this.params[key])
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc digits*(this: RequestValidation, key:string, digit:int): RequestValidation =
  let error = %digits(this.params[key], digit)
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc domain*(this:RequestValidation, key="domain"):RequestValidation =
  let error = %domain(this.params[key])
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc strictEmail*(this:RequestValidation, key="email"):RequestValidation =
  let error = %strictEmail(this.params[key])
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc equals*(this: RequestValidation, key: string, val: string): RequestValidation =
  let error = %equals(this.params[key], val)
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc exists*(this: RequestValidation, key: string): RequestValidation =
  if not this.params.hasKey(key):
    this.putValidate(key, &"{key} should exists in request params")
  return this

proc gratorThan*(this: RequestValidation, key: string, val: float): RequestValidation =
  let error = %gratorThan(this.params[key].parseFloat, val)
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc inRange*(this: RequestValidation, key: string, min: float,
              max: float): RequestValidation =
  let error = %inRange(this.params[key].parseFloat, min, max)
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc ip*(this: RequestValidation, key: string): RequestValidation =
  let error = %domain(&"[{this.params[key]}]")
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc isBool*(this:RequestValidation, key:string): RequestValidation =
  let error = %isBool(this.params[key])
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc isFloat*(this:RequestValidation, key:string): RequestValidation =
  let error = %isFloat(this.params[key])
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc isIn*(this:RequestValidation, key:string,
            vals:openArray[int|float|string]): RequestValidation =
  if this.params.hasKey(key):
    var count = 0
    for val in vals:
      if this.params[key] == $val:
        count.inc
    if count == 0:
      this.putValidate(key, &"{key} should be in {vals}")
  return this

proc isInt*(this:RequestValidation, key:string): RequestValidation =
  let error = %isInt(this.params[key])
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc isString*(this:RequestValidation, key:string): RequestValidation =
  let error = %isString(this.params[key])
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc lessThan*(this: RequestValidation, key: string, val: float): RequestValidation =
  let error = %lessThan(this.params[key].parseFloat, val)
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc numeric*(this: RequestValidation, key: string): RequestValidation =
  let error = %numeric(this.params[key])
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc oneOf*(this: RequestValidation, keys: openArray[string]): RequestValidation =
  var count = 0
  for key, val in this.params:
    if keys.contains(key):
      count.inc
  if count == 0:
    this.putValidate("oneOf", &"at least one of {keys} is required")
  return this

proc password*(this: RequestValidation, key = "password"): RequestValidation =
  var error = newJArray()
  if this.params[key].len == 0:
    error.add(%"this field is required")

  if this.params[key].len < 8:
    error.add(%"password needs at least 8 chars")

  if not this.params[key].match(re"(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[!-~a-zA-Z\d]*"):
    error.add(%"invalid form of password")

  if error.len > 0:
    this.putValidate(key, error)

  return this

proc required*(this: RequestValidation, keys: openArray[string]): RequestValidation =
  for key in keys:
    if not this.params.hasKey(key) or this.params[key].len == 0:
      this.putValidate(key, &"{key} is required")
  return this

proc unique*(this: RequestValidation, key: string, table: string,
    column: string): RequestValidation =
  if this.params.hasKey(key):
    let val = this.params[key]
    let num = RDB().table(table).where(column, "=", val).count()
    if num > 0:
      this.putValidate(key, &"{key} should be unique")
  return this

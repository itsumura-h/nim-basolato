import asynchttpserver, os, json, re, tables, strformat, strutils, unicode
# from ./core/core import Request, params
import core/baseEnv
include core/validation
import core/request
import core/logger
import allographer/query_builder

let baseMessages = %*{
  "accepted": "The :attribute must be accepted.",
  "after": "The :attribute must be a date after :date.",
  "after_or_equal": "The :attribute must be a date after or equal to :date.",
  "alpha": "The :attribute may only contain letters.",
  "alpha_dash": "The :attribute may only contain letters, numbers, dashes and underscores.",
  "alpha_num": "The :attribute may only contain letters and numbers.",
  "array": "The :attribute must be an array.",
  "before": "The :attribute must be a date before :date.",
  "before_or_equal": "The :attribute must be a date before or equal to :date.",
  "between": {
    "numeric": "The :attribute must be between :min and :max.",
    "file": "The :attribute must be between :min and :max kilobytes.",
    "string": "The :attribute must be between :min and :max characters.",
    "array": "The :attribute must have between :min and :max items.",
  },
  "boolean": "The :attribute field must be true or false.",
  "confirmed": "The :attribute confirmation does not match.",
  "date": "The :attribute is not a valid date.",
  "date_equals": "The :attribute must be a date equal to :date.",
  "different": "The :attribute and :other must be different.",
  "digits": "The :attribute must be :digits digits.",
  "digits_between": "The :attribute must be between :min and :max digits.",
  "distinct": "The :attribute field has a duplicate value.",
  "domain": "The :attribute must be a valid domain.",
  "email": "The :attribute must be a valid email address.",
  "ends_with": "The :attribute must be end with one of following :values.",
  "exists": "The selected :attribute is invalid.",
  "file": "The :attribute must be a file.",
  "filled": "The :attribute field must have a value.",
  "gt": {
    "numeric": "The :attribute must be greater than :value.",
    "file": "The :attribute must be greater than :value kilobytes.",
    "string": "The :attribute must be greater than :value characters.",
    "array": "The :attribute must have more than :value items.",
  },
  "gte": {
    "numeric": "The :attribute must be greater than or equal :value.",
    "file": "The :attribute must be greater than or equal :value kilobytes.",
    "string": "The :attribute must be greater than or equal :value characters.",
    "array": "The :attribute must have :value items or more.",
  },
  "image": "The :attribute must be an image.",
  "in": "The selected :attribute is invalid.",
  "in_array": "The :attribute field does not exist in :other.",
  "integer": "The :attribute must be an integer.",
  "ip": "The :attribute must be a valid IP address.",
  "ipv4": "The :attribute must be a valid IPv4 address.",
  "ipv6": "The :attribute must be a valid IPv6 address.",
  "json": "The :attribute must be a valid JSON string.",
  "lt": {
    "numeric": "The :attribute must be less than :value.",
    "file": "The :attribute must be less than :value kilobytes.",
    "string": "The :attribute must be less than :value characters.",
    "array": "The :attribute must have less than :value items.",
  },
  "lte": {
    "numeric": "The :attribute must be less than or equal :value.",
    "file": "The :attribute must be less than or equal :value kilobytes.",
    "string": "The :attribute must be less than or equal :value characters.",
    "array": "The :attribute must not have more than :value items.",
  },
  "max": {
    "numeric": "The :attribute may not be greater than :max.",
    "file": "The :attribute may not be greater than :max kilobytes.",
    "string": "The :attribute may not be greater than :max characters.",
    "array": "The :attribute may not have more than :max items.",
  },
  "mimes": "The :attribute must be a file of type: :values.",
  "mimetypes": "The :attribute must be a file of type: :values.",
  "min": {
    "numeric": "The :attribute must be at least :min.",
    "file": "The :attribute must be at least :min kilobytes.",
    "string": "The :attribute must be at least :min characters.",
    "array": "The :attribute must have at least :min items.",
  },
  "not_in": "The selected :attribute is invalid.",
  "not_regex": "The :attribute format is invalid.",
  "numeric": "The :attribute must be a number.",
  "present": "The :attribute field must be present.",
  "regex": "The :attribute format is invalid.",
  "required": "The :attribute field is required.",
  "required_if": "The :attribute field is required when :other is :value.",
  "required_unless": "The :attribute field is required unless :other is in :values.",
  "required_with": "The :attribute field is required when :values is present.",
  "required_with_all": "The :attribute field is required when :values are present.",
  "required_without": "The :attribute field is required when :values is not present.",
  "required_without_all": "The :attribute field is required when none of :values are present.",
  "same": "The :attribute and :other must match.",
  "size": {
    "numeric": "The :attribute must be :size.",
    "file": "The :attribute must be :size kilobytes.",
    "string": "The :attribute must be :size characters.",
    "array": "The :attribute must contain :size items.",
  },
  "starts_with": "The :attribute must be start with one of following :values.",
  "string": "The :attribute must be a string.",
  "timezone": "The :attribute must be a valid zone.",
  "unique": "The :attribute has already been taken.",
  "uploaded": "The :attribute failed to upload.",
  "url": "The :attribute format is invalid.",
  "uuid": "The :attribute must be a valid UUID.",
}
discard """
Laravel validation impl
http://github.com/illuminate/validation/blob/master/Concerns/ValidatesAttributes.php

changed item in message
delete: active_url, bail, date_format, dimensions
add: domain
"""

when defined(testing):
  let messages = baseMessages
else:
  let messageTemplatePath = getCurrentDir() / &"resources/lang/{LANGUAGE}/validation.json"
  let messages =
    if messageTemplatePath.fileExists():
      let f = open(messageTemplatePath)
      f.readAll().parseJson()
    else:
      baseMessages

type ValidationErrors* = TableRef[string, seq[string]]

proc newValidationErrors():ValidationErrors =
  return newTable[string, seq[string]]()


type RequestValidation* = ref object
  params: Params
  errors: ValidationErrors

func newRequestValidation*(params: Params):RequestValidation =
  return RequestValidation(
    params: params,
    errors: newValidationErrors()
  )

func add*(self: RequestValidation, key, error:string) =
  if self.errors.hasKey(key):
    self.errors[key].add(error)
  else:
    self.errors[key] = @[error]

func hasError*(self:RequestValidation):bool =
  return self.errors.len > 0

func errors*(self:RequestValidation):ValidationErrors =
  return self.errors

# =============================================================================

proc accepted*(self:RequestValidation, key:string, val="on") =
  if self.params.hasKey(key):
    if not self.params.getStr(key).accepted():
      let message = messages["accepted"].getStr.replace(":attribute", key)
      self.add(key, message)

proc after*(self:RequestValidation, base, target, format:string) =
  if self.params.hasKey(base) and self.params.hasKey(target):
    let a = self.params.getStr(base).parse(format)
    let b = self.params.getStr(target).parse(format)
    if not after(a, b):
      let message = messages["after"].getStr
        .replace(":attribute", base)
        .replace(":date", self.params.getStr(target))
      self.add(base, message)

proc after*(self:RequestValidation, base:string, target:DateTime, format:string) =
  if self.params.hasKey(base):
    let a = self.params.getStr(base).parse(format)
    let b = target
    if not after(a, b):
      let message = messages["after"].getStr
        .replace(":attribute", base)
        .replace(":date", $target)
      self.add(base, message)

proc afterOrEqual*(self:RequestValidation, base, target, format:string) =
  if self.params.hasKey(base) and self.params.hasKey(target):
    let a = self.params.getStr(base).parse(format)
    let b = self.params.getStr(target).parse(format)
    if not afterOrEqual(a, b):
      let message = messages["after_or_equal"].getStr
        .replace(":attribute", base)
        .replace(":date", self.params.getStr(target))
      self.add(base, message)

proc afterOrEqual*(self:RequestValidation, base:string, target:DateTime, format:string) =
  if self.params.hasKey(base):
    let a = self.params.getStr(base).parse(format)
    let b = target
    if not afterOrEqual(a, b):
      let message = messages["after_or_equal"].getStr
        .replace(":attribute", base)
        .replace(":date", $target)
      self.add(base, message)

proc alpha*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    if not self.params.getStr(key).alpha():
      let message = messages["alpha"].getStr.replace(":attribute", key)
      self.add(key, message)

proc alphaDash*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    if not self.params.getStr(key).alphaDash():
      let message = messages["alpha_dash"].getStr.replace(":attribute", key)
      self.add(key, message)

proc alphaNum*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    if not self.params.getStr(key).alphaNum():
      let message = messages["alpha_num"].getStr.replace(":attribute", key)
      self.add(key, message)

proc array*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    if not self.params.getStr(key).array():
      let message = messages["array"].getStr.replace(":attribute", key)
      self.add(key, message)

proc before*(self:RequestValidation, base, target, format:string) =
  if self.params.hasKey(base) and self.params.hasKey(target):
    let a = self.params.getStr(base).parse(format)
    let b = self.params.getStr(target).parse(format)
    if not before(a, b):
      let message = messages["before"].getStr
        .replace(":attribute", base)
        .replace(":date", self.params.getStr(target))
      self.add(base, message)

proc before*(self:RequestValidation, base:string, target:DateTime, format:string) =
  if self.params.hasKey(base):
    let a = self.params.getStr(base).parse(format)
    let b = target
    if not before(a, b):
      let message = messages["before"].getStr
        .replace(":attribute", base)
        .replace(":date", $target)
      self.add(base, message)

proc beforeOrEqual*(self:RequestValidation, base, target, format:string) =
  if self.params.hasKey(base) and self.params.hasKey(target):
    let a = self.params.getStr(base).parse(format)
    let b = self.params.getStr(target).parse(format)
    if not beforeOrEqual(a, b):
      let message = messages["before_or_equal"].getStr
        .replace(":attribute", base)
        .replace(":date", self.params.getStr(target))
      self.add(base, message)

proc beforeOrEqual*(self:RequestValidation, base:string, target:DateTime, format:string) =
  if self.params.hasKey(base):
    let a = self.params.getStr(base).parse(format)
    let b = target
    if not beforeOrEqual(a, b):
      let message = messages["before_or_equal"].getStr
        .replace(":attribute", base)
        .replace(":date", $target)
      self.add(base, message)

proc betweenNum*(self:RequestValidation, key:string, min, max:int|float) =
  if self.params.hasKey(key):
    try:
      let value = self.params.getFloat(key)
      if not between(value, min, max):
        let message = messages["between"]["numeric"].getStr
          .replace(":attribute", key)
          .replace(":min", $min)
          .replace(":max", $max)
        self.add(key, message)
    except:
      echoErrorMsg( getCurrentExceptionMsg() )

proc betweenStr*(self:RequestValidation, key:string, min, max:int) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not between(value, min, max):
      let message = messages["between"]["string"].getStr
        .replace(":attribute", key)
        .replace(":min", $min)
        .replace(":max", $max)
      self.add(key, message)

proc betweenArr*(self:RequestValidation, key:string, min, max:int) =
  if self.params.hasKey(key):
    try:
      let value = self.params.getStr(key).split(", ")
      if not between(value, min, max):
        let message = messages["between"]["array"].getStr
          .replace(":attribute", key)
          .replace(":min", $min)
          .replace(":max", $max)
        self.add(key, message)
    except:
      echoErrorMsg( getCurrentExceptionMsg() )

proc betweenFile*(self:RequestValidation, key:string, min, max:int) =
  if self.params.hasKey(key) and self.params[key].ext.len > 0:
    try:
      let value = self.params.getStr(key)
      if not betweenFile(value, min, max):
        let message = messages["between"]["file"].getStr
          .replace(":attribute", key)
          .replace(":min", $min)
          .replace(":max", $max)
        self.add(key, message)
    except:
      echoErrorMsg( getCurrentExceptionMsg() )

proc boolean*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not boolean(value):
      let message = messages["boolean"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc confirmed*(self:RequestValidation, key:string, saffix="_confirmation") =
  if self.params.hasKey(key) and self.params.hasKey(key & saffix):
    let a = self.params.getStr(key)
    let b = self.params.getStr(key & saffix)
    if not confirmed(a, b):
      let message = messages["confirmed"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc date*(self:RequestValidation, key, format:string) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not date(value, format):
      let message = messages["date"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc date*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not date(value):
      let message = messages["date"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc dateEquals*(self:RequestValidation, key, format:string, target:DateTime) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not dateEquals(value, format, target):
      let message = messages["date_equals"].getStr
        .replace(":attribute", key)
        .replace(":date", target.format("yyyy-MM-dd"))
      self.add(key, message)

proc dateEquals*(self:RequestValidation, key:string, target:DateTime) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not dateEquals(value, target):
      let message = messages["date_equals"].getStr
        .replace(":attribute", key)
        .replace(":date", target.format("yyyy-MM-dd"))
      self.add(key, message)

proc different*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let a = self.params.getStr(key)
    let b = self.params.getStr(target)
    if not different(a, b):
      let message = messages["different"].getStr
        .replace(":attribute", key)
        .replace(":other", target)
      self.add(key, message)

proc digits*(self:RequestValidation, key:string, digit:int) =
  if self.params.hasKey(key):
    let value = self.params.getInt(key)
    if not digits(value, digit):
      let message = messages["digits"].getStr
        .replace(":attribute", key)
        .replace(":digits", $digit)
      self.add(key, message)

proc digits_between*(self:RequestValidation, key:string, min, max:int) =
  if self.params.hasKey(key):
    let value = self.params.getInt(key)
    if not digits_between(value, min, max):
      let message = messages["digits_between"].getStr
        .replace(":attribute", key)
        .replace(":min", $min)
        .replace(":max", $max)
      self.add(key, message)

proc distinctArr*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    let values = self.params.getStr(key).split(", ")
    if not distinctArr(values):
      let message = messages["distinct"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc domain*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not domain(value):
      let message = messages["domain"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc email*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not email(value):
      let message = messages["email"].getStr
        .replace(":attribute", key)
      self.add(key, message)

# func contains*(self: var RequestValidation, key: string, val: string) =
#   if self.params.hasKey(key):
#     if not self.params.getStr(key).contains(val):
#       self.putValidate(key, &"{key} should contain {val}")


# func digits*(self: var RequestValidation, key: string, digit: int) =
#   let error = %digits(self.params.getStr(key), digit)
#   if error.len > 0:
#     self.putValidate(key, error)


# proc domain*(self: var RequestValidation, key = "domain") =
#   let error = %domain(self.params.getStr(key))
#   if error.len > 0:
#     self.putValidate(key, error)


# func email*(self: var RequestValidation, key = "email") =
#   let error = %email(self.params.getStr(key))
#   if error.len > 0:
#     self.putValidate(key, error)


# proc strictEmail*(self: var RequestValidation, key = "email") =
#   let error = %strictEmail(self.params.getStr(key))
#   if error.len > 0:
#     self.putValidate(key, error)


# func equals*(self: var RequestValidation, key: string, val: string) =
#   let error = %equals(self.params.getStr(key), val)
#   if error.len > 0:
#     self.putValidate(key, error)


# func exists*(self: var RequestValidation, key: string) =
#   if not self.params.hasKey(key):
#     self.putValidate(key, &"{key} should exists in request params")


# func gratorThan*(self: var RequestValidation, key: string, val: float) =
#   let error = %gratorThan(self.params.getStr(key).parseFloat, val)
#   if error.len > 0:
#     self.putValidate(key, error)


# func inRange*(self: var RequestValidation, key: string, min: float,
#               max: float) =
#   let error = %inRange(self.params.getStr(key).parseFloat, min, max)
#   if error.len > 0:
#     self.putValidate(key, error)


# proc ip*(self: var RequestValidation, key: string) =
#   let error = %domain(&"[{self.params.getStr(key)}]")
#   if error.len > 0:
#     self.putValidate(key, error)


# func isBool*(self: var RequestValidation, key: string) =
#   let error = %isBool(self.params.getStr(key))
#   if error.len > 0:
#     self.putValidate(key, error)


# func isFloat*(self: var RequestValidation, key: string) =
#   let error = %isFloat(self.params.getStr(key))
#   if error.len > 0:
#     self.putValidate(key, error)


# func isIn*(self: var RequestValidation, key: string,
#             vals: openArray[int|float|string]) =
#   if self.params.hasKey(key):
#     var count = 0
#     for val in vals:
#       if self.params.getStr(key) == $val:
#         count.inc
#     if count == 0:
#       self.putValidate(key, &"{key} should be in {vals}")


# func isInt*(self: var RequestValidation, key: string) =
#   let error = %isInt(self.params.getStr(key))
#   if error.len > 0:
#     self.putValidate(key, error)


# func isString*(self: var RequestValidation, key: string) =
#   let error = %isString(self.params.getStr(key))
#   if error.len > 0:
#     self.putValidate(key, error)


# func lessThan*(self: var RequestValidation, key: string, val: float) =
#   let error = %lessThan(self.params.getStr(key).parseFloat, val)
#   if error.len > 0:
#     self.putValidate(key, error)


# func numeric*(self: var RequestValidation, key: string) =
#   let error = %numeric(self.params.getStr(key))
#   if error.len > 0:
#     self.putValidate(key, error)


# func oneOf*(self: var RequestValidation, keys: openArray[string]) =
#   var count = 0
#   for key, val in self.params:
#     if keys.contains(key):
#       count.inc
#   if count == 0:
#     self.putValidate("oneOf", &"at least one of {keys} is required")


# func password*(self: var RequestValidation, key = "password") =
#   var error = newJArray()
#   if self.params.getStr(key).len == 0:
#     error.add(%"this field is required")

#   if self.params.getStr(key).len < 8:
#     error.add(%"password needs at least 8 chars")

#   if not self.params.getStr(key).match(re"(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[!-~a-zA-Z\d]*"):
#     error.add(%"invalid form of password")

#   if error.len > 0:
#     self.putValidate(key, error)


# func required*(self: var RequestValidation, keys: openArray[string]) =
#   for key in keys:
#     if not self.params.hasKey(key) or self.params.getStr(key).len == 0:
#       self.putValidate(key, &"{key} is required")


# proc unique*(self: var RequestValidation, key: string, table: string,
#     column: string) =
#   if self.params.hasKey(key):
#     let val = self.params.getStr(key)
#     let num = RDB().table(table).where(column, "=", val).count()
#     if num > 0:
#       self.putValidate(key, &"{key} should be unique")
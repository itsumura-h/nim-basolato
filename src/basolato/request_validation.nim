import
  asynchttpserver,
  os,
  json,
  re,
  tables,
  strformat,
  strutils,
  unicode
include core/validation
import core/request
import core/logger

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
  "url": "The :attribute format is invalid.",
  "uuid": "The :attribute must be a valid UUID.",
}
discard """
Laravel validation impl
http://github.com/illuminate/validation/blob/master/Concerns/ValidatesAttributes.php

Laravel validation message difinition
https://github.com/laravel/laravel/blob/7.x/resources/lang/en/validation.php

changed item in message
delete: active_url, bail, date_format, dimensions, exclude_if, exclude_unless, 
  exists, ip, ipv4, ipv6, mimetypes, string, timezone, unique, uploaded
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
      let value = self.params.getStr(key).split(",")
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
    if not same(a, b):
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
    let values = self.params.getStr(key).split(",")
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

proc endsWith*(self:RequestValidation, key, expect:string) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not endsWith(value, expect):
      let message = messages["ends_with"].getStr
        .replace(":attribute", key)
        .replace(":values", expect)
      self.add(key, message)

proc file*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    let ext = self.params[key].ext
    if not file(value, ext):
      let message = messages["file"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc filled*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not filled(value):
      let message = messages["filled"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc gtNum*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let a = self.params.getStr(key).parseBiggestInt
    let b = self.params.getStr(target).parseBiggestInt
    if not gt(a, b):
      let message = messages["gt"]["numeric"].getStr
        .replace(":attribute", key)
        .replace(":value", target)
      self.add(key, message)

proc gtFile*(self:RequestValidation, key, target:string) =
  try:
    if self.params.hasKey(key) and self.params.hasKey(target):
      let a = self.params.getStr(key)
      let b = self.params.getStr(target)
      if not gt(a, b):
        let message = messages["gt"]["file"].getStr
          .replace(":attribute", key)
          .replace(":value", $(b.len / 1024))
        self.add(key, message)
  except:
    echoErrorMsg( getCurrentExceptionMsg() )

proc gtStr*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let a = self.params.getStr(key)
    let b = self.params.getStr(target)
    if not gt(a, b):
      let message = messages["gt"]["string"].getStr
        .replace(":attribute", key)
        .replace(":value", target)
      self.add(key, message)

proc gtArr*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let a = self.params.getStr(key).split(",")
    let b = self.params.getStr(target).split(",")
    if not gt(a, b):
      let message = messages["gt"]["array"].getStr
        .replace(":attribute", key)
        .replace(":value", target)
      self.add(key, message)

proc gteNum*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let a = self.params.getStr(key).parseBiggestInt
    let b = self.params.getStr(target).parseBiggestInt
    if not gte(a, b):
      let message = messages["gte"]["numeric"].getStr
        .replace(":attribute", key)
        .replace(":value", target)
      self.add(key, message)

proc gteFile*(self:RequestValidation, key, target:string) =
  try:
    if self.params.hasKey(key) and self.params.hasKey(target):
      let a = self.params.getStr(key)
      let b = self.params.getStr(target)
      if not gte(a, b):
        let message = messages["gte"]["file"].getStr
          .replace(":attribute", key)
          .replace(":value", $(b.len div 1024))
        self.add(key, message)
  except:
    echoErrorMsg( getCurrentExceptionMsg() )

proc gteStr*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let a = self.params.getStr(key)
    let b = self.params.getStr(target)
    if not gte(a, b):
      let message = messages["gte"]["string"].getStr
        .replace(":attribute", key)
        .replace(":value", target)
      self.add(key, message)

proc gteArr*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let a = self.params.getStr(key).split(",")
    let b = self.params.getStr(target).split(",")
    if not gte(a, b):
      let message = messages["gte"]["array"].getStr
        .replace(":attribute", key)
        .replace(":value", target)
      self.add(key, message)

proc image*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    let ext = self.params[key].ext
    if not image(ext):
      let message = messages["image"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc `in`*(self:RequestValidation, key:string, list:openArray[string]) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not `in`(value, list):
      let message = messages["in"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc inArray*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let value = self.params.getStr(key)
    let list = self.params.getStr(target).split(",")
    if not `in`(value, list):
      let message = messages["in_array"].getStr
        .replace(":attribute", key)
        .replace(":other", target)
      self.add(key, message)

proc integer*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not integer(value):
      let message = messages["integer"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc json*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not json(value):
      let message = messages["json"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc ltNum*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let a = self.params.getStr(key).parseBiggestInt
    let b = self.params.getStr(target).parseBiggestInt
    if not lt(a, b):
      let message = messages["lt"]["numeric"].getStr
        .replace(":attribute", key)
        .replace(":value", target)
      self.add(key, message)

proc ltFile*(self:RequestValidation, key, target:string) =
  try:
    if self.params.hasKey(key) and self.params.hasKey(target):
      let a = self.params.getStr(key)
      let b = self.params.getStr(target)
      if not lt(a, b):
        let message = messages["lt"]["file"].getStr
          .replace(":attribute", key)
          .replace(":value", $(b.len / 1024))
        self.add(key, message)
  except:
    echoErrorMsg( getCurrentExceptionMsg() )

proc ltStr*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let a = self.params.getStr(key)
    let b = self.params.getStr(target)
    if not lt(a, b):
      let message = messages["lt"]["string"].getStr
        .replace(":attribute", key)
        .replace(":value", target)
      self.add(key, message)

proc ltArr*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let a = self.params.getStr(key).split(",")
    let b = self.params.getStr(target).split(",")
    if not lt(a, b):
      let message = messages["lt"]["array"].getStr
        .replace(":attribute", key)
        .replace(":value", target)
      self.add(key, message)

proc lteNum*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let a = self.params.getStr(key).parseBiggestInt
    let b = self.params.getStr(target).parseBiggestInt
    if not lte(a, b):
      let message = messages["lte"]["numeric"].getStr
        .replace(":attribute", key)
        .replace(":value", target)
      self.add(key, message)

proc lteFile*(self:RequestValidation, key, target:string) =
  try:
    if self.params.hasKey(key) and self.params.hasKey(target):
      let a = self.params.getStr(key)
      let b = self.params.getStr(target)
      if not lte(a, b):
        let message = messages["lte"]["file"].getStr
          .replace(":attribute", key)
          .replace(":value", $(b.len div 1024))
        self.add(key, message)
  except:
    echoErrorMsg( getCurrentExceptionMsg() )

proc lteStr*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let a = self.params.getStr(key)
    let b = self.params.getStr(target)
    if not lte(a, b):
      let message = messages["lte"]["string"].getStr
        .replace(":attribute", key)
        .replace(":value", target)
      self.add(key, message)

proc lteArr*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let a = self.params.getStr(key).split(",")
    let b = self.params.getStr(target).split(",")
    if not lte(a, b):
      let message = messages["lte"]["array"].getStr
        .replace(":attribute", key)
        .replace(":value", target)
      self.add(key, message)

proc maxNum*(self:RequestValidation, key:string, maximum:int) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key).parseBiggestInt
    if not maxValidate(value, maximum):
      let message = messages["max"]["numeric"].getStr
        .replace(":attribute", key)
        .replace(":max", $maximum)
      self.add(key, message)

proc maxFile*(self:RequestValidation, key:string, maximum:int) =
  try:
    if self.params.hasKey(key):
      let value = self.params.getStr(key)
      if not maxFileValidate(value, maximum):
        let message = messages["max"]["file"].getStr
          .replace(":attribute", key)
          .replace(":max", $maximum)
        self.add(key, message)
  except:
    echoErrorMsg( getCurrentExceptionMsg() )

proc maxStr*(self:RequestValidation, key:string, maximum:int) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not maxValidate(value, maximum):
      let message = messages["max"]["string"].getStr
        .replace(":attribute", key)
        .replace(":max", $maximum)
      self.add(key, message)

proc maxArr*(self:RequestValidation, key:string, maximum:int) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key).split(",")
    if not maxValidate(value, maximum):
      let message = messages["max"]["array"].getStr
        .replace(":attribute", key)
        .replace(":max", $maximum)
      self.add(key, message)

proc mimes*(self:RequestValidation, key:string, types:openArray[string]) =
  if self.params.hasKey(key):
    let ext = self.params[key].ext
    if not mimes(ext, types):
      let message = messages["mimes"].getStr
        .replace(":attribute", key)
        .replace(":values", $types)
      self.add(key, message)

proc minNum*(self:RequestValidation, key:string, minimum:int) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key).parseBiggestInt
    if not minValidate(value, minimum):
      let message = messages["min"]["numeric"].getStr
        .replace(":attribute", key)
        .replace(":min", $minimum)
      self.add(key, message)

proc minFile*(self:RequestValidation, key:string, minimum:int) =
  try:
    if self.params.hasKey(key):
      let value = self.params.getStr(key)
      if not minFileValidate(value, minimum):
        let message = messages["min"]["file"].getStr
          .replace(":attribute", key)
          .replace(":min", $minimum)
        self.add(key, message)
  except:
    echoErrorMsg( getCurrentExceptionMsg() )

proc minStr*(self:RequestValidation, key:string, minimum:int) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not minValidate(value, minimum):
      let message = messages["min"]["string"].getStr
        .replace(":attribute", key)
        .replace(":min", $minimum)
      self.add(key, message)

proc minArr*(self:RequestValidation, key:string, minimum:int) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key).split(",")
    if not minValidate(value, minimum):
      let message = messages["min"]["array"].getStr
        .replace(":attribute", key)
        .replace(":min", $minimum)
      self.add(key, message)

proc `notIn`*(self:RequestValidation, key:string, list:openArray[string]) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not `notIn`(value, list):
      let message = messages["in"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc notRegex*(self:RequestValidation, key:string, reg:Regex) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not notRegex(value, reg):
      let message = messages["not_regex"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc numeric*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not numeric(value):
      let message = messages["numeric"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc present*(self:RequestValidation, key:string) =
  if not self.params.hasKey(key):
    let message = messages["present"].getStr
      .replace(":attribute", key)
    self.add(key, message)

proc regex*(self:RequestValidation, key:string, reg:Regex) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not regex(value, reg):
      let message = messages["regex"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc required*(self:RequestValidation, key:string) =
  if not self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not required(value):
      let message = messages["required"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc requiredIf*(self:RequestValidation, key, other:string, values:openArray[string]) =
  if self.params.hasKey(other):
    let otherValue = self.params.getStr(other)
    for val in values:
      if val == otherValue:
        if (not self.params.hasKey(key)) or (not required(self.params.getStr(key))):
          let message = messages["required_if"].getStr
            .replace(":attribute", key)
            .replace(":other", other)
            .replace(":value", val)
          self.add(key, message)
          break

proc requiredUnless*(self:RequestValidation, key, other:string, values:openArray[string]) =
  if self.params.hasKey(other):
    let otherValue = self.params.getStr(other)
    if not values.contains(otherValue):
      if (not self.params.hasKey(key)) or (not required(self.params.getStr(key))):
        let message = messages["required_unless"].getStr
          .replace(":attribute", key)
          .replace(":other", other)
          .replace(":values", $values)
        self.add(key, message)

proc requiredWith*(self:RequestValidation, key:string, others:openArray[string]) =
  for other in others:
    if self.params.hasKey(other):
      if (not self.params.hasKey(key)) or (not required(self.params.getStr(key))):
        let message = messages["required_with"].getStr
          .replace(":attribute", key)
          .replace(":other", other)
          .replace(":values", $others)
        self.add(key, message)
        break

proc requiredWithAll*(self:RequestValidation, key:string, others:openArray[string]) =
  var isExists = true
  for other in others:
    if not self.params.hasKey(other):
      isExists = false
      break
  if isExists:
    if (not self.params.hasKey(key)) or (not required(self.params.getStr(key))):
      let message = messages["required_with_all"].getStr
        .replace(":attribute", key)
        .replace(":values", $others)
      self.add(key, message)

proc requiredWithout*(self:RequestValidation, key:string, others:openArray[string]) =
  var isExists = false
  for other in others:
    if not self.params.hasKey(other):
      isExists = true
      break
  if isExists:
    if (not self.params.hasKey(key)) or (not required(self.params.getStr(key))):
      let message = messages["required_without"].getStr
        .replace(":attribute", key)
        .replace(":values", $others)
      self.add(key, message)

proc requiredWithoutAll*(self:RequestValidation, key:string, others:openArray[string]) =
  var isExists = false
  for other in others:
    if self.params.hasKey(other):
      isExists = true
      break
  if not isExists:
    if (not self.params.hasKey(key)) or (not required(self.params.getStr(key))):
      let message = messages["required_without_all"].getStr
        .replace(":attribute", key)
        .replace(":values", $others)
      self.add(key, message)

proc same*(self:RequestValidation, key, target:string) =
  if self.params.hasKey(key) and self.params.hasKey(target):
    let a = self.params.getStr(key)
    let b = self.params.getStr(target)
    if not same(a, b):
      let message = messages["same"].getStr
        .replace(":attribute", key)
        .replace(":other", target)
      self.add(key, message)

proc sizeNum*(self:RequestValidation, key:string, standard:int) =
  if self.params.hasKey(key):
    let value = self.params.getInt(key)
    if not size(value, standard):
      let message = messages["size"]["numeric"].getStr
        .replace(":attribute", key)
        .replace(":size", $standard)
      self.add(key, message)

proc sizeFile*(self:RequestValidation, key:string, standard:int) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not sizeFile(value, standard):
      let message = messages["size"]["file"].getStr
        .replace(":attribute", key)
        .replace(":size", $standard)
      self.add(key, message)

proc sizeStr*(self:RequestValidation, key:string, standard:int) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not size(value, standard):
      let message = messages["size"]["string"].getStr
        .replace(":attribute", key)
        .replace(":size", $standard)
      self.add(key, message)

proc sizeArr*(self:RequestValidation, key:string, standard:int) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key).split(",")
    if not size(value, standard):
      let message = messages["size"]["array"].getStr
        .replace(":attribute", key)
        .replace(":size", $standard)
      self.add(key, message)


proc startsWith*(self:RequestValidation, key:string, targets:openArray[string]) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not startsWith(value, targets):
      let message = messages["starts_with"].getStr
        .replace(":attribute", key)
        .replace(":values", $targets)
      self.add(key, message)

proc url*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not url(value):
      let message = messages["url"].getStr
        .replace(":attribute", key)
      self.add(key, message)

proc uuid*(self:RequestValidation, key:string) =
  if self.params.hasKey(key):
    let value = self.params.getStr(key)
    if not uuid(value):
      let message = messages["uuid"].getStr
        .replace(":attribute", key)
      self.add(key, message)

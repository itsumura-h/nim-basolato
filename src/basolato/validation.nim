import json, re, tables, strformat, strutils
from jester import Request, params
import allographer/query_builder


type 
  Validation* = ref object
    params*: Table[string, string]
    errors*: JsonNode # JObject


proc validate*(request:Request): Validation =
  Validation(
    params: request.params,
    errors: newJObject()
  )


proc putValidate*(this:Validation, key:string, error:JsonNode) =
  if isNil(this.errors):
    this.errors = %{key: error}
  else:
    this.errors[key] = error
    
proc putValidate*(this:Validation, key:string, msg:string) =
  if isNil(this.errors):
    this.errors = %*{key: [msg]}
  elif this.errors.hasKey(key):
    this.errors[key].add(%(msg))
  else:
    this.errors[key] = %[(msg)]

proc password*(this:Validation, key="password"): Validation =
  var error = newJArray()
  
  if this.params[key].len == 0:
    error.add(%"this field is required.")

  if this.params[key].len < 8:
    error.add(%"password needs at least 8 chars")
  
  if not this.params[key].match(re"^(?=.*?[a-z])(?=.*?\d)[a-z\d]*$"):
    error.add(%"invalid form of password")
  
  if error.len > 0:
    this.putValidate(key, error)
  
  return this

proc email*(this:Validation, key="email"): Validation =
  var error = newJArray()

  if this.params[key].len == 0:
    error.add(%"this field is required.")

  if not this.params[key].match(re"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[?:\.a-zA-Z0-9]*$"):
    error.add(%"invalid form of email")
  
  if error.len > 0:
    this.putValidate(key, error)

  return this

proc required*(this:Validation, keys:openArray[string]): Validation =
  for key in keys:
    if this.params[key].len == 0:
      this.putValidate(key, &"{key} is required")
  return this

proc accepted*(this:Validation, key:string, val="on"): Validation =
  if this.params.hasKey(key):
    if this.params[key] != val:
      this.putValidate(key, &"{key} should be accespted")
  return this

proc contains*(this:Validation, key:string, val:string): Validation =
  if this.params.hasKey(key):
    if not this.params[key].contains(val):
      this.putValidate(key, &"{key} should contain {val}")
  return this

proc equals*(this:Validation, key:string, val:string): Validation =
  if this.params.hasKey(key):
    if this.params[key] != val:
      this.putValidate(key, &"{key} should be {val}")
  return this

proc exists*(this:Validation, key:string): Validation =
  if not this.params.hasKey(key):
    this.putValidate(key, &"{key} should exists in request params")
  return this

proc gratorThan*(this:Validation, key:string, val:float): Validation =
  if this.params.hasKey(key):
    if this.params[key].parseFloat <= val:
      this.putValidate(key, &"{key} should be grator than {val}")
  return this

proc inRange*(this:Validation, key:string, min:float, max:float): Validation =
  if this.params.hasKey(key):
    let val = this.params[key].parseFloat
    if val < min or max < val:
      this.putValidate(key, &"{key} should be in range between {min} and {max}")
  return this

proc ip*(this:Validation, key:string): Validation =
  if this.params.hasKey(key):
    if not this.params[key].match(re"[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"):
      this.putValidate(key, &"{key} should be a form of IP address")
  return this

proc isIn*(this:Validation, key:string, vals:openArray[int|float|string]): Validation =
  if this.params.hasKey(key):
    var count = 0
    for val in vals:
      if this.params[key] == $val:
        count.inc
    if count == 0:
      this.putValidate(key, &"{key} should be in {vals}")
  return this

proc lessThan*(this:Validation, key:string, val:float): Validation =
  if this.params.hasKey(key):
    if this.params[key].parseFloat >= val:
      this.putValidate(key, &"{key} should be less than {val}")
  return this

proc numeric*(this:Validation, key:string): Validation =
  if this.params.hasKey(key):
    try:
      let _ = this.params[key].parseFloat
    except:
      this.putValidate(key, &"{key} should be numeric")
  return this

proc oneOf*(this:Validation, keys:openArray[string]): Validation =
  var count = 0
  for key, val in this.params:
    if keys.contains(key):
      count.inc
  if count == 0:
    this.putValidate("oneOf", &"at least one of {keys} is required")
  return this

proc unique*(this:Validation, key:string, table:string, column:string): Validation =
  if this.params.hasKey(key):
    let val = this.params[key]
    let num = RDB().table(table).where(column, "=", val).count()
    if num != 0:
      this.putValidate(key, &"{key} should be unique")
  return this

when isMainModule:
  type Request = ref object
    params: Table[string, string]

  var params = {
    "password": "asdwe",
    "email": "user1@gmail.com",
    "required": "",
    "accepted": "",
    "contains": "jester app",
    "equals": "24",
    "gratorThan": "24",
    "inRange9": "9",
    "inRange10": "10",
    "inRange13": "13",
    "ip": "1232.123.123.123",
    "isIn": "3",
    "lessThan": "26",
    "numeric": "a",
    "oneOf": "a",
  }.toTable

  let request = Request(params:params)
  
  let v = request.validate()
            .password()
            .email()
            .required(["required"])
            .accepted("accepted")
            .contains("contains", "basolato")
            .equals("equals", "25")
            .exists("aa")
            .gratorThan("gratorThan", 25)
            .inRange("inRange9", min=10, max=12)
            .inRange("inRange10", min=10, max=12)
            .inRange("inRange13", min=10, max=12)
            .ip("ip")
            .isIn("isIn", [1, 2, 4])
            .lessThan("lessThan", 25)
            .numeric("numeric")
            .oneOf(["oneOf1", "oneOf2"])
            .unique("email", "users", "email")
  echo v.errors

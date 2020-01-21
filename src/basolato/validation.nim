import json, re, tables, strformat

type 
  Validation* = ref object
    params*: Table[string, string]
    errors*: JsonNode # JObject

  Request = ref object
    params*: Table[string, string]

proc validate*(request:Request): Validation =
  Validation(
    params: request.params,
    errors: newJObject()
  )


proc putError(this:Validation, key:string, error:JsonNode) =
  if isNil(this.errors):
    this.errors = %{key: error}
  else:
    this.errors[key] = error


proc password*(this:Validation, key="password"): Validation =
  var error = newJArray()
  
  if this.params[key].len == 0:
    error.add(%"this field is required.")

  if this.params[key].len < 8:
    error.add(%"password needs at least 8 chars")
  
  if not this.params[key].match(re"^(?=.*?[a-z])(?=.*?\d)[a-z\d]*$"):
    error.add(%"invalid form of password")
  
  if error.len > 0:
    this.putError(key, error)
  
  return this

proc email*(this:Validation, key="email"): Validation =
  var error = newJArray()

  if this.params[key].len == 0:
    error.add(%"this field is required.")

  if not this.params[key].match(re"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$"):
    error.add(%"invalid form of email")
  
  if error.len > 0:
    this.putError(key, error)

  return this

proc required*(this:Validation, keys:openArray[string]): Validation =
  for key in keys:
    if this.params[key].len == 0:
      if isNil(this.errors):
        this.errors = %*{key: [&"{key} is required"]}
      elif this.errors.hasKey(key):
        this.errors[key].add(%(&"{key} is required"))
      else:
        this.errors[key] = %[(&"{key} is required")]
  return this

when isMainModule:
  var params = {"password": "", "email": "user1gmai"}.toTable
  let request = Request(params:params)
  
  let v = request.validate()
            .password()
            .email()
            .required(["password"])
  echo v.errors
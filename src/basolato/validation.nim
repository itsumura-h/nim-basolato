import json, re, tables

type 
  Validation* = ref object
    params*: Table[string, string]
    errors*: JsonNode

  Request = ref object
    params*: Table[string, string]

proc varidate*(request:Request): Validation =
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
  var error = newseq[JsonNode]()
  
  if this.params[key].len == 0:
    error.add(%"this field is required.")

  if this.params[key].len < 8:
    error.add(%"password needs at least 8 chars")
  
  if not this.params[key].match(re"^(?=.*?[a-z])(?=.*?\d)[a-z\d]*$"):
    error.add(%"invalid form of password")
  
  if error.len > 0:
    this.putError(key, error)
  
  return this

proc email*(this:Validation, val:string, key="email"): Validation =
  var error = %*{"val": val, "errors": []}

  if val.len == 0:
    error["isError"] = %true
    error["errors"].add(%"this field is required.")

  if not val.match(re"^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$"):
    error["isError"] = %true
    error["errors"].add(%"invalid form of email")
  
  if error["isError"].getBool:
    this.putError(key, error)

  return this

proc required*(this:Validation, vals:openArray[string]): Validation =
  for val in vals:
    var error = %*{"val": val, "errors": []}
    echo val.repr
    # if val.len == 0:
    #   error["errors"].add(%(&"{val} is required"))
    #   this.putError(val)


when isMainModule:
  

  var params = {"password": "asdas", "email": "user1gmai", "name": ""}.toTable
  let request = Request(params:params)
  
  let v = validate()
            .password("password", "asdasda9")
            .email("email", "user1@gmail.com")
            .required([aaa, bbb, ""])
  echo v.errors
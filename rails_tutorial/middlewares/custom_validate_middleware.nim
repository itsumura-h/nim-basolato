import tables, strutils, strformat
import ../../src/basolato/request_validation


proc filled*(this:RequestValidation, args:openArray[string]):RequestValidation =
  for key in args:
    let val = this.params[key]
    if val.len == 0 or val.isNilOrWhitespace():
      this.putValidate(key, &"{key} cannot be blank") 
  return this

proc length*(this:RequestValidation, key:string, min, max:int):RequestValidation =
  let params = this.params
  if params[key].len < min or max < params[key].len:
    this.putValidate(key, &"{key}'s length shoud between {min} and {max}")
  return this

proc equalInput*(this:RequestValidation, key1, key2:string):RequestValidation =
  let params = this.params
  if params[key1] != params[key2]:
    this.putValidate(key1, "password is not match")
  return this

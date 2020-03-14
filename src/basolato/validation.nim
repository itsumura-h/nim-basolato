import json, re, tables, strformat, strutils, unicode
from net import isIpAddress
from jester import Request, params
import allographer/query_builder


type
  Validation* = ref object
    params*: Table[string, string]
    errors*: JsonNode # JObject


proc validate*(request: Request): Validation =
  Validation(
    params: request.params,
    errors: newJObject()
  )


proc putValidate*(this: Validation, key: string, error: JsonNode) =
  if isNil(this.errors):
    this.errors = %{key: error}
  else:
    this.errors[key] = error

proc putValidate*(this: Validation, key: string, msg: string) =
  if isNil(this.errors):
    this.errors = %*{key: [msg]}
  elif this.errors.hasKey(key):
    this.errors[key].add(%(msg))
  else:
    this.errors[key] = %[(msg)]

# =============================================================================

proc accepted*(this: Validation, key: string, val = "on"): Validation =
  if this.params.hasKey(key):
    if this.params[key] != val:
      this.putValidate(key, &"{key} should be accespted")
  return this

proc contains*(this: Validation, key: string, val: string): Validation =
  if this.params.hasKey(key):
    if not this.params[key].contains(val):
      this.putValidate(key, &"{key} should contain {val}")
  return this

proc email*(this: Validation, key = "email"): Validation =
  var error = newJArray()
  if this.params[key].len == 0:
    error.add(%"this field is required")
  if not this.params[key].match(re"\A[\w+\-.]+@[a-zA-Z\d\-]+(\.[a-zA-Z\d\-]+)*\.[a-zA-Z]+\Z"):
    error.add(%"invalid form of email")
  if error.len > 0:
    this.putValidate(key, error)
  return this

proc validateDomain(domain:string) =
  block:
    let fqdn = re"^(([a-z0-9]{1,2}|[a-z0-9][a-z0-9-]{0,61}[a-z0-9])\.)*([a-z0-9]{1,2}|[a-z0-9][a-z0-9-]{0,61}?[a-z0-9])$"
    let addr4 = re"(([01]?[0-9]{1,2}|2(?:[0-4]?[0-9]|5[0-5]))\.){3}([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))"
    let addr4Start = re"^(([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))\.){3}([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))$"
    if domain.len == 0 or domain.len > 255:
      raise newException(Exception, "domain length is 0")
    if not domain.startsWith("["):
      if not (not domain.match(addr4) and domain.match(fqdn)):
        raise newException(Exception, "invalid domain format")
        # return false
      elif domain.find(re"\.[0-9]$|^[0-9]+$") > -1:
        raise newException(Exception, "the last label of domain should not number")
      else:
        break
    if not domain.endsWith("]"):
      raise newException(Exception, "domain lacks ']'")
    var domain = domain
    domain.removePrefix("[")
    domain.removeSuffix("]")
    if domain.match(addr4Start):
      if domain != "0.0.0.0":
        break
      else:
        raise newException(Exception, "domain 0.0.0.0 is invalid")
    if domain.endsWith("::"):
      raise newException(Exception, "IPv6 should not end with '::'")
    var v4_flg = false
    var last = ""
    try:
      last = domain.rsplit(":", maxsplit=1)[^1]
    except:
      raise newException(Exception, "invalid domain")
    if last.match(addr4):
      if domain == "0.0.0.0":
        raise newException(Exception, "domain 0.0.0.0 is invalid")
      domain = domain.replace(last, "0:0")
      v4_flg = true
    var oc:int
    if domain.contains("::"):
      oc = 8 - domain.count(":")
      if oc < 1:
        raise newException(Exception, "8 blocks is required for IPv6")
      var ocStr = "0:"
      domain = domain.replace("::", &":{ocStr.repeat(oc)}")
      if domain.startsWith(":"):
        domain = &"0{domain}"
      if domain.endsWith(":"):
        domain = &"{domain}0"
    var elems = domain.split(":")
    if elems.len != 8:
      raise newException(Exception, "invalid IP address")
    var res = 0
    for i, a in elems:
      if a.len > 4:
        raise newException(Exception, "each blick of IP address should be shorter than 4")
      try:
        res += a.parseHexInt shl ((7 - i) * 16)
      except:
        raise newException(Exception, "invalid IPv6 address")
    if not (res != 0 and (not v4_flg or res shr 32 == 0xffff)):
      raise newException(Exception, "invalid IPv4-Mapped IPv6 address")

proc strictEmail*(this: Validation, key = "email"): Validation =
  var error = newJArray()
  var email = this.params[key]
  try:
    let valid = "abcdefghijklmnopqrstuvwxyz1234567890!#$%&\'*+-/=?^_`{}|~"
    if email.len == 0:
      raise newException(Exception, "invalid email format 1")
    email = email.toLowerAscii()
    if not email.contains("@"):
      raise newException(Exception, "email should have '@'")
    var i:int
    if email.startsWith("\""):
      i = 1
      while i < min(64, email.len):
        if (valid & "()<>[]:;@,. ").contains(email[i]):
          i.inc()
          continue
        if $email[i] == "\\":
          if email[i+1..^1].len > 0 and (valid & """()<>[]:;@,.\\" """).contains($email[i+1]):
            i.inc(2)
            continue
          raise newException(Exception, "invalid email format 2")
        if email[i] == '"':
          break
      if i == 64:
        i.dec()
      if not (email[i+1..^1].len > 0 and $email[i+1] == "@"):
        raise newException(Exception, "invalid email local-part")
      validateDomain(email[i+2..^1])
    else:
      i = 0
      while i < min(64, email.len):
        if valid.contains(email[i]):
          i.inc()
          continue
        if $email[i] == ".":
          if i == 0 or email[i+1..^1].len == 0 or ".@".contains(email[i+1]):
            raise newException(Exception, "invalid email local-part")
          i.inc()
          continue
        if $email[i] == "@":
          if i == 0:
            raise newException(Exception, "email has no local-part")
          i.dec()
          break
        raise newException(Exception, "email includes invalid char")
      if i == 64:
        i.dec
      if not (email[i+1..^1].len > 0 and "@".contains(email[i+1])):
        raise newException(Exception, "email local-part should be shorter than 64")
      validateDomain(email[i+2..^1])
  except:
    error.add(%(getCurrentExceptionMsg()))

  if error.len > 0:
    # debugEcho email
    # debugEcho error
    this.putValidate(key, error)
  else:
    # debugEcho email
    discard
  return this

proc equals*(this: Validation, key: string, val: string): Validation =
  if this.params.hasKey(key):
    if this.params[key] != val:
      this.putValidate(key, &"{key} should be {val}")
  return this

proc exists*(this: Validation, key: string): Validation =
  if not this.params.hasKey(key):
    this.putValidate(key, &"{key} should exists in request params")
  return this

proc gratorThan*(this: Validation, key: string, val: float): Validation =
  if this.params.hasKey(key):
    if this.params[key].parseFloat <= val:
      this.putValidate(key, &"{key} should be grator than {val}")
  return this

proc inRange*(this: Validation, key: string, min: float,
    max: float): Validation =
  if this.params.hasKey(key):
    let val = this.params[key].parseFloat
    if val < min or max < val:
      this.putValidate(key, &"{key} should be in range between {min} and {max}")
  return this

proc ip*(this: Validation, key: string): Validation =
  if this.params.hasKey(key):
    if not this.params[key].match(re"[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"):
      this.putValidate(key, &"{key} should be a form of IP address")
  return this

proc isIn*(this: Validation, key: string, vals: openArray[
    int|float|string]): Validation =
  if this.params.hasKey(key):
    var count = 0
    for val in vals:
      if this.params[key] == $val:
        count.inc
    if count == 0:
      this.putValidate(key, &"{key} should be in {vals}")
  return this

proc lessThan*(this: Validation, key: string, val: float): Validation =
  if this.params.hasKey(key):
    if this.params[key].parseFloat >= val:
      this.putValidate(key, &"{key} should be less than {val}")
  return this

proc numeric*(this: Validation, key: string): Validation =
  if this.params.hasKey(key):
    try:
      let _ = this.params[key].parseFloat
    except:
      this.putValidate(key, &"{key} should be numeric")
  return this

proc oneOf*(this: Validation, keys: openArray[string]): Validation =
  var count = 0
  for key, val in this.params:
    if keys.contains(key):
      count.inc
  if count == 0:
    this.putValidate("oneOf", &"at least one of {keys} is required")
  return this

proc password*(this: Validation, key = "password"): Validation =
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

proc required*(this: Validation, keys: openArray[string]): Validation =
  for key in keys:
    if not this.params.hasKey(key) or this.params[key].len == 0:
      this.putValidate(key, &"{key} is required")
  return this

proc unique*(this: Validation, key: string, table: string,
    column: string): Validation =
  if this.params.hasKey(key):
    let val = this.params[key]
    let num = RDB().table(table).where(column, "=", val).count()
    if num > 0:
      this.putValidate(key, &"{key} should be unique")
  return this

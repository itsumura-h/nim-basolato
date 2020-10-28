import json, re, tables, strformat, strutils, unicode

type Validation* = ref object


proc digits(value:string, digit:int):seq[string] =
  var r = newSeq[string]()
  if value.len > digit:
    r.add(&"the number of digits in {value} should less than {digit}")
  return r

proc digits*(this:Validation, value:string, digit:int):bool =
  if digits(value, digit).len > 0:
    return false
  else:
    return true

proc email(value:string):seq[string] =
  var r = newSeq[string]()
  if value.len == 0:
    r.add("this field is required")
  if not value.match(re"\A[\w+\-.]+@[a-zA-Z\d\-]+(\.[a-zA-Z\d\-]+)*\.[a-zA-Z]+\Z"):
    r.add("invalid form of email")
  return r

proc email*(this:Validation, value:string):bool =
  if email(value).len > 0:
    return false
  else:
    return true

proc domain(value:string):seq[string] =
  var r = newSeq[string]()
  try:
    block:
      let fqdn = re"^(([a-z0-9]{1,2}|[a-z0-9][a-z0-9-]{0,61}[a-z0-9])\.)*([a-z0-9]{1,2}|[a-z0-9][a-z0-9-]{0,61}?[a-z0-9])$"
      let addr4 = re"(([01]?[0-9]{1,2}|2(?:[0-4]?[0-9]|5[0-5]))\.){3}([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))"
      let addr4Start = re"^(([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))\.){3}([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))$"
      if value.len == 0 or value.len > 255:
        raise newException(Exception, "domain length is 0")
      if not value.startsWith("["):
        if not (not value.match(addr4) and value.match(fqdn)):
          raise newException(Exception, "invalid domain format")
        elif value.find(re"\.[0-9]$|^[0-9]+$") > -1:
          raise newException(Exception, "the last label of domain should not number")
        else:
          break
      if not value.endsWith("]"):
        raise newException(Exception, "domain lacks ']'")
      var value = value
      value.removePrefix("[")
      value.removeSuffix("]")
      if value.match(addr4Start):
        if value != "0.0.0.0":
          break
        else:
          raise newException(Exception, "domain 0.0.0.0 is invalid")
      if value.endsWith("::"):
        raise newException(Exception, "IPv6 should not end with '::'")
      var v4_flg = false
      var last = ""
      try:
        last = value.rsplit(":", maxsplit=1)[^1]
      except:
        raise newException(Exception, "invalid domain")
      if last.match(addr4):
        if value == "0.0.0.0":
          raise newException(Exception, "domain 0.0.0.0 is invalid")
        value = value.replace(last, "0:0")
        v4_flg = true
      var oc:int
      if value.contains("::"):
        oc = 8 - value.count(":")
        if oc < 1:
          raise newException(Exception, "8 blocks is required for IPv6")
        var ocStr = "0:"
        value = value.replace("::", &":{ocStr.repeat(oc)}")
        if value.startsWith(":"):
          value = &"0{value}"
        if value.endsWith(":"):
          value = &"{value}0"
      var elems = value.split(":")
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
  except:
    r.add(getCurrentExceptionMsg())
  return r

proc domain*(this:Validation, value:string):bool =
  if domain(value).len > 0:
    return false
  else:
    return true

proc validateDomain(value:string) =
  let r = domain(value)
  if r.len > 0:
    raise newException(Exception, r[0])

proc strictEmail(value:string):seq[string] =
  var r = newSeq[string]()
  var value = value
  try:
    let valid = "abcdefghijklmnopqrstuvwxyz1234567890!#$%&\'*+-/=?^_`{}|~"
    if value.len == 0:
      raise newException(Exception, "email is empty")
    value = value.toLowerAscii()
    if not value.contains("@"):
      raise newException(Exception, "email should have '@'")
    var i:int
    if value.startsWith("\""):
      i = 1
      while i < min(64, value.len):
        if (valid & "()<>[]:;@,. ").contains(value[i]):
          i.inc()
          continue
        if $value[i] == "\\":
          if value[i+1..^1].len > 0 and (valid & """()<>[]:;@,.\\" """).contains($value[i+1]):
            i.inc(2)
            continue
          raise newException(Exception, "invalid email format")
        if value[i] == '"':
          break
      if i == 64:
        i.dec()
      if not (value[i+1..^1].len > 0 and $value[i+1] == "@"):
        raise newException(Exception, "invalid email local-part")
      validateDomain(value[i+2..^1])
    else:
      i = 0
      while i < min(64, value.len):
        if valid.contains(value[i]):
          i.inc()
          continue
        if $value[i] == ".":
          if i == 0 or value[i+1..^1].len == 0 or ".@".contains(value[i+1]):
            raise newException(Exception, "invalid email local-part")
          i.inc()
          continue
        if $value[i] == "@":
          if i == 0:
            raise newException(Exception, "email has no local-part")
          i.dec()
          break
        raise newException(Exception, "email includes invalid char")
      if i == 64:
        i.dec
      if not (value[i+1..^1].len > 0 and "@".contains(value[i+1])):
        raise newException(Exception, "email local-part should be shorter than 64")
      validateDomain(value[i+2..^1])
  except:
    r.add(getCurrentExceptionMsg())
  return r

proc strictEmail*(this:Validation, value:string):bool =
  if strictEmail(value).len > 0:
    return false
  else:
    return true

proc equals(sub:any, target:any):seq[string] =
  var r = newSeq[string]()
  if sub != target:
    r.add(&"{$sub} should be {$target}")
  return r

proc equals*(this:Validation, sub:any, target:any):bool =
  if equals(sub, target).len > 0:
    return false
  else:
    return true

proc gratorThan(sub, target:int|float):seq[string] =
  var r = newSeq[string]()
  if sub <= target:
    r.add(&"{$sub} should be grator than {$target}")
  return r

proc gratorThan*(this:Validation, sub, target:int|float):bool =
  if gratorThan(sub, target).len > 0:
    return false
  else:
    return true

proc inRange(value, min, max:int|float):seq[string] =
  var r = newSeq[string]()
  block:
    if value < min or max < value:
      r.add(&"{value} should be in range between {min} and {max}")
  return r

proc inRange*(this:Validation, value, min, max:int|float):bool =
  if inRange(value, min, max).len > 0:
    return false
  else:
    return true

proc ip*(this:Validation, value:string):bool =
  if domain(&"[{value}]").len > 0:
    return false
  else:
    return true

proc isBool(value:string):seq[string] =
  var r = newSeq[string]()
  try:
    discard value.parseBool()
  except:
    r.add(&"{value} is not float")
  return r

proc isBool*(this:Validation, value:string):bool =
  if isBool(value).len > 0:
    return false
  else:
    return true

proc isFloat(value:string):seq[string] =
  var r = newSeq[string]()
  try:
    discard value.parseFloat()
  except:
    r.add(&"{value} is not float")
  return r

proc isFloat*(this:Validation, value:string):bool =
  if isFloat(value).len > 0:
    return false
  else:
    return true

proc isInt(value:string):seq[string] =
  var r = newSeq[string]()
  try:
    discard value.parseInt()
  except:
    r.add(&"{value} is not integer")
  return r

proc isInt*(this:Validation, value:string):bool =
  if isInt(value).len > 0:
    return false
  else:
    return true

proc isString(value:string):seq[string] =
  var r = newSeq[string]()
  if not value.match(re"^(?=[a-zA-Z]+)(?!.*(true|false)).*$"):
    r.add(&"{value} is not a string")
  return r

proc isString*(this:Validation, value:string):bool =
  if isString(value).len > 0:
    return false
  else:
    return true

proc lessThan(sub, target:int|float):seq[string] =
  var r = newSeq[string]()
  if sub >= target:
    r.add(&"{sub} should be less than {target}")
  return r

proc lessThan*(this:Validation, sub, target:int|float):bool =
  if lessThan(sub, target).len > 0:
    return false
  else:
    return true

proc numeric(value:string):seq[string] =
  var r = newSeq[string]()
  try:
    let _ = value.parseFloat
  except:
    r.add(&"{value} should be numeric")
  return r

proc numeric*(this:Validation, value:string):bool =
  if numeric(value).len > 0:
    return false
  else:
    return true

proc password(value:string):seq[string] =
  var r = newSeq[string]()
  if value.len == 0:
    r.add("this field is required")

  if value.len < 8:
    r.add("password needs at least 8 chars")

  if not value.match(re"(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[!-~a-zA-Z\d]*"):
    r.add("invalid form of password")
  return r

proc password*(this:Validation, value:string):bool =
  if password(value).len > 0:
    return false
  else:
    return true

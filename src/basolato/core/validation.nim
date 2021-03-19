import
  json,
  re,
  tables,
  strformat,
  strutils,
  unicode,
  times


type Validation* = ref object

func newValidation*():Validation =
  return Validation()


proc accepted(value:string):bool =
  if value == "yes" or value == "on" or value == "1" or value == "true":
    return true
  else:
    return false

proc accepted*(self:Validation, value:string):bool =
  return accepted(value)


proc after(a,b:DateTime):bool =
  return a > b

proc after*(self:Validation, a, b:DateTime):bool =
  return after(a, b)


proc afterOrEqual(a,b:DateTime):bool =
  return a >= b

proc afterOrEqual*(self:Validation, a, b:DateTime):bool =
  return afterOrEqual(a, b)


proc alpha(value:string):bool =
  return value.match(re"^[a-zA-Z]+$")

proc alpha*(self:Validation, value:string):bool =
  return alpha(value)


proc alphaDash(value:string):bool =
  return value.match(re"^[a-zA-Z0-9-_]+$")

proc alphaDash*(self:Validation, value:string):bool =
  return alphaDash(value)


proc alphaNum(value:string):bool =
  return value.match(re"^[a-zA-Z0-9]+$")

proc alphaNum*(self:Validation, value:string):bool =
  return alphaNum(value)


proc array*(value:string):bool =
  return value.match(re"^(?=.*\w,)(?!.*(=|\{|\})).*$")

proc array*(self:Validation, value:string):bool =
  return array(value)


proc before(a,b:DateTime):bool =
  return a < b

proc before*(self:Validation, a, b:DateTime):bool =
  return before(a, b)


proc beforeOrEqual(a,b:DateTime):bool =
  return a <= b

proc beforeOrEqual*(self:Validation, a, b:DateTime):bool =
  return beforeOrEqual(a, b)


proc between(value, min, max:int|float):bool =
  return min.float <= value.float and value.float <= max.float

proc between*(self:Validation, value, min, max:int|float):bool =
  return between(value, min, max)


proc between(value:string, min, max:int):bool =
  return min <= value.runeLen and value.runeLen <= max

proc between*(self:Validation, value:string, min, max:int):bool =
  return between(value, min, max)


proc between(value:openArray[string], min, max:int):bool =
  return min <= value.len and value.len <= max

proc between*(self:Validation, value:openArray[string], min, max:int):bool =
  return between(value, min, max)


proc betweenFile(value:string, min, max:int):bool =
  return min*1024 <= value.len and value.len <= max*1024

proc betweenFile*(self:Validation, value:string, min, max:int):bool =
  return betweenFile(value, min, max)


proc boolean(value:string):bool =
  try:
    discard value.parseBool
    return true
  except:
    return false

proc boolean*(self:Validation, value:string):bool =
  return boolean(value)


proc confirmed(a,b:string):bool =
  return a == b

proc confirmed*(self:Validation, a,b:string):bool =
  return a == b


proc date(value, format:string):bool =
  try:
    discard value.parse(format)
    return true
  except:
    return false

proc date*(self:Validation, value, format:string):bool =
  return date(value, format)


proc date(value:string):bool =
  try:
    if value[0] == '-':
      raise newException(Exception, "")
    discard value.parseBiggestUInt.int.fromUnix
    return true
  except:
    return false

proc date*(self:Validation, value:string):bool =
  return date(value)


proc dateEquals(value, format:string, target:DateTime):bool =
  try:
    let valDt = value.parse(format)
    return valDt.month == target.month and valDt.monthday == target.monthday
  except:
    return false

proc dateEquals*(self:Validation, value, format:string, target:DateTime):bool =
  return dateEquals(value, format, target)

proc dateEquals(value:string, target:DateTime):bool =
  try:
    if value[0] == '-':
      raise newException(Exception, "")
    let valDt = value.parseBiggestUInt.int.fromUnix.utc
    return valDt.month == target.month and valDt.monthday == target.monthday
  except:
    return false

proc dateEquals*(self:Validation, value:string, target:DateTime):bool =
  return dateEquals(value, target)


proc different(a,b:string):bool =
  return a != b

proc different*(self:Validation, a, b:string):bool =
  return different(a, b)


proc digits(value:SomeInteger, digit:int):bool =
  return value.`$`.runeLen == digit

proc digits*(self:Validation, value:SomeInteger, digit:int):bool =
  return digits(value, digit)


proc digits_between(value:SomeInteger, min, max:int):bool =
  let length = value.`$`.runeLen
  return min <= length and length <= max

proc digits_between*(self:Validation, value:SomeInteger, min, max:int):bool =
  return digits_between(value, min, max)


proc distinctArr(values:openArray[string]):bool =
  var tmp = newSeq[string](values.len)
  for i, row in values:
    if tmp.contains(row):
      return false
    else:
      tmp[i] = row
  return true

proc distinctArr*(self:Validation, values:openArray[string]):bool =
  return distinctArr(values)


proc domain(value:string):bool =
  try:
    block:
      # let fqdn = re"^(([a-z0-9]{1,2}|[a-z0-9][a-z0-9-]{0,61}[a-z0-9])\.)*([a-z0-9]{1,2}|[a-z0-9][a-z0-9-]{0,61}?[a-z0-9])$"
      let fqdn = re"^(([a-zA-Z0-9]{1,2}|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9])\.)*([a-zA-Z0-9]{1,2}|[a-zA-Z0-9][a-zA-Z0-9-]{0,61}?[a-zA-Z0-9])$"
      let addr4 = re"(([01]?[0-9]{1,2}|2(?:[0-4]?[0-9]|5[0-5]))\.){3}([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))"
      let addr4Start = re"^(([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))\.){3}([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))$"
      if value.len == 0 or value.len > 255:
        raise newException(Exception, "domain part is missing")
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
    return false
  return true

proc domain*(self:Validation, value:string):bool =
  return domain(value)


proc email(value:string):bool =
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
      return domain(value[i+2..^1])
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
      return domain(value[i+2..^1])
  except:
    return false
  return true

proc email*(self:Validation, value:string):bool =
  return email(value)

# func digits(value:string, digit:int):seq[string] =
#   var r = newSeq[string]()
#   if value.len > digit:
#     r.add(&"the number of digits in {value} should less than {digit}")
#   return r

# func digits*(self:Validation, value:string, digit:int):bool =
#   if digits(value, digit).len > 0:
#     return false
#   else:
#     return true

# func email(value:string):seq[string] =
#   var r = newSeq[string]()
#   if value.len == 0:
#     r.add("this field is required")
#   if not value.match(re"\A[\w+\-.]+@[a-zA-Z\d\-]+(\.[a-zA-Z\d\-]+)*\.[a-zA-Z]+\Z"):
#     r.add("invalid form of email")
#   return r

# func email*(self:Validation, value:string):bool =
#   if email(value).len > 0:
#     return false
#   else:
#     return true

# proc domain(value:string):seq[string] =
#   var r = newSeq[string]()
#   try:
#     block:
#       let fqdn = re"^(([a-z0-9]{1,2}|[a-z0-9][a-z0-9-]{0,61}[a-z0-9])\.)*([a-z0-9]{1,2}|[a-z0-9][a-z0-9-]{0,61}?[a-z0-9])$"
#       let addr4 = re"(([01]?[0-9]{1,2}|2(?:[0-4]?[0-9]|5[0-5]))\.){3}([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))"
#       let addr4Start = re"^(([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))\.){3}([01]?[0-9]{1,2}|2([0-4]?[0-9]|5[0-5]))$"
#       if value.len == 0 or value.len > 255:
#         raise newException(Exception, "domain part is missing")
#       if not value.startsWith("["):
#         if not (not value.match(addr4) and value.match(fqdn)):
#           raise newException(Exception, "invalid domain format")
#         elif value.find(re"\.[0-9]$|^[0-9]+$") > -1:
#           raise newException(Exception, "the last label of domain should not number")
#         else:
#           break
#       if not value.endsWith("]"):
#         raise newException(Exception, "domain lacks ']'")
#       var value = value
#       value.removePrefix("[")
#       value.removeSuffix("]")
#       if value.match(addr4Start):
#         if value != "0.0.0.0":
#           break
#         else:
#           raise newException(Exception, "domain 0.0.0.0 is invalid")
#       if value.endsWith("::"):
#         raise newException(Exception, "IPv6 should not end with '::'")
#       var v4_flg = false
#       var last = ""
#       try:
#         last = value.rsplit(":", maxsplit=1)[^1]
#       except:
#         raise newException(Exception, "invalid domain")
#       if last.match(addr4):
#         if value == "0.0.0.0":
#           raise newException(Exception, "domain 0.0.0.0 is invalid")
#         value = value.replace(last, "0:0")
#         v4_flg = true
#       var oc:int
#       if value.contains("::"):
#         oc = 8 - value.count(":")
#         if oc < 1:
#           raise newException(Exception, "8 blocks is required for IPv6")
#         var ocStr = "0:"
#         value = value.replace("::", &":{ocStr.repeat(oc)}")
#         if value.startsWith(":"):
#           value = &"0{value}"
#         if value.endsWith(":"):
#           value = &"{value}0"
#       var elems = value.split(":")
#       if elems.len != 8:
#         raise newException(Exception, "invalid IP address")
#       var res = 0
#       for i, a in elems:
#         if a.len > 4:
#           raise newException(Exception, "each blick of IP address should be shorter than 4")
#         try:
#           res += a.parseHexInt shl ((7 - i) * 16)
#         except:
#           raise newException(Exception, "invalid IPv6 address")
#       if not (res != 0 and (not v4_flg or res shr 32 == 0xffff)):
#         raise newException(Exception, "invalid IPv4-Mapped IPv6 address")
#   except:
#     r.add(getCurrentExceptionMsg())
#   return r

# proc domain*(self:Validation, value:string):bool =
#   if domain(value).len > 0:
#     return false
#   else:
#     return true

# proc validateDomain(value:string) =
#   let r = domain(value)
#   if r.len > 0:
#     raise newException(Exception, r[0])

# proc strictEmail(value:string):seq[string] =
#   var r = newSeq[string]()
#   var value = value
#   try:
#     let valid = "abcdefghijklmnopqrstuvwxyz1234567890!#$%&\'*+-/=?^_`{}|~"
#     if value.len == 0:
#       raise newException(Exception, "email is empty")
#     value = value.toLowerAscii()
#     if not value.contains("@"):
#       raise newException(Exception, "email should have '@'")
#     var i:int
#     if value.startsWith("\""):
#       i = 1
#       while i < min(64, value.len):
#         if (valid & "()<>[]:;@,. ").contains(value[i]):
#           i.inc()
#           continue
#         if $value[i] == "\\":
#           if value[i+1..^1].len > 0 and (valid & """()<>[]:;@,.\\" """).contains($value[i+1]):
#             i.inc(2)
#             continue
#           raise newException(Exception, "invalid email format")
#         if value[i] == '"':
#           break
#       if i == 64:
#         i.dec()
#       if not (value[i+1..^1].len > 0 and $value[i+1] == "@"):
#         raise newException(Exception, "invalid email local-part")
#       validateDomain(value[i+2..^1])
#     else:
#       i = 0
#       while i < min(64, value.len):
#         if valid.contains(value[i]):
#           i.inc()
#           continue
#         if $value[i] == ".":
#           if i == 0 or value[i+1..^1].len == 0 or ".@".contains(value[i+1]):
#             raise newException(Exception, "invalid email local-part")
#           i.inc()
#           continue
#         if $value[i] == "@":
#           if i == 0:
#             raise newException(Exception, "email has no local-part")
#           i.dec()
#           break
#         raise newException(Exception, "email includes invalid char")
#       if i == 64:
#         i.dec
#       if not (value[i+1..^1].len > 0 and "@".contains(value[i+1])):
#         raise newException(Exception, "email local-part should be shorter than 64")
#       validateDomain(value[i+2..^1])
#   except:
#     r.add(getCurrentExceptionMsg())
#   return r

# proc strictEmail*(self:Validation, value:string):bool =
#   if strictEmail(value).len > 0:
#     return false
#   else:
#     return true

# func equals(sub:any, target:any):seq[string] =
#   var r = newSeq[string]()
#   if sub != target:
#     r.add(&"{$sub} should be {$target}")
#   return r

# func equals*(self:Validation, sub:any, target:any):bool =
#   if equals(sub, target).len > 0:
#     return false
#   else:
#     return true

# func gratorThan(sub, target:int|float):seq[string] =
#   var r = newSeq[string]()
#   if sub <= target:
#     r.add(&"{$sub} should be grator than {$target}")
#   return r

# func gratorThan*(self:Validation, sub, target:int|float):bool =
#   if gratorThan(sub, target).len > 0:
#     return false
#   else:
#     return true

# func inRange(value, min, max:int|float):seq[string] =
#   var r = newSeq[string]()
#   block:
#     if value < min or max < value:
#       r.add(&"{value} should be in range between {min} and {max}")
#   return r

# func inRange*(self:Validation, value, min, max:int|float):bool =
#   if inRange(value, min, max).len > 0:
#     return false
#   else:
#     return true

# proc ip*(self:Validation, value:string):bool =
#   if domain(&"[{value}]").len > 0:
#     return false
#   else:
#     return true

# func isBool(value:string):seq[string] =
#   var r = newSeq[string]()
#   try:
#     discard value.parseBool()
#   except:
#     r.add(&"{value} is not float")
#   return r

# func isBool*(self:Validation, value:string):bool =
#   if isBool(value).len > 0:
#     return false
#   else:
#     return true

# func isFloat(value:string):seq[string] =
#   var r = newSeq[string]()
#   try:
#     discard value.parseFloat()
#   except:
#     r.add(&"{value} is not float")
#   return r

# func isFloat*(self:Validation, value:string):bool =
#   if isFloat(value).len > 0:
#     return false
#   else:
#     return true

# func isInt(value:string):seq[string] =
#   var r = newSeq[string]()
#   try:
#     discard value.parseInt()
#   except:
#     r.add(&"{value} is not integer")
#   return r

# func isInt*(self:Validation, value:string):bool =
#   if isInt(value).len > 0:
#     return false
#   else:
#     return true

# func isString(value:string):seq[string] =
#   var r = newSeq[string]()
#   if not value.match(re"^(?=[a-zA-Z]+)(?!.*(true|false)).*$"):
#     r.add(&"{value} is not a string")
#   return r

# func isString*(self:Validation, value:string):bool =
#   if isString(value).len > 0:
#     return false
#   else:
#     return true

# func lessThan(sub, target:int|float):seq[string] =
#   var r = newSeq[string]()
#   if sub >= target:
#     r.add(&"{sub} should be less than {target}")
#   return r

# func lessThan*(self:Validation, sub, target:int|float):bool =
#   if lessThan(sub, target).len > 0:
#     return false
#   else:
#     return true

# func numeric(value:string):seq[string] =
#   var r = newSeq[string]()
#   try:
#     let _ = value.parseFloat
#   except:
#     r.add(&"{value} should be numeric")
#   return r

# func numeric*(self:Validation, value:string):bool =
#   if numeric(value).len > 0:
#     return false
#   else:
#     return true

# func password(value:string):seq[string] =
#   var r = newSeq[string]()
#   if value.len == 0:
#     r.add("this field is required")

#   if value.len < 8:
#     r.add("password needs at least 8 chars")

#   if not value.match(re"(?=.*?[a-z])(?=.*?[A-Z])(?=.*?\d)[!-~a-zA-Z\d]*"):
#     r.add("invalid form of password")
#   return r

# func password*(self:Validation, value:string):bool =
#   if password(value).len > 0:
#     return false
#   else:
#     return true

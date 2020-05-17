import json
# framework
import base, security
# 3rd party
import templates

# framework
export base, security
export templates


type View* = ref object
  auth*:Auth

proc newView*(auth:Auth=nil):View =
  if auth.isNil:
    return View(auth:Auth())
  else:
    return View(auth:auth)

proc get*(val:JsonNode):string =
  case val.kind
  of JString:
    return val.getStr
  of JInt:
    return $(val.getInt)
  of JFloat:
    return $(val.getFloat)
  of JBool:
    return $(val.getBool)
  of JNull:
    return ""
  else:
    raise newException(JsonKindError, "val is array")

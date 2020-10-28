import templates, json
export templates
import core/security
export security

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

proc old*(params:JsonNode, key:string):string =
  try:
    return params[key].get()
  except:
    return ""

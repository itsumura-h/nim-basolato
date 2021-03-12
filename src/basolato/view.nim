import
  templates, json, random, tables, strformat, strutils, asyncdispatch, cgi, re
export templates, asyncdispatch, re
import core/security, core/utils
export security

proc get*(val:JsonNode):string =
  case val.kind
  of JString:
    return val.getStr.xmlEncode
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

proc get*(val:string|TaintedString):string =
  return val.string.xmlEncode

proc old*(params:JsonNode, key:string):string =
  if params.hasKey(key):
    return params[key].get()
  else:
    return ""

proc old*(params:TableRef, key:string):string =
  if params.hasKey(key):
    return params[key].xmlEncode
  else:
    return ""

type Css* = ref object
  body:string
  saffix:string

proc newCss*(body, saffix:string):Css =
  return Css(body:body, saffix:saffix)

proc `$`*(self:Css):string =
  return self.body

proc get*(self:Css, name:string):string =
  return name & self.saffix

when isExistsLibsass():
  import sass
  import random
  randomize()
  template style*(typ:string, name, body: untyped):untyped =
    if not ["css", "scss"].contains(typ):
      raise newException(Exception, "style type css/scss is only avaiable")
    let name = (proc ():Css =
      var css =
        if typ == "scss":
          compile(body)
        else:
          body
      var matches = newSeq[string]()
      for row in css.findAll(re"\.[\d\w]+"):
        if not matches.contains(row):
          matches.add(row)

      var saffix = "_"
      for _ in 0..9:
        saffix.add(char(rand(int('a')..int('z'))))

      for match in matches:
        css = css.replace(match, match & saffix)
      let cssBody = "<style type=\"text/css\">" & css & "</style>"
      return newCss(cssBody, saffix)
    )()
else:
  template style*(typ:string, name, body: untyped):untyped =
    if typ != "css": raise newException(Exception, "You can use only css for the style type.\nTo use scss, please install libsass.\nhttps://github.com/sass/libsass")
    let name = (proc():Css =
      var saffix = "_"
      for _ in 0..9:
        saffix.add(char(rand(int('a')..int('z'))))

      var css = body
      var matches = newSeq[string]()
      for row in css.findAll(re"\.[\d\w]+"):
        if not matches.contains(row):
          matches.add(row)

      for match in matches:
        css = css.replace(match, match & saffix)
      let cssBody = "<style type=\"text/css\">" & css & "</style>"
      return newCss(cssBody, saffix)
    )()

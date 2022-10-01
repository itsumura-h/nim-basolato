import std/asyncdispatch; export asyncdispatch
import std/cgi; export cgi
import std/json
import std/re; export re
import std/strformat
import std/strutils; export strutils
import std/tables; export tables
import ./core/baseEnv
import ./core/security/context; export context
import ./core/security/csrf_token; export csrf_token
import ./core/security/random_string
import ./core/templates; export templates

when defined(httpbeast) or defined(httpx):
  import ./core/libservers/nostd/request; export request
else:
  import ./core/libservers/std/request; export request


proc old*(params:JsonNode, key:string, default=""):string =
  if params.hasKey(key):
    case params[key].kind
    of JString:
      return params[key].getStr
    of JInt:
      return $params[key].getInt
    of JFloat:
      return $params[key].getFloat
    of JBool:
      return $params[key].getBool
    else:
      return $params[key]
  else:
    return default


func old*(params:TableRef, key:string, default=""):string =
  if params.hasKey(key):
    return params[key]
  else:
    return default


func old*(params:Params, key:string, default=""):string =
  if params.hasKey(key):
    return params.getStr(key)
  else:
    return default


# ========== style ==========
type Style* = ref object
  body:string
  saffix:string

func new*(typ:type Style, body, saffix:string):Style =
  return Style(body:body, saffix:saffix)

proc toString*(self:Style):string =
  return self.body

proc `$`*(self:Style):string =
  return self.toString()

func element*(self:Style, name:string):string =
  return name & self.saffix

# when DOES_USE_LIBSASS:
#   import sass
#   template style*(typ:string, name, body: untyped):untyped =
#     if not ["css", "scss"].contains(typ):
#       raise newException(Exception, "style type css/scss is only avaiable")
#     var css =
#       if typ == "scss":
#         var bodyTmp = body
#         bodyTmp = bodyTmp.replace(re"\s+<style>")
#         bodyTmp = bodyTmp.replace(re"<\/style>\s+")
#         bodyTmp = compile(bodyTmp)
#         "<style>" & bodyTmp & "</style>"
#       else:
#         body
#     let name = (proc():Css =
#       var matches = newSeq[string]()
#       for row in css.findAll(re"\.[\d\w]+"):
#         if not matches.contains(row):
#           matches.add(row)

#       var saffix = "_"
#       for _ in 0..9:
#         saffix.add(char(rand(int('a')..int('z'))))

#       for match in matches:
#         css = css.replace(match, match & saffix)
#       return Css.new(css, saffix)
#     )()
# else:
#   template style*(typ:string, name, body: untyped):untyped =
#     if typ != "css": raise newException(Exception, "You can use only css for the style type.\nTo use scss, please install libsass.\nhttps://github.com/sass/libsass")
#     let name = (proc():Css =
#       var saffix = "_"
#       for _ in 0..9:
#         saffix.add(char(rand(int('a')..int('z'))))

#       var css = body
#       var matches = newSeq[string]()
#       for row in css.findAll(re"\.[\d\w]+"):
#         if not matches.contains(row):
#           matches.add(row)

#       for match in matches:
#         css = css.replace(match, match & saffix)
#       return Css.new(css, saffix)
#     )()

type StyleType* = enum
  Css, Scss

when DOES_USE_LIBSASS:
  import sass
  proc styleTmpl*(typ:StyleType, body:string):Style =
    var css =
      if typ == Scss:
        var bodyTmp = body
        bodyTmp = bodyTmp.replace(re"\s+<style>")
        bodyTmp = bodyTmp.replace(re"<\/style>\s+")
        bodyTmp = compile(bodyTmp)
        "<style>\n" & bodyTmp & "</style>"
      else:
        body

    const options = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let saffix = "_" & randStr(10, options)

    var matches = newSeq[string]()
    for row in css.findAll(re"\.[\d\w]+"):
      if not matches.contains(row):
        matches.add(row)
    for match in matches:
      css = css.replace(match, match & saffix)
    return Style.new(css, saffix)
else:
  proc styleTmpl*(typ:StyleType, body:string):Style =
    if typ != Css:
      raise newException(Exception, "You can use only css for the style type.\nTo use scss, please install libsass.\nhttps://github.com/sass/libsass")
    var css = body
    const options = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let saffix = "_" & randStr(10, options)

    var matches = newSeq[string]()
    for row in css.findAll(re"\.[\d\w]+"):
      if not matches.contains(row):
        matches.add(row)
    for match in matches:
      css = css.replace(match, match & saffix)
    return Style.new(css, saffix)

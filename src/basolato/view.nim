import
  templates,
  json,
  random,
  tables,
  strformat,
  strutils,
  asyncdispatch,
  cgi,
  re
export
  templates,
  asyncdispatch,
  re,
  tables
import
  core/security/csrf_token,
  core/security/context,
  core/utils,
  core/request
  # request_validation
export
  csrf_token,
  context,
  request
  # request_validation

randomize()

func get*(val:JsonNode):string =
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

func get*(val:string|TaintedString):string =
  return val.string.xmlEncode

func old*(params:JsonNode, key:string, default=""):string =
  if params.hasKey(key):
    return params[key].get().xmlEncode
  else:
    return default

func old*(params:TableRef, key:string, default=""):string =
  if params.hasKey(key):
    return params[key].xmlEncode
  else:
    return default

func old*(params:Params, key:string, default=""):string =
  if params.hasKey(key):
    return params.getStr(key).xmlEncode
  else:
    return default


type Css* = ref object
  body:string
  saffix:string

func new*(typ:type Css, body, saffix:string):Css =
  return Css(body:body, saffix:saffix)

func `$`*(self:Css):string =
  return self.body

func element*(self:Css, name:string):string =
  return name & self.saffix

when isExistsLibsass():
  import sass
  template style*(typ:string, name, body: untyped):untyped =
    if not ["css", "scss"].contains(typ):
      raise newException(Exception, "style type css/scss is only avaiable")
    var css =
      if typ == "scss":
        var bodyTmp = body
        bodyTmp = bodyTmp.replace(re"\s+<style>")
        bodyTmp = bodyTmp.replace(re"<\/style>\s+")
        bodyTmp = compile(bodyTmp)
        "<style>" & bodyTmp & "</style>"
      else:
        body
    let name = (proc():Css =
      var matches = newSeq[string]()
      for row in css.findAll(re"\.[\d\w]+"):
        if not matches.contains(row):
          matches.add(row)

      var saffix = "_"
      for _ in 0..9:
        saffix.add(char(rand(int('a')..int('z'))))

      for match in matches:
        css = css.replace(match, match & saffix)
      return Css.new(css, saffix)
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
      return Css.new(css, saffix)
    )()


type Script* = ref object
  body:string
  saffix:string

func new*(typ:type Script, body, saffix:string):Script =
  return Script(body:body, saffix:saffix)

func `$`*(self:Script):string =
  return self.body

func element*(self:Script, name:string):string =
  return name & self.saffix

template script*(selectors:openArray[string], name, body:untyped):untyped =
  let name = (proc():Script =
    var saffix = "_"
    for _ in 0..9:
      saffix.add(char(rand(int('a')..int('z'))))
    var script = body
    for selector in selectors:
      script = script.multiReplace(
        ("'" & selector & "'", "'" & selector & saffix & "'"),
        ("\"" & selector & "\"", "\"" & selector & saffix & "\""),
      )
    return Script.new(script, saffix)
  )()

template script*(name, body:untyped):untyped =
  let name = (proc():Script =
    var saffix = "_"
    for _ in 0..9:
      saffix.add(char(rand(int('a')..int('z'))))
    return Script.new(body, saffix)
  )()

import
  templates, json, random, tables, strformat, strutils, asyncdispatch, cgi
export templates, asyncdispatch
import core/security
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
  return val.xmlEncode

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


type CssRow = ref object
  key:string
  class:string
  value:string

type Css* = ref object
  suffix: string
  values: OrderedTable[string, OrderedTable[string, CssRow]]

randomize()

proc newCss*():Css =
  var random:string
  for _ in 0..10:
    random.add(char(rand(int('a')..int('z'))))
  return Css(suffix:random)

proc set*(this:var Css, className, option:string, value:string) =
  if not this.values.hasKey(className):
    this.values[className] = OrderedTable[string, CssRow]()
  this.values[className][option] = CssRow(
    key: &"{className}_{this.suffix}{option}",
    class: &"{className}_{this.suffix}",
    value:value
  )

proc get*(this:Css, className:string):string =
  for option, cssRow in this.values[className]:
    return cssRow.class

proc define*(this:Css):string =
  result = "<style type=\"text/css\">\n"
  for className, cssRows in this.values:
    for option, cssRow in cssRows:
      var row = &"""
.{cssRow.key} [[
{cssRow.value}]]
"""
      row = row.replace("[[", "{").replace("]]", "}")
      result.add(row)
  result.add("</style>")

import std/json
import std/macros
import std/strutils
import std/strformat
import std/tables
import ./security/random_string

# ==================== xmlEncode ====================
# extract from `cgi` to be able to run for JavaScript.
# https://nim-lang.org/docs/cgi.html#xmlEncode%2Cstring

proc addXmlChar(dest: var string, c: char) {.inline.} =
  case c
  of '&': add(dest, "&amp;")
  of '<': add(dest, "&lt;")
  of '>': add(dest, "&gt;")
  of '\"': add(dest, "&quot;")
  else: add(dest, c)

proc xmlEncode*(s: string): string =
  ## Encodes a value to be XML safe:
  ## * `"` is replaced by `&quot;`
  ## * `<` is replaced by `&lt;`
  ## * `>` is replaced by `&gt;`
  ## * `&` is replaced by `&amp;`
  ## * every other character is carried over.
  result = newStringOfCap(s.len + s.len shr 2)
  for i in 0..len(s)-1: addXmlChar(result, s[i])


# ==================== libView ====================
proc toString*(val:JsonNode):string =
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

proc toString*(val:string):string =
  return val.strip.xmlEncode

proc toString*(val:bool | int | float):string =
  return val.`$`.xmlEncode


# ==================== Component ====================
type Component* = ref object
  value:string
  id:string

proc new*(_:type Component):Component =
  let id = randStr(10)
  return Component(value:"", id:id)

proc add*(self:Component, value:string) =
  self.value.add(value)

proc toString*(self:Component):string =
  return self.value.strip()

proc `$`*(self:Component):string =
  return self.toString()

proc id*(self:Component):string = self.id


# ==================== parse template ====================
type BlockType = enum
  strBlock
  ifBlock               # $if
  elifBlock             # $elif
  elseBlock             # $else
  forBlock              # $for
  caseBlock             # $case
  ofBlock               # $of
  whileBlock            # $while
  displayVariableBlock  # $()
  nimCodeBlock          # ${}

proc identifyBlockType(str:string, point:int):BlockType =
  if str.substr(point, point+2) == "$if":
    return ifBlock
  elif str.substr(point, point+4) == "$elif":
    return elifBlock
  elif str.substr(point, point+4) == "$else":
    return elseBlock
  elif str.substr(point, point+3) == "$for":
    return forBlock
  elif str.substr(point, point+4) == "$case":
    return caseBlock
  elif str.substr(point, point+2) == "$of":
    return ofBlock
  elif str.substr(point, point+5) == "$while":
    return whileBlock
  elif str.substr(point, point+1) == "$(":
    return displayVariableBlock
  elif str.substr(point, point+1) == "${":
    return nimCodeBlock
  else:
    return strBlock


proc findStrBlock(str:string, point:int):(int, string) =
  var isDoller = false
  var blacketLevel = 0
  var count = -1
  for i in point..<str.len:
    let s = str[i]
    count += 1
    if s == '$':
      isDoller = true
      break
    elif s == '{':
      blacketLevel += 1
      continue
    elif s == '}' and blacketLevel > 0:
      blacketLevel -= 1
      continue
    elif s == '}' and blacketLevel == 0:
      break

  let resPoint = point + count
  let resStr = str.substr(point, resPoint-1) # $、}を含めない

  if isDoller:
    return (resPoint, resStr) # $からスタート
  else:
    return (resPoint+1, resStr) # 「}」の次からスタート


proc findNimVariableBlock(str:string, point:int):(int, string) =
  let point = point + 2 # 「$(」の分進める
  var parenthesisLevel = 0
  var count = -1
  for i in point..<str.len:
    let s = str[i]
    count += 1
    if s == '(':
      parenthesisLevel += 1
      continue
    if s == ')' and parenthesisLevel > 0:
      parenthesisLevel -= 1
      continue
    if s == ')' and parenthesisLevel == 0:
      break

  let resPoint = point + count
  let resStr = str.substr(point, resPoint-1) # 「)」を含めない
  return (resPoint+1, resStr) # 「)」の次からスタート


proc findNimBlock(str:string, point:int):(int, string) =
  let point = point + 1 # 「$」の分進める
  var count = -1
  for i in point..<str.len:
    let s = str[i]
    count += 1
    if s == '{':
      break

  let resPoint = point + count
  let resStr = str.substr(point, resPoint-1) # 「{」を含めない
  return (resPoint+1, resStr) # 「{」の次からスタート


proc findNimCodeBlock(str:string, point:int):(int, string) =
  let point = point + 2 # 「${」の分進める
  var blacketLevel = 0
  var count = -1
  for i in point..<str.len:
    let s = str[i]
    count += 1
    if s == '{':
      blacketLevel += 1
      continue
    if s == '}' and blacketLevel > 0:
      blacketLevel -= 1
      continue
    if s == '}' and blacketLevel == 0:
      break

  let resPoint = point + count
  let resStr = str.substr(point, resPoint-1) # 「}」を含めない
  return (resPoint+1, resStr) # 「}」の次からスタート


proc reindent(str:string, indentLevel:int):string  =
  let indent = "  ".repeat(indentLevel)
  return indent & str


macro tmpl*(html: untyped): untyped =
  # """...""" に囲まれた「...」の部分の文字列を取得
  var html =
    if html.kind in nnkStrLit..nnkTripleStrLit:
      html.strVal
    else:
      html[1].strVal

  var body = "result = Component.new()\n"
  var point = 0
  var indentLevel = 0
  var blockType = strBlock
  while true:
    # echo "=".repeat(30)

    if point == html.len:
      break

    blockType = identifyBlockType(html, point)

    case blockType
    of strBlock:
      var (resPoint, resStr) = findStrBlock(html, point)
      # echo "=== resStr"
      # echo resStr
      let isAllWhitespace = resStr.strip().len == 0
      if not isAllWhitespace: # 空白文字以外が含まれているなら、改行を残し、改行より外側の空白文字を削除して追加する
        resStr = resStr.strip(chars={' ', '\t', '\v', '\f'}) # whitespace - newline  https://nim-lang.org/docs/strutils.html#Whitespace
        resStr = newStrLitNode(resStr).repr # 複数行の文字列を改行コードを含む1行にする
        resStr = &"result.add({resStr})\n"
        resStr = reindent(resStr, indentLevel)
        body.add(resStr)
        #[
          if cond{
            aaa
          }
          $else{
            bbb
          }
          この時「}」と$elseの間の空白行に対応する必要がある
          
          if cond:
            result.add("aaa")
          result.add("       ")
          else:
          
          となってしまう
          resStr.strip()にすると改行も消えてしまう
        ]#
      point = resPoint
      # resPointの1つ前が「}」の場合、indentLevelを下げる
      if html[resPoint-1] == '}':
        indentLevel -= 1
    of ifBlock:
      var (resPoint, resStr) = findNimBlock(html, point)
      resStr = resStr.strip() & ":\n"
      resStr = reindent(resStr, indentLevel)
      body.add(resStr)
      indentLevel += 1
      point = resPoint
    of elifBlock:
      var (resPoint, resStr) = findNimBlock(html, point)
      resStr = resStr.strip() & ":\n"
      resStr = reindent(resStr, indentLevel)
      body.add(resStr)
      indentLevel += 1
      point = resPoint
    of elseBlock:
      var (resPoint, resStr) = findNimBlock(html, point)
      resStr = resStr.strip() & ":\n"
      resStr = reindent(resStr, indentLevel)
      body.add(resStr)
      indentLevel += 1
      point = resPoint
    of forBlock:
      var (resPoint, resStr) = findNimBlock(html, point)
      resStr = resStr.strip() & ":\n"
      resStr = reindent(resStr, indentLevel)
      body.add(resStr)
      indentLevel += 1
      point = resPoint
    of caseBlock:
      var (resPoint, resStr) = findNimBlock(html, point)
      resStr = resStr.strip() & ":\n"
      resStr = reindent(resStr, indentLevel)
      point = resPoint
      body.add(resStr)
    of ofBlock:
      var (resPoint, resStr) = findNimBlock(html, point)
      resStr = resStr.strip() & ":\n"
      resStr = reindent(resStr, indentLevel)
      point = resPoint
      body.add(resStr)
      indentLevel += 1
    of whileBlock:
      var (resPoint, resStr) = findNimBlock(html, point)
      resStr = resStr.strip() & ":\n"
      resStr = reindent(resStr, indentLevel)
      point = resPoint
      body.add(resStr)
      indentLevel += 1
    of displayVariableBlock:
      var (resPoint, resStr) = findNimVariableBlock(html, point)
      resStr = resStr.strip()
      resStr = &"result.add(toString(({resStr})))"
      resStr = reindent(resStr, indentLevel)
      body.add(resStr & "\n")
      point = resPoint
    of nimCodeBlock:
      var (resPoint, resStr) = findNimCodeBlock(html, point)
      resStr = resStr.strip() & "\n"
      resStr = reindent(resStr, indentLevel)
      body.add(resStr)
      point = resPoint

    # echo ""
    # echo body

    if point == html.len:
      break

  return body.parseStmt()

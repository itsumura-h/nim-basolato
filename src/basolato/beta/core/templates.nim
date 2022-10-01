# Edited for sanitizing
# https://github.com/onionhammer/nim-templates

import std/json
import std/macros
import std/parseutils
import std/strutils
import std/tables
import ./security/random_string


# ========== xmlEncode ==========
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


# ========== libView ==========
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


# ========== Component ==========
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


# ========== annotate ==========
# Generate tags
macro make(names: varargs[untyped]): void =
  result = newStmtList()

  for i in 0 .. names.len-1:
    result.add newProc(
        name = ident($names[i]).postfix("*"),
        params = [
            ident("string"),
            newIdentDefs(
                ident("content"),
                ident("string")
      )
    ],
        body = newStmtList(
            parseStmt("reindent(content)")
      )
    )


iterator lines(value: string): string =
  var i = 0
  while i < value.len:
    var line: string
    inc(i, value.parseUntil(line, 0x0A.char, i) + 1)
    yield line


proc reindent*(value: string, presetIndent = 0): string =
  var indent = -1

  # Detect indentation!
  for ln in lines(value):
    var read = ln.skipWhitespace()

    # If the line is empty, ignore it for indentation
    if read == ln.len: continue

    indent = if indent < 0: read
                 else: min(indent, read)

  # Create a precursor indent as-needed
  var precursor = newString(0)
  for i in 1 .. presetIndent:
    precursor.add(' ')

  # Re-indent
  result = newString(0)

  for ln in lines(value):
    var value = ln.substr(indent)

    result.add(precursor)

    if value.len > 0:
      result.add(value)
      result.add(0x0A.char)

  return result

#Define tags
make(html, xml, glsl, js, css, rst, md, nim)


# ========== templates ==========
# Fields
const identChars = {'a'..'z', 'A'..'Z', '0'..'9', '_'}


# Procedure Declarations
proc parseTemplate(node: NimNode, value: string) {.compiletime.}


# Procedure Definitions
proc substring(value: string, index: int, length = -1): string {.compiletime.} =
  ## Returns a string at most `length` characters long, starting at `index`.
  return if length < 0: value.substr(index)
           elif length == 0: ""
           else: value.substr(index, index + length-1)


proc parseThruEol(value: string, index: int): int {.compiletime.} =
  ## Reads until and past the end of the current line, unless
  ## a non-whitespace character is encountered first
  var remainder: string
  var read = value.parseUntil(remainder, {0x0A.char}, index)
  if remainder.skipWhitespace() == read:
    return read + 1


proc trimAfterEol(value: var string) {.compiletime.} =
  ## Trims any whitespace at end after \n
  var toTrim = 0
  for i in countdown(value.len-1, 0):
    # If \n, return
    if value[i] in [' ', '\t']: inc(toTrim)
    else: break

  if toTrim > 0:
    value = value.substring(0, value.len - toTrim)


proc trimEol(value: var string) {.compiletime.} =
  ## Removes everything after the last line if it contains nothing but whitespace
  for i in countdown(value.len - 1, 0):
    # If \n, trim and return
    if value[i] == 0x0A.char:
      value = value.substr(0, i)
      break

    # Skip change
    if not (value[i] in [' ', '\t']): break

    # This is the first character, and it's not whitespace
    if i == 0:
      value = ""
      break

proc detectIndent(value: string, index: int): int {.compiletime.} =
  ## Detects how indented the line at `index` is.
  # Seek to the beginning of the line.
  var lastChar = index
  for i in countdown(index, 0):
    if value[i] == 0x0A.char:
      # if \n, return the indentation level
      return lastChar - i
    elif not (value[i] in [' ', '\t']):
      # if non-whitespace char, decrement lastChar
      dec(lastChar)


proc parseThruString(value: string, i: var int,
        strType = '"') {.compiletime.} =
  ## Parses until ending " or ' is reached.
  inc(i)
  if i < value.len-1:
    inc(i, value.skipUntil({'\\', strType}, i))


proc parseToClose(value: string, index: int, open = '(', close = ')',
        opened = 0): int {.compiletime.} =
  ## Reads until all opened braces are closed
  ## ignoring any strings "" or ''
  var remainder = value.substring(index)
  var openBraces = opened
  result = 0

  while result < remainder.len:
    var c = remainder[result]

    if c == open: inc(openBraces)
    elif c == close: dec(openBraces)
    elif c == '"': remainder.parseThruString(result)
    elif c == '\'': remainder.parseThruString(result, '\'')

    if openBraces == 0: break
    else: inc(result)


iterator parseStmtList(value: string, index: var int): string =
  ## Parses unguided ${..} block
  var read = value.parseToClose(index, open = '{', close = '}')
  var expressions = value.substring(index + 1, read - 1).split({';', 0x0A.char})

  for expression in expressions:
    let value = expression.strip
    if value.len > 0:
      yield value

  #Increment index & parse thru EOL
  inc(index, read + 1)
  inc(index, value.parseThruEol(index))


iterator parseCompoundStatements(value, identifier: string,
        index: int): string =
  ## Parses through several statements, i.e. if {} elif {} else {}
  ## and returns the initialization of each as an empty statement
  ## i.e. if x == 5 { ... } becomes if x == 5: nil.

  template getNextIdent(expected): void =
    var nextIdent: string
    discard value.parseWhile(nextIdent, {'$'} + identChars, i)

    var next: string
    var read: int

    if nextIdent == "case":
      # We have to handle case a bit differently
      read = value.parseUntil(next, '$', i)
      inc(i, read)
      yield next.strip(leading = false) & "\n"

    else:
      read = value.parseUntil(next, '{', i)

      if nextIdent in expected:
        inc(i, read)
        # Parse until closing }, then skip whitespace afterwards
        read = value.parseToClose(i, open = '{', close = '}')
        inc(i, read + 1)
        inc(i, value.skipWhitespace(i))
        yield next & ": nil\n"

      else: break


  var i = index
  while true:
    # Check if next statement would be valid, given the identifier
    if identifier in ["if", "when"]:
      getNextIdent([identifier, "$elif", "$else"])

    elif identifier == "case":
      getNextIdent(["case", "$of", "$elif", "$else"])

    elif identifier == "try":
      getNextIdent(["try", "$except", "$finally"])


proc parseComplexStmt(value, identifier: string,
        index: var int): NimNode {.compiletime.} =
  ## Parses if/when/try /elif /else /except /finally statements

  # Build up complex statement string
  var stmtString = newString(0)
  var numStatements = 0
  for statement in value.parseCompoundStatements(identifier, index):
    if statement[0] == '$': stmtString.add(statement.substr(1))
    else: stmtString.add(statement)
    inc(numStatements)

  # Parse stmt string
  result = parseExpr(stmtString)

  var resultIndex = 0

  # Fast forward a bit if this is a case statement
  if identifier == "case":
    inc(resultIndex)

  while resultIndex < numStatements:

    # Detect indentation
    let indent = detectIndent(value, index)

    # Parse until an open brace `{`
    var read = value.skipUntil('{', index)
    inc(index, read + 1)

    # Parse through EOL
    inc(index, value.parseThruEol(index))

    # Parse through { .. }
    read = value.parseToClose(index, open = '{', close = '}', opened = 1)

    # Add parsed sub-expression into body
    var body = newStmtList()
    var stmtString = value.substring(index, read)
    trimAfterEol(stmtString)
    stmtString = reindent(stmtString, indent)
    parseTemplate(body, stmtString)
    inc(index, read + 1)

    # Insert body into result
    var stmtIndex = len(result[resultIndex]) - 1
    result[resultIndex][stmtIndex] = body

    # Parse through EOL again & increment result index
    inc(index, value.parseThruEol(index))
    inc(resultIndex)


proc parseSimpleStatement(value: string,
        index: var int): NimNode {.compiletime.} =
  ## Parses for/while

  # Detect indentation
  let indent = detectIndent(value, index)

  # Parse until an open brace `{`
  var splitValue: string
  var read = value.parseUntil(splitValue, '{', index)
  result = parseExpr(splitValue & ":nil")
  inc(index, read + 1)

  # Parse through EOL
  inc(index, value.parseThruEol(index))

  # Parse through { .. }
  read = value.parseToClose(index, open = '{', close = '}', opened = 1)

  # Add parsed sub-expression into body
  var body = newStmtList()
  var stmtString = value.substring(index, read)
  trimAfterEol(stmtString)
  stmtString = reindent(stmtString, indent)
  parseTemplate(body, stmtString)
  inc(index, read + 1)

  # Insert body into result
  var stmtIndex = len(result) - 1
  result[stmtIndex] = body

  # Parse through EOL again
  inc(index, value.parseThruEol(index))


proc parseUntilSymbol(node: NimNode, value: string,
        index: var int): bool {.compiletime.} =
  ## Parses a string until a $ symbol is encountered, if
  ## two $$'s are encountered in a row, a split will happen
  ## removing one of the $'s from the resulting output
  var splitValue: string
  var read = value.parseUntil(splitValue, '$', index)
  var insertionPoint = node.len

  inc(index, read + 1)
  if index < value.len:

    case value[index]
    of '$':
      # Check for duplicate `$`, meaning this is an escaped $
      node.add newCall("add", ident("result"), newStrLitNode("$"))
      inc(index)

    of '(':
      # Check for open `(`, which means parse as simple single-line expression.
      trimEol(splitValue)
      read = value.parseToClose(index) + 1
      node.add newCall("add", ident("result"),
          # newCall(bindSym"strip", parseExpr("$" & value.substring(index, read)))
          newCall("toString", parseExpr(value.substring(index, read)))
      )
      inc(index, read)

    of '{':
      # Check for open `{`, which means open statement list
      trimEol(splitValue)
      for s in value.parseStmtList(index):
        node.add parseExpr(s)

    else:
      # Otherwise parse while valid `identChars` and make expression w/ $
      var identifier: string
      read = value.parseWhile(identifier, identChars, index)

      if identifier in ["for", "while"]:
        ## for/while means open simple statement
        trimEol(splitValue)
        node.add value.parseSimpleStatement(index)

      elif identifier in ["if", "when", "case", "try"]:
        ## if/when/case/try means complex statement
        trimEol(splitValue)
        node.add value.parseComplexStmt(identifier, index)

      elif identifier.len > 0:
        ## Treat as simple variable
        node.add newCall("add", ident("result"), newCall("$", ident(identifier)))
        inc(index, read)

    result = true

  # Insert
  if splitValue.len > 0:
    node.insert insertionPoint, newCall("add", ident("result"),
            newStrLitNode(splitValue))


proc parseTemplate(node: NimNode, value: string) =
  ## Parses through entire template, outputing valid
  ## Nim code into the input `node` AST.
  var index = 0
  while index < value.len and
        parseUntilSymbol(node, value, index): discard

when not defined(js):
  macro tmplf*(body: untyped): void =
    result = newStmtList()
    # result.add parseExpr("result = \"\"")
    result.add parseExpr("result = Component.new()")
    var value = readFile(body.strVal)
    parseTemplate(result, reindent(value))


macro tmpli*(body: untyped): void =
  result = newStmtList()

  result.add parseExpr("result = Component.new()")

  var value = if body.kind in nnkStrLit..nnkTripleStrLit: body.strVal
                else: body[1].strVal

  parseTemplate(result, reindent(value))


macro tmpl*(body: untyped): void =
  result = newStmtList()

  var value = if body.kind in nnkStrLit..nnkTripleStrLit: body.strVal
                else: body[1].strVal

  parseTemplate(result, reindent(value))

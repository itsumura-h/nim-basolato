import
  std/jsffi,
  std/jsfetch,
  std/jscore,
  std/asyncjs,
  std/strutils


let document {.importc.}: JsObject
let console {.importc.}: JsObject

var
  dom:JsObject
  num = 1

proc inc(a:int):int =
  return a+1

proc init(idName:cstring) {.exportc.} =
  dom = document.getElementById(idName)
  dom.innerText = num.toJs()

proc addDom() {.exportc.} =
  num = num.inc()
  dom.innerText = num.toJs()

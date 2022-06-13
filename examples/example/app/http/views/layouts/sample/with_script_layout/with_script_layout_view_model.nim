import
  std/asyncdispatch,
  std/json

type WithScriptLayoutViewModel* = ref object

proc new*(_:type WithScriptLayoutViewModel):WithScriptLayoutViewModel =
  discard

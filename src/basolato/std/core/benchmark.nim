import std/times
import std/math
import strformat
import strutils

proc toString(t:Duration):string =
  let secound = t.inSeconds
  let miliSecound = t.inMilliseconds.int.intToStr(3)
  let nanoSecound = t.inNanoseconds.int
  return &"{secound}.{miliSecound}{nanoSecound}"

var t:Time
proc diffTime*(num:int) =
  let c = getTime()
  if t == Time(): t = c
  echo (c - t).toString()
  echo "===== " & $num
  t = c

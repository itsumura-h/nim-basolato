import os, strformat, strutils, terminal, random

proc isFileExists*(targetPath:string):bool =
  if existsFile(targetPath):
    let message = &"{targetPath} is already exists"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return true
  else:
    return false

proc isDirExists*(targetPath:string):bool =
  if existsDir(targetPath):
    let message = &"{targetPath} is already exists"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return true
  else:
    return false

proc isTargetContainSlash*(target:string):bool =
  if target.contains("/"):
    let message = &"Don't contain \"/\" in migration file name"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return true
  else:
    return false

proc rundStr*(n:openArray[int]):string =
  randomize()
  let options = {'0','1','2','3','4','5','6','7','8','9',
    'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r',
    's','t','u','v','w','x','y','z',
    'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R',
    'S','T','U','V','W','X','Y','Z',
    '!','#','$','%','&','(',')','-','=','~','^','|','@','[','{',';','+','*',
    ']','}',',','<','.','>','/','?','_'
  }
  var n = n.sample()
  for _ in 1..n:
    add(result, options.sample())

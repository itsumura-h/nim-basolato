import strformat, terminal

proc make*(args:seq[string]):int =
  ## make file
  var
    message:string
    todo:string
    target:string
  
  try:
    todo = args[0]
    target = args[1]
  except:
    message = "missing args"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 0

  case todo:
  of "controller":
    message = &"create controller {target}Controller"
    styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  else:
    message = "invalid things to make"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
  
import strformat, terminal

proc new*(args:seq[string], architecture="MVC"):int =
  ## create new project
  var
    message:string
    packageDir:string

  if args.len > 0 and args[0].len > 0:
    packageDir = args[0]
    message = &"create project {packageDir}"
  else:
    message = "create project here"

  case architecture:
  of "MVC":
    message.add("\ncreate as MVC")
    styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  of "DDD":
    message.add("\ncreate as DDD")
    styledWriteLine(stdout, fgGreen, bgDefault, message, resetStyle)
  else:
    message = """
invalid architecture.
MVC or DDD is only available.
MVC is set by default."""
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
    return 1
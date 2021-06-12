import os, strformat, terminal
import allographer/query_builder

let
  dbName = getEnv("DB_DATABASE")
  connection = getEnv("DB_CONNECTION")

proc migrate*(args:seq[string]):int =
  if args.len == 0:
    discard execShellCmd("nim c -r migrations/migrate")
    return 0

  let arg = args[0]
  if arg == "clear":
    if fileExists(connection):
      discard tryRemoveFile(connection)
      let f = open(connection, fmWrite)
      defer: f.close()
      f.write("")
    else:
      rdb().raw(&"DROP DATABASE {dbName}").exec()
      rdb().raw(&"CREATE DATABASE {dbName}").exec()
  elif arg == "fresh":
    discard execShellCmd("ducere migrate clear")
    discard execShellCmd("ducere migrate")
  else:
    let message = "Invalid args"
    styledWriteLine(stdout, fgRed, bgDefault, message, resetStyle)
  return 0

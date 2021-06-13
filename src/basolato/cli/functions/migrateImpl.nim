import os, strformat, terminal
import allographer/query_builder

proc migrate*(args:seq[string]):int =
  if args.len == 0:
    discard execShellCmd("nim c -r migrations/migrate")
    return 0

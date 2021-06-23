import os

proc migrate*(args:seq[string]):int =
  if args.len == 0:
    discard execShellCmd("nim c -r migrations/migrate")
    return 0

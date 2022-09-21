import os

proc seed*(args:seq[string]):int =
  ## Run seeder
  if args.len == 0:
    discard execShellCmd("nim c -r database/seeders/seed")
    return 0

import os

proc migrate*(seed=false, args:seq[string]):int =
  ## Run migration
  echo seed
  discard execShellCmd("nim c -r database/migrations/migrate")
  if seed:
    discard execShellCmd("nim c -r database/seeders/seed")
  return 0

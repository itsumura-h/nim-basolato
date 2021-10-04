import os

proc migrate*(reset=false, seed=false, args:seq[string]):int =
  ## Run migration
  if reset:
    discard execShellCmd("nim c -r database/migrations/migrate --reset")
  else:
    discard execShellCmd("nim c -r database/migrations/migrate")

  if seed:
    discard execShellCmd("nim c -r database/seeders/seed")
  return 0

import os

proc migrate*() =
  ## Run migration
  discard execShellCmd("nim c -r migrations/migrate")
